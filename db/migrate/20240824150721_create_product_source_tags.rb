class CreateProductSourceTags < ActiveRecord::Migration[7.2]
  def change
    create_table :product_source_tags do |t|
      t.references :product_source, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
