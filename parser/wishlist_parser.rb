require 'mechanize'

require_relative '../model/game'

module Parser
  class WishlistParser
    def initialize(steam_id)
      @robot = Mechanize.new
      @steam_id = steam_id
    end

    def parse
      # fetch the list of bundled games
      page = @robot.get "http://steamcommunity.com/profiles/#{@steam_id}/wishlist"

      # add all bundled games on this page
      page.css('.wishlistRow').map {|row|
        game = Model::Game.new
        game.name = row.css('h4').first.content
        game.steam_id = row.attr('id').gsub('game_', '').to_i
        game
      }
    end
  end
end
