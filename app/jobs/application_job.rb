class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked
  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError
  # Track the status of the job, see https://github.com/kenaniah/sidekiq-status
  include Sidekiq::Status::Worker

  def cancelled?
    Sidekiq.redis { |c| c.exists("cancelled-#{@provider_job_id}") == 1 } # Use c.exists? on Redis >= 4.2.0
  end

  def self.cancel(jid)
    Sidekiq.redis { |c| c.set("cancelled-#{jid}", 1, ex: 86_400) }
  end
end
