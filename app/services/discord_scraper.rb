# app/services/discord_scraper.rb
require 'capybara'
require 'selenium-webdriver'

class DiscordScraper
  DISCORD_SERVERS = [
    'Hack2skill', 'GCES', 'Tech Startup Community', 'Everything Startup',
    'Startup Growth Hub', 'Furlough', 'Startups and Entrepreneurship',
    'Starthub', 'Art Code', 'Million Dollar Weekend'
  ]

  def initialize
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end
    Capybara.javascript_driver = :selenium
    @session = Capybara::Session.new(:selenium)
  end

  def login
    @session.visit('https://discord.com/login')
    @session.fill_in 'email', with: ENV['DISCORD_EMAIL']
    @session.fill_in 'password', with: ENV['DISCORD_PASSWORD']
    @session.click_button 'Login'
    sleep 5 # Wait for login to complete
  end

  def scrape_servers
    DISCORD_SERVERS.each do |server|
      scrape_server(server)
    end
  end

  private

  def scrape_server(server_name)
    @session.find('.guilds-1SWlCJ').find("div[aria-label='#{server_name}']").click
    sleep 2 # Wait for server to load

    # Find channels that might contain product announcements
    channels = @session.all('.channelName-2YrOjO').select do |channel|
      ['product', 'launch', 'announcement'].any? { |keyword| channel.text.downcase.include?(keyword) }
    end

    channels.each do |channel|
      channel.click
      sleep 2 # Wait for channel to load
      scrape_messages
    end
  end

  def scrape_messages
    messages = @session.all('.message-2qnXI6')
    messages.each do |message|
      content = message.find('.contents-2MsGLg').text
      # Look for links in the message
      urls = message.all('a').map { |a| a['href'] }
      
      urls.each do |url|
        next unless url.match?(/^https?:\/\//)
        Product.find_or_create_by(url: url) do |p|
          p.name = extract_name(content)
          p.description = content
          p.buzz = calculate_buzz(message)
        end
      end
    end
  end

  def extract_name(content)
    # This is a simple implementation. You might want to use NLP for better results
    content.split("\n").first
  end

  def calculate_buzz(message)
    reactions = message.all('.reactionInner-15NvIl').sum { |r| r.text.to_i }
    replies = message.all('.repliedMessage-VokQwo').count
    reactions + (replies * 2)
  end
end