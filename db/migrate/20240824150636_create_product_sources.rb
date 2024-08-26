class CreateProductSources < ActiveRecord::Migration[7.2]
  def change
    create_table :product_sources do |t|
      t.string :source
      t.string :name
      t.string :url
      t.text :description
      t.json :meta
      t.datetime :sourced_at

      t.references :product, null: false, foreign_key: true
      t.boolean :validated, default: false
      t.datetime :validated_at
      t.references :validated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
