require 'yaml'

require_relative 'parser/wishlist_parser'

# requires a steam_id.txt file in the data directory, containing a single line with your steam id (not url)
steam_id = IO.read('data/steam_id.txt').to_i

wishlist = Parser::WishlistParser.new(steam_id).parse
puts "Found #{wishlist.length} games on your wishlist"

# create a data folder, unless it already exists
Dir.mkdir('data') unless Dir.exist?('data')

# write the bundled games to YAML
File.write('data/wishlist.yml', YAML::dump(wishlist))
