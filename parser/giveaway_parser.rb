require 'mechanize'
require_relative '../model/giveaway.rb'

module Parser
  class GiveawayParser
    def initialize
      @robot = Mechanize.new
      @count = 0
    end

    def parse(giveaway_id)
      @count += 1

      url = "http://www.steamgifts.com/giveaway/#{giveaway_id}/"
      puts "#{@count}: #{url}"

      page = @robot.get url

      giveaway = Model::Giveaway.new
      giveaway.uri = page.uri
      giveaway.title = page.title

      # do we have a description? If not, we don't really need to follow links
      description = page.css('.page__description__display-state .markdown')[0]
      if !description.nil?
        giveaway.description = description.content

        description.css("a").each do |link|
          giveaway.linked_urls << URI.join(page.uri, link.attr('href'))
        end
      end

      giveaway
    end
  end
end
