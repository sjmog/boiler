require "spec_helper"
require "support/database_cleaner"
require "support/omniauth"
require "support/capybara"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Warden::Test::Helpers
  config.include FactoryBot::Syntax::Methods
end

# Uncomment to precompile assets befores running tests
# RSpec.configure do |config|
#   config.before :all do
#     if !ENV["ASSET_PRECOMPILE_DONE"]
#       prep_passed = system "rails test:prepare"
#       ENV["ASSET_PRECOMPILE_DONE"] = "true"
#       abort "\nYour assets didn't compile. Exiting WITHOUT running any tests. Review the output above to resolve any errors." if !prep_passed
#     end
#   end
# end
