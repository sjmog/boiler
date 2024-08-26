# app/jobs/scraper_job.rb
class ScraperJob < ApplicationJob
  queue_as :default

  def perform
    ScraperStatus.start
    ScraperLogEntry.create_and_broadcast(message: "Scraping started")

    Source.all.each do |source|
      ProductScraper.scrape_source(source)
    end

    ScraperLogEntry.create_and_broadcast(message: "Scraping completed")
  ensure
    ScraperStatus.complete
  end
end
