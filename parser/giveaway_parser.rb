require 'mechanize'
require_relative '../model/giveaway'

module Parser
  class GiveawayParser
    def initialize(wishlist, bundled_games)
      @robot = Mechanize.new
      @count = 0

      @wishlist = wishlist
      @bundled_games = bundled_games
    end

    def parse(giveaway_id)
      @count += 1

      url = "http://www.steamgifts.com/giveaway/#{giveaway_id}/"
      print "#{@count}: #{url}"

      page = @robot.get url

      giveaway = Model::Giveaway.new
      giveaway.uri = page.uri
      giveaway.title = page.title

      # is this a game with an id?
      image = page.css('a.global__image-outer-wrap--game-large').first
      if !image.nil?
        giveaway.steam_id = URI.parse(image.attr('href')).path.split('/')[2].to_i

        print ' '
        print 'W' if @wishlist.include?(giveaway.steam_id)
        print 'B' if @bundled_games.include?(giveaway.steam_id)
      end

      # do we have a description? If not, we don't really need to follow links
      description = page.css('.page__description__display-state .markdown')[0]
      if !description.nil?
        giveaway.description = description.content

        description.css("a").each do |link|
          giveaway.linked_urls << URI.join(page.uri, link.attr('href'))
        end
      end

      puts ''

      giveaway
    end
  end
end
