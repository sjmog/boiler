class Admin::DashboardController < ApplicationController
  layout "page"
  before_action :authenticate_user!

  def index
    @sources = Source.all
    @scraping_records = ScrapingRecord.order(created_at: :desc).limit(20)
    @log_entries = ScraperLogEntry.order(created_at: :asc)
  end

  def run_scraper
    ScraperJob.perform_later
    Turbo::StreamsChannel.broadcast_replace_to(
      "scraper_status",
      target: "scraper_status",
      partial: "admin/dashboard/scraper_status",
    )
    head :ok
  end

  def scraper_status
    render partial: "scraper_status"
  end

  private

  def scraping_status(last_scrape)
    return "not_scraped" if last_scrape.nil?
    return "error" if last_scrape.error?
    return "recent" if last_scrape.created_at > 24.hours.ago
    "outdated"
  end
end
