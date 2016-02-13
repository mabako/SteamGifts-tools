require 'set'
require 'yaml'

require_relative 'model/game'
require_relative 'parser/bundle_list_parser'

current_page = 0
bundled_games = Set.new
parser = Parser::BundleListParser.new
loop do
  current_page += 1

  # somewhat of an indicator of progress
  if current_page % 20 == 0
    puts current_page
  else
    print '.'
  end

  # fetch all bundled games on the current page
  bundled_games.merge parser.parse(current_page)

  # either we're adding existing games, or we're at the last page
  break if current_page * 25 != bundled_games.length
end

puts '', '===', '', "Got #{current_page} pages worth of bundled games, totalling #{bundled_games.length} games"

# create a data folder, unless it already exists
Dir.mkdir('data') unless Dir.exist?('data')

# write the bundled games to YAML
File.write('data/bundled_games.yml', YAML::dump(bundled_games.to_a))
