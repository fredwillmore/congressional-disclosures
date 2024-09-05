namespace :db do
  namespace :seed do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb').intern
      desc "Run seed file #{filename}"
      task task_name, [:options] => :environment do |t, args|
        begin
          options = JSON.parse(args[:options] || '{}')
        rescue JSON::ParserError => e
          puts "Failed to parse options: #{e.message}"
        end

        # Set a global variable to pass options
        $options = options
        load(filename) if File.exist?(filename)
      end
    end
  end
  
  desc "Drop, create, migrate the database"
  task :rebuild => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end
end
