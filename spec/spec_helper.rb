$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'acts_as_aliased'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do

  create_table :aliases do |t|
    t.integer :aliased_id,    null: false
    t.string  :aliased_type,  null: false
    t.string  :name,          null: false
    t.timestamps
  end

  add_index :aliases, [:aliased_id, :aliased_type]
  add_index :aliases, :name


  create_table :companies do |t|
    t.string :name, null: false
  end

  create_table :departments do |t|
    t.string :title, null: false
  end

  create_table :projects do |t|
    t.string :name, null: false
    t.integer :company_id, null: false
    t.integer :department_id, null: false
  end
  add_index :projects, :company_id
  add_index :projects, :department_id
end

class Project < ActiveRecord::Base
  belongs_to :company
  belongs_to :department
end

class Company < ActiveRecord::Base
  has_many :projects
  acts_as_aliased associations: [:projects]
end

class Department < ActiveRecord::Base
  has_many :projects
  acts_as_aliased column: 'title', associations: [:projects]
end


def clean_database
  models = [ActsAsAliased::Alias, Project, Company, Department]
  models.each do |model|
    ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
  end
end



