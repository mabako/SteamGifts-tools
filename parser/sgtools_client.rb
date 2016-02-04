require 'json'
require 'mechanize'
require_relative '../model/giveaway'

module Parser
  class SGToolsClient
    def initialize(session_id)
      @robot = Mechanize.new
      @robot.cookie_jar << Mechanize::Cookie.new(domain: 'www.sgtools.info', name: 'PHPSESSID', value: session_id, path: '/', expires: (Date.today + 365).to_s)
    end

    def fetch_giveaway(uuid)
      url = "http://www.sgtools.info/giveaways/#{uuid.gsub('!', '')}"
      puts "SGTools: #{url}"

      @robot.get "#{url}/check"
      page = @robot.get "#{url}/getLink"


      begin
        json = JSON.parse(page.content)
        found_url = json['url']
        puts found_url
        if !found_url.nil? and found_url != ''
          giveaway = Model::Giveaway.new
          giveaway.uri = url
          giveaway.title = 'SGTools'
          giveaway.fake = true
          giveaway.linked_urls << URI(found_url)
          giveaway
        else
          puts "No link for #{url}"
          nil
        end
      rescue JSON::ParserError => e
        puts "No JSON for #{url}"
        nil
      end
    end
  end
end
