class CreatesActsAsAliasedTable < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.integer :aliased_id,    null: false
      t.string  :aliased_type,  null: false
      t.string  :name,          null: false
      t.timestamps
    end

    add_index :aliases, [:aliased_id, :aliased_type]
    add_index :aliases, :name
  end
end
