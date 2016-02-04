require 'launchy'
require 'set'

require_relative 'model/game'
require_relative 'model/giveaway'
require_relative 'output/giveaway_writer'
require_relative 'parser/giveaway_parser'

# create a data folder, unless it already exists
Dir.mkdir('data') unless Dir.exist?('data')

# initialize the wishlist to be used for game checking
if File.exist?('data/wishlist.ymlx')
  @wishlist = YAML.load_file('data/wishlist.ymlx').map { |game| game.steam_id }
else
  @wishlist = Array.new
end

# the list of bundled games
if File.exist?('data/bundled_games.yml')
  @bundled_games = YAML.load_file('data/bundled_games.yml').map { |game| game.steam_id }
else
  @bundled_games = Array.new
end

# parser for all giveaways
@parser = Parser::GiveawayParser.new(@wishlist, @bundled_games)

def fetch_giveaways(checking)
  to_check = Set.new
  checked = Set.new

  checking.each do |giveaway_id|
    giveaway = @parser.parse(giveaway_id)

    checked << giveaway
    to_check.merge giveaway.linked_giveaway_ids
  end

  return checked, to_check
end

giveaways_to_check = ARGV.to_set
checked_giveaways = SortedSet.new
while giveaways_to_check.length > 0 do
  newly_checked_giveaways, giveaways_to_check = fetch_giveaways(giveaways_to_check)

  # keep a list so we'll be able to evaluate those giveaways later
  checked_giveaways.merge newly_checked_giveaways

  # remove all previously seen giveaways
  giveaways_to_check.subtract newly_checked_giveaways.map { |giveaway| giveaway.id }
end

puts '', "Found #{checked_giveaways.length} giveaways"

# generate HTML file
writer = Output::GiveawayWriter.new
writer.wishlist, checked_giveaways = checked_giveaways.partition { |giveaway| @wishlist.include? giveaway.steam_id }
writer.bundled, writer.normal = checked_giveaways.partition { |giveaway| @bundled_games.include? giveaway.steam_id }

Dir.mkdir('trains') unless Dir.exist?('trains')
filename = "trains/#{ARGV.join('_')}.html"
if File.write(filename, writer.build)
  Launchy.open filename
end
