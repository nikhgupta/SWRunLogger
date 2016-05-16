require 'csv'
class CsvImporter
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(user_id, path)
    @path, @user = path, User.find(user_id)

    read_csv_data
    verify_csv_upload!
    total @csv.count

    @import = @user.imports.create path: path
    upload_csv_to_github if Rails.env.production?

    @csv = @csv.each_with_index.map do |row, i|
      at i+1; add_sprint @import.id, row
    end

    counts = { total: @csv.count, saved: @csv.count(:saved),
      faulty: @csv.count(:faulty), existing: @csv.count(:existing) }

    counts.each{|key, value| store key => value }
    @import.update_attributes(counts.merge(uploaded_at: Time.now))

    @user.invalidate_cache!
  rescue StandardError => e
    message = "Invalid file imported! Is this, really, a CSV file?"
    message = "#{e.class}: #{e.message}" unless e.is_a?(CSV::MalformedCSVError)
    store error: message
  end

  private

  def verify_csv_upload!
    keys = ["dungeon", "cleartime", "runegrade", "sellvalue"]
    csv_keys = @csv[0].keys.map{|key| key.downcase.gsub(/[^a-z0-9]/, '')}
    return if csv_keys & keys == keys
    raise RuntimeError, "Invalid CSV data detected! Is this, really, a runs.csv?"
  end

  def add_sprint(*args)
    SprintImporter.new.perform(*args)
  end

  def upload_csv_to_github
    gh_job_id = CsvUploader.perform_async @import.id, prefix: "runs"
    store upload_job_id: gh_job_id
  end

  def read_csv_data
    content = File.read @path
    content = content.encode Encoding.find('ASCII'), invalid: :replace,
      undef: :replace, replace: '', universal_newline: true

    data = CSV.parse content
    keys = data.shift
    @csv = data.map{|s| Hash[ keys.zip(s) ] }

    store stage: :read_csv
  end
end
