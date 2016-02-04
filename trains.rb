require 'set'

require_relative 'model/giveaway'
require_relative 'parser/giveaway_parser'

@parser = Parser::GiveawayParser.new

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

puts '', '== found giveaways ==', ''
checked_giveaways.each do |giveaway|
  puts giveaway.uri
end
