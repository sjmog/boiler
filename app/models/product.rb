class Product < ApplicationRecord
  acts_as_paranoid

  validates :name, :url, presence: true
  validates :url, uniqueness: true

  has_many :product_sources

  scope :by_buzz, -> { order(buzz: :desc) }

  has_many :tags, through: :product_sources

  scope :validated, -> { where(validated: true) }

  def validate_product!
    update(validated: true)
  end

  def update_buzz
    total_buzz = 0
    sources = product_sources

    sources.each do |source|
      source_buzz = calculate_source_buzz(source)
      total_buzz += source_buzz
    end

    # Apply a logarithmic scale to prevent extreme values
    scaled_buzz = Math.log(total_buzz + 1) * 10

    # Add a small random factor to prevent ties
    final_buzz = scaled_buzz + rand(0.1..0.9)

    update(buzz: final_buzz.round(2))
  end

  private

  def calculate_source_buzz(source)
    return 0 unless source.meta.present?

    base_score = source.meta["score"] || 0
    num_comments = source.meta["num_comments"] || 0
    upvotes = source.meta["upvotes"] || 0
    downvotes = source.meta["downvotes"] || 0

    # Calculate time decay factor
    hours_since_sourced = (Time.now - source.sourced_at) / 1.hour
    time_decay = 1.0 / (1 + hours_since_sourced / 24) # 24 hours half-life

    # Calculate controversy factor
    controversy = 1 + (upvotes + downvotes) / [base_score, 1].max

    # Calculate engagement factor
    engagement = 1 + Math.log(num_comments + 1)

    # Combine all factors
    source_buzz = (base_score * 1.5 + num_comments * 3) * time_decay * controversy * engagement

    source_buzz.round(2)
  end
end
