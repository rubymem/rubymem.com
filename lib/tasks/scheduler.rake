desc "Import leaky gems from https://github.com/rubymem/ruby-mem-advisory-db "
namespace :rubymem do
  task :import => :environment do
    puts "Importing rubymem leaky gems database..."
    RubymemImporter.new.import!
    puts "done."
  end
end
