require_relative File.join(Rails.root, 'lib/git_handler')
class RubysecImporter
  SOURCE = "rubysec"
  PLATFORM = "ruby"
  REPO_URL = "https://github.com/rubysec/ruby-advisory-db.git"
  REPO_PATH = "tmp/importers/rubysec"

  def initialize(repo_path = nil, repo_url = nil)
    @repo_url = repo_url || REPO_URL
    @repo_path = repo_path || REPO_PATH
  end

  def import!
    update_local_store!
    raw_advisories = fetch_advisories
    all_advisories = raw_advisories.lazy.map { |ra| parse(ra) }
    process_advisories(all_advisories)

  end

  def process_advisories(all_advisories)
    all_advisories.each do |new_adv|
      old_adv = RubysecAdvisory.where(:identifier => new_adv.identifier).first

      if old_adv.nil?
        created_adv = RubysecAdvisory.create!(new_adv.to_h)
      else
        old_adv.update_attributes!(new_adv.to_h)
      end
    end
  end

  def local_path
    File.join(Rails.root, @repo_path)
  end

  def update_local_store!
    git = GitHandler.new(self.class, @repo_url, local_path)
    git.fetch_and_update_repo!
  end

  def fetch_advisories
    Dir[File.join(local_path, "gems", "/**/**yml")]  
  end

  def parse(ymlfile)
    hsh = YAML.load_file(ymlfile)
    everything = {"filepath" => ymlfile}.merge(hsh)
    RubysecAdapter.new(everything)
  end
end
