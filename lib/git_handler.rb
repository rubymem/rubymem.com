require 'fileutils'
require 'open3'

class GitHandler
  attr_accessor :klass_name, :repo_url, :local_path
  def initialize(klass, url, path)
    self.klass_name = klass.name
    self.repo_url = url
    self.local_path = path
  end

  def fetch_and_update_repo!
    if File.exists?(local_path)
      output, process = Open3.capture2e("cd #{local_path} && git pull")
      unless process.success?
        raise "#{klass_name} - something went wrong pulling: #{output}"
      end
    else
      FileUtils.mkdir_p(local_path)
      output, process = Open3.capture2e("git clone #{repo_url} #{local_path}")
      unless process.success?
        raise "#{klass_name} - something went wrong cloning: #{output}"
      end
    end
  end
end
