require 'mechanize'

require_relative '../model/game'

module Parser
  class BundleListParser
    def initialize
      @robot = Mechanize.new
    end

    def parse(page)
      # fetch the list of bundled games
      page = @robot.get('http://www.steamgifts.com/bundle-games/search', {page: page})

      # add all bundled games on this page
      page.css('.table__rows .table__column--width-fill').map {|row|
        game = Model::Game.new
        game.name = row.css('.table__column__heading').first.content
        game.steam_id = URI.parse(row.css('a.table__column__secondary-link').first).path.split('/')[2].to_i
        game
      }
    end
  end
end
