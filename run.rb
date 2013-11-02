require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'redis'
require 'watir'
require 'headless'
require 'selenium-webdriver'

require_relative 'mailer'

class Runner
  class << self
    CONFIG  = YAML.load_file("config/settings.yml")
    ISTART  = CONFIG["runner"]["start"]
    IEND    = CONFIG["runner"]["end"]
    DOMAIN  = CONFIG["runner"]["domain"]
    URL     = "#{DOMAIN}/#list/real-estate/apartments-and-rooms/1:912/2:#{ISTART}-#{IEND}/7:35/9:6037,6039,6040,4829"

    def start
      headless = Headless.new
      headless.start

      browser = Watir::Browser.new
      browser.goto URL
      page = Nokogiri::HTML(browser.html)
      browser.close
      headless.destroy
      parse_offers page
    end

    def parse_offers page
      page.css("ul#m__ads-list li").each do |offer|
        title = offer.css(".adsPage__list__title").text.strip
        href  = "#{DOMAIN}/#!/#{offer['data-id']}"
        date  = offer.css(".adsPage__list__date").text.strip
        price = offer.css(".adsPage__list__feature-price").text.strip
        check_details(title, href, date, price)
      end
    end

    def check_details title, href, date, price
      if price != "" && date.match("#{Time.now.day} ноя") && offer_is_unique(title, href, date, price)
        headless = Headless.new
        headless.start

        browser = Watir::Browser.new
        browser.goto href

        details = Nokogiri::HTML(browser.html).css("#m__ad-placeholder").to_html

        browser.close
        headless.destroy

        if details.include?("adPage__content__photos grid_18")
          Mailer.offer(CONFIG["mailer"]["from"], CONFIG["mailer"]["to"], "#{price} - #{title}", "#{details} <a href='#{href}'>Link</a>").deliver
        end
      end
    end

    def offer_is_unique title, href, date, price
      hash = Digest::MD5.hexdigest("#{title}-#{href}-#{date}-#{price}")
      redis = Redis.new(:host => "localhost", :port => 6379)
      if redis.get(hash)
        false
      else
        redis.set(hash, 1)
        true
      end
    end
  end
end

Runner.start
