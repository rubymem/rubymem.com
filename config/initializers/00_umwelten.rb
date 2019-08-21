require 'find'

settings_path = File.join(Rails.root, "config/settings")

search_dirs = [settings_path]
files = []

until search_dirs.empty?

  search_path = search_dirs.shift 
  Find.find(search_path) do |path|

    unless path == search_path 

      if File.directory?( path )
        
        if File.symlink?(path)
          search_dirs << "#{path}/"
        else
          search_dirs << path
        end

      else
        files << path
      end

    end
  end
end


files.each do |file|
  new_conf = YAML.load_file(file)
  file_name = File.basename(file)
  next unless new_conf.is_a? Hash

  if new_conf[Rails.env]
    new_settings = new_conf[Rails.env]

    key = new_settings.keys.first
    if key
      Rails.configuration.send("#{key}=", OpenStruct.new(new_settings[key]))
    end
  end
end
