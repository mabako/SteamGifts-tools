require 'launchy'
require 'set'

require_relative 'model/game'
require_relative 'model/giveaway'
require_relative 'output/giveaway_writer'
require_relative 'parser/discussion_parser'
require_relative 'parser/giveaway_parser'
require_relative 'parser/sgtools_client'

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
@giveaway_parser = Parser::GiveawayParser.new(@wishlist, @bundled_games)
if File.exist?('data/steamgifts_session_id.txt')
  @giveaway_parser.session_id = File.read('data/steamgifts_session_id.txt').chomp
end

@discussion_parser = Parser::DiscussionParser.new

if File.exist?('data/sgtools_session_id.txt')
  @sgtools_client = Parser::SGToolsClient.new File.read('data/sgtools_session_id.txt').chomp
end

@last_giveaway = nil
def fetch_giveaways(checking)
  to_check = Set.new
  checked = Set.new
  unchecked_links = Set.new

  checking.each do |giveaway_id|
    giveaway = case
    when giveaway_id.start_with?('*')
      @discussion_parser.parse(giveaway_id)
    when giveaway_id.start_with?('!')
      raise "sgtools account not configured while trying #{giveaway_id}." if @sgtools_client.nil?
      @sgtools_client.fetch_giveaway(giveaway_id)
    else
      @giveaway_parser.parse(giveaway_id)
    end

    next if giveaway.nil?

    if !giveaway.not_enterable
      checked << giveaway
      @last_giveaway = giveaway
    end
    to_check.merge giveaway.linked_giveaway_ids
    unchecked_links.merge giveaway.other_links
  end

  return checked, to_check, unchecked_links
end

giveaways_to_check = ARGV.to_set
checked_giveaways = SortedSet.new
unchecked_links = SortedSet.new
while giveaways_to_check.length > 0 do
  newly_checked_giveaways, giveaways_to_check, other_links = fetch_giveaways(giveaways_to_check)

  # keep a list so we'll be able to evaluate those giveaways later
  checked_giveaways.merge newly_checked_giveaways

  # remove all previously seen giveaways
  giveaways_to_check.subtract newly_checked_giveaways.map { |giveaway| giveaway.id }

  unchecked_links.merge other_links
end

puts '', "Found #{checked_giveaways.length} giveaways"
Launchy.open(@last_giveaway.uri) unless @last_giveaway.nil?

# generate HTML file
writer = Output::GiveawayWriter.new
writer.exists_in_account, checked_giveaways = checked_giveaways.partition { |giveaway| giveaway.exists_in_account }
writer.wishlist, checked_giveaways = checked_giveaways.partition { |giveaway| @wishlist.include? giveaway.steam_id }
writer.bundled, writer.normal = checked_giveaways.partition { |giveaway| @bundled_games.include? giveaway.steam_id }
writer.other_links = other_links

Dir.mkdir('trains') unless Dir.exist?('trains')
filename = "trains/#{ARGV.join('_').gsub('*', '').gsub('!', '')}.html"
if File.write(filename, writer.build)
  Launchy.open filename
end
