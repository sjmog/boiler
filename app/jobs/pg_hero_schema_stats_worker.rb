class PgHeroSchemaStatsWorker < ApplicationJob
  sidekiq_options queue: :low_priority, retry: 0

  def perform
    PgHero.clean_query_stats
  end
end
