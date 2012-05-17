def in_memory_database?
  Rails.configuration.database_configuration[ENV["RAILS_ENV"]] and
  Rails.configuration.database_configuration[ENV["RAILS_ENV"]]['database'] == ':memory:'
end

def initialize_in_memory_database
  puts "Creating SQLite in memory database"
  ActiveRecord::Schema.verbose = false
  load "#{Rails.root}/db/schema.rb"
  # ActiveRecord::Migrator.up('db/migrate')
end