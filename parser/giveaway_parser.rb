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

    def session_id= session_id
      @robot.cookie_jar << Mechanize::Cookie.new(domain: 'www.steamgifts.com', name: 'PHPSESSID', value: session_id, path: '/', expires: (Date.today + 7).to_s)
    end

    def parse(giveaway_id)
      @count += 1

      url = "http://www.steamgifts.com/giveaway/#{giveaway_id}/"
      print "#{@count}: #{url}"
      print ' '

      page = @robot.get url

      giveaway = Model::Giveaway.new
      giveaway.uri = page.uri
      giveaway.title = page.title

      # does the giveaway exist in the account? This can only ever be true if
      # a session id was set.
      giveaway.exists_in_account = !page.css('.sidebar__error.is-disabled').first.nil?
      print 'E' if giveaway.exists_in_account

      # Have we entered this giveaway? This, likewise, requires a session id.
      enterableForm = page.css('.sidebar__entry-insert').first
      giveaway.enterable = !enterableForm.attr('class').include?('is-hidden') unless enterableForm.nil?
      print 'x' if giveaway.enterable

      # If this game has an image, it's likely on Steam
      image = page.css('a.global__image-outer-wrap--game-large').first
      unless image.nil?
        giveaway.steam_id = URI.parse(image.attr('href')).path.split('/')[2].to_i

        print 'W' if @wishlist.include?(giveaway.steam_id)
        print 'B' if @bundled_games.include?(giveaway.steam_id)
      end

      # do we have a description? If not, we don't really need to follow links
      description = page.css('.page__description__display-state .markdown')[0]
      unless description.nil?
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
