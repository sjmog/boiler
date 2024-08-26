class CreateScraperStatuses < ActiveRecord::Migration[7.2]
  def change
    create_table :scraper_statuses do |t|
      t.string :status

      t.timestamps
    end
  end
end
