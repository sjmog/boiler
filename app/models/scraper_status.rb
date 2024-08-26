class ScraperStatus < ApplicationRecord
  def self.running?
    where(status: "running").exists?
  end

  def self.start
    create_or_find_by(id: 1).update(status: "running")
  end

  def self.complete
    find_by(id: 1)&.update(status: "completed")
  end
end
