require "openai"
require "httparty"
require "yaml"
# require 'discord'
# require 'slack-ruby-client'

class ProductScraper
  SOURCES = YAML.load_file(Rails.root.join("config", "sources.yml"))

  REDDIT_USER_AGENT = "ruby:com.test.buzz:v1.0.0 (by /u/sjmog)"

  # DISCORD_BOT_TOKEN = ENV['DISCORD_BOT_TOKEN']
  # SLACK_BOT_TOKEN = ENV['SLACK_BOT_TOKEN']

  def self.scrape_all
    Source.find_each do |source|
      scrape_source(source)
    end
  end

  def self.scrape_source(source)
    begin
      ScraperLogEntry.create_and_broadcast(message: "Scraping started for #{source.name} (#{source.source_type})")

      case source.source_type.to_sym
      when :reddit
        scrape_reddit(source.name)
      when :discord
        scrape_discord(source.name)
      when :slack
        scrape_slack(source.name)
      end

      source.create_and_broadcast_scraping_record({ status: :success }, "Scraping completed for #{source.name} (#{source.source_type})")
      ScraperLogEntry.create_and_broadcast(message: "Scraping completed for #{source.name} (#{source.source_type})")
    rescue => e
      source.create_and_broadcast_scraping_record({ status: :error, error_message: e.message }, e.message)
      ScraperLogEntry.create_and_broadcast(message: "Error scraping #{source.source_type} - #{source.name}: #{e.message}")
      Rails.logger.error("Error scraping #{source.source_type} - #{source.name}: #{e.message}")
    end
  end

  def self.scrape_reddit(subreddit)
    access_token = get_reddit_access_token
    url = "https://oauth.reddit.com/r/#{subreddit}/new.json"
    headers = {
      "User-Agent" => REDDIT_USER_AGENT,
      "Authorization" => "Bearer #{access_token}",
    }

    response = HTTParty.get(url, headers: headers)

    if response.code == 403
      Rails.logger.error("403 Forbidden error when accessing Reddit API: #{response.body}")
      return
    end

    return unless response.success?

    posts = JSON.parse(response.body)["data"]["children"]

    posts.each do |post|
      data = post["data"]
      product_data = extract_product_data(data)

      next unless product_data[:is_product_or_product_launch]

      tags = product_data[:tags].map do |tag|
        tag_name = tag[:name]
        Tag.find_or_create_by(name: tag_name) if tag_name.present?
      end.compact

      product = Product.find_or_create_by(url: product_data[:url]) do |p|
        p.name = product_data[:name]
        p.description = product_data[:description]
      end

      product_source = product.product_sources.find_or_create_by(url: product_data[:url]) do |p|
        p.source = "reddit"
        p.name = product_data[:name]
        p.description = product_data[:description]
        p.tags = tags
        p.meta = {
          score: data["score"],
          num_comments: data["num_comments"],
          upvotes: data["ups"],
          downvotes: data["downs"],
          author: data["author_fullname"],
          created_utc: data["created_utc"],
          subreddit: subreddit,
        }
        p.sourced_at = DateTime.now
        p.original_data = data
      end

      product.update_buzz
    end
  end

  def self.extract_product_data(post_data)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"],
                                log_errors: true)

    not_a_product_message = "Not a product post"

    # Dynamically read the content of not_products.txt
    not_products_examples = File.read("not_products.txt").strip

    # Get examples of deleted products
    deleted_products = Product.only_deleted.joins(:product_sources).where(product_sources: { source: "reddit" }).distinct.limit(20).map do |product|
      content = product.product_sources.first.original_data&.dig("selftext")
      next unless content
      "Title: #{product.name}\nContent: #{content}\nURL: #{product.url}\n"
    end.compact.join("\n")

    validated_products = Product.validated.joins(:product_sources).where(product_sources: { source: "reddit" }).distinct.limit(20).map do |product|
      content = product.product_sources.first.original_data&.dig("selftext")
      next unless content
      "Title: #{product.name}\nContent: #{content}\nURL: #{product.url}\n"
    end.compact.join("\n")

    system_prompt = <<~SYSTEM
      You are a bot that formats unstructured reddit posts into structured information about any products or projects that are being launched in this post.

      You will receive a post from Reddit and you will need to determine if it is about a product or product launch.

      Return a JSON object with the following structure:
      {
        "rationale_for_being_a_product_or_product_launch": "Explain why you believe this appears to be or does not appear to be a product or product launch post. This should be a sentence or two.",
        "is_product_or_product_launch": "True if this is a product or product launch post, false otherwise."
        "name": "Product Name",
        "description": "Brief description of the product, maximum a sentence or two.",
        "url": "Product/project URL or post URL if no specific product URL is available",
        "tags": "Array of tags or keywords related to the product. Maximum of five",
      }

      Here are some examples of things that are definitely posts about product or product launches (is_product_or_product_launch: true):
      #{validated_products}

      If the post is asking for feedback on a newly-launched product, "is_product_or_product_launch": true.
      Or, if the post is celebrating the launch of a product, "is_product_or_product_launch": true.
      Or, if the post is detailing a project and it might become a product, "is_product_or_product_launch": true.

      On the other hand, here are some examples of things that are not about products or product launches (is_product_or_product_launch: false):
      #{deleted_products}

      If the post is news about an existing startup, is_product_or_product_launch: false.
      Or, if the post is asking for ideas about where to do digital nomad work, is_product_or_product_launch: false.
    SYSTEM

    user_prompt = <<~PROMPT
      Title: #{post_data["title"]}
      Content: #{post_data["selftext"]}
      URL: #{post_data["url"]}
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt },
        ],
        temperature: 0.7,
        response_format: {
          type: "json_schema",
          json_schema: {
            name: "product_response",
            strict: true,
            schema: {
              type: "object",
              properties: {
                rationale_for_being_a_product_or_project_launch: {
                  type: "string",
                },
                is_product_or_product_launch: {
                  type: "boolean",
                },
                name: {
                  type: "string",
                },
                description: {
                  type: "string",
                },
                url: {
                  type: "string",
                },
                tags: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: {
                      name: {
                        type: "string",
                      },
                    },
                    required: ["name"],
                    additionalProperties: false,
                  },
                },
              },
              required: ["rationale_for_being_a_product_or_project_launch", "is_product_or_product_launch", "name", "description", "url", "tags"],
              additionalProperties: false,
            },
          },
        },
      },
    )

    result = response.dig("choices", 0, "message", "content")

    begin
      JSON.parse(result, symbolize_names: true)
    rescue JSON::ParserError
      nil
    end
  end

  def self.get_reddit_access_token
    url = "https://www.reddit.com/api/v1/access_token"
    response = HTTParty.post(
      url,
      basic_auth: { username: ENV["REDDIT_CLIENT_ID"], password: ENV["REDDIT_CLIENT_SECRET"] },
      headers: { "User-Agent" => REDDIT_USER_AGENT },
      body: { grant_type: "client_credentials" },
    )
    JSON.parse(response.body)["access_token"]
  end
end
