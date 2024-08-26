class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :url
      t.integer :buzz

      t.timestamps
    end
  end
end
