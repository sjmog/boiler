class ScraperChannel < ApplicationCable::Channel
  def subscribed
    stream_from "scraper_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end