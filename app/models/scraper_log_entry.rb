class ScraperLogEntry < ApplicationRecord
  def self.create_and_broadcast(attributes)
    log_entry = create(attributes)
    Turbo::StreamsChannel.broadcast_append_to(
      "scraper_log",
      target: "scraper_log",
      partial: "admin/dashboard/log_entry",
      locals: { log_entry: log_entry },
    )
  end
end
