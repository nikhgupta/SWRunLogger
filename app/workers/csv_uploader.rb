class CsvUploader < GithubUploader
  def perform(import_id, options = {})
    @kind   = options.fetch 'prefix', 'miscelleneous'
    @import = Import.includes(:user).find import_id

    time = Time.now.strftime("%Y%m%d-%H%M%S")
    file = "#{@kind}/#{@import.user.id}/#{time}#{File.extname(@import.path)}"

    message   = "Added '#{@kind}' log for User with ID: #{@import.user.id}"
    response  = super(file, @import.path, message)
    temp_path = @import.path

    @import.update_attributes(
      path: response.content.path, uploaded_at: Time.now
    ) if response.success?
  end
end
