class CreateScrapingRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :scraping_records do |t|
      t.references :source, polymorphic: true, null: false
      t.integer :status, null: false, default: 0
      t.text :error_message

      t.timestamps
    end
  end
end
