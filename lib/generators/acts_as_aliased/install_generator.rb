require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module ActsAsAliased
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration
    source_root File.expand_path("../templates", __FILE__)

    def create_migration_file
      puts "Adding a migration..."
      migration_template 'migration.rb', 'db/migrate/create_acts_as_alias_table.rb' rescue puts $!.message
    end

  end
end
