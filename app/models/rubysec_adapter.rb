class RubysecAdapter < AdvisoryAdapter.new(:filepath, :gem, :cve, 
                                           :osvdb, :url, :title, 
                                           :date, :description, :cvss_v2, 
                                           :cvss_v3, :patched_versions, :unaffected_versions, 
                                           :related)
  def identifier
    filepath.split("/")[-2..-1].join("/")
  end

  def to_h
    super.merge(:identifier => identifier,
                :imported => true)
      .except(:filepath).stringify_keys
  end
end
