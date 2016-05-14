class GithubUploader
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(path, temp_path, message = nil)
    content = File.read temp_path
    message ||= "Added file: #{path}"

    response = client.repos.contents.create username, repository, path, {
      path: path, content: content, message: message
    }

    store message: message
    store failed: (response.success? ? 0 : 1)
    store github_url: response.try(:content).try(:html_url)
    store uploaded_at: (response.success? ? Time.now : nil)

    response
  end

  private

  def secrets
    Rails.application.secrets.github
  end

  def username
    secrets['user']
  end

  def password
    secrets['token']
  end

  def repository
    secrets['repo']
  end

  def client
    @client ||= Github.new(
      basic_auth: "#{username}:#{password}",
      user: username, repo: repository
    )
  end
end
