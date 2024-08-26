require "yaml"

namespace :sources do
  desc "Populate sources from config/sources.yml"
  task populate: :environment do
    sources = YAML.load_file(Rails.root.join("config", "sources.yml"))
    sources.each do |source_type, communities|
      communities.each do |community|
        Source.find_or_create_by!(name: community, source_type: source_type)
      end
    end
    puts "Sources populated successfully!"
  end
end
