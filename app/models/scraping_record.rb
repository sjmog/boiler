class ScrapingRecord < ApplicationRecord
  belongs_to :source, polymorphic: true

  enum status: { success: 0, error: 1 }

  def self.latest
    order(created_at: :desc).first
  end
end
