class RubymemAdapter < AdvisoryAdapter.new(
  :filepath,
  :gem,
  :url,
  :title,
  :date,
  :description,
  :patched_versions,
  :unaffected_versions,
  :related
)

  def identifier
    filepath.split("/")[-2..-1].join("-").gsub(".yml", "")
  end

  def to_h
    super.merge(:identifier => identifier,
                :imported => true)
      .except(:filepath).stringify_keys
  end
end
