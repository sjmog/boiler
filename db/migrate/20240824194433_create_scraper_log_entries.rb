class CreateScraperLogEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :scraper_log_entries do |t|
      t.text :message

      t.timestamps
    end
  end
end
