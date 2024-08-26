class Source < ApplicationRecord
  has_many :scraping_records

  validates :name, presence: true
  validates :source_type, presence: true

  enum source_type: { reddit: 0, discord: 1, slack: 2 }

  def last_scraped_at
    scraping_records.order(created_at: :desc).first&.created_at
  end

  def status
    last_scrape = scraping_records.order(created_at: :desc).first
    return "not_scraped" if last_scrape.nil?
    return "error" if last_scrape.error?
    return "recent" if last_scrape.created_at > 24.hours.ago
    "outdated"
  end

  def create_and_broadcast_scraping_record(attributes, message)
    scraping_records.create(attributes)

    Turbo::StreamsChannel.broadcast_replace_to(
      "scraper_updates",
      target: "source_#{self.id}",
      partial: "admin/dashboard/source_row",
      locals: { source: self, message: message },
    )
  end
end
