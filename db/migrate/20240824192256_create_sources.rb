class CreateSources < ActiveRecord::Migration[6.1]
  def change
    create_table :sources do |t|
      t.string :name, null: false
      t.integer :source_type, null: false

      t.timestamps
    end
    add_index :sources, [:name, :source_type], unique: true
  end
end
