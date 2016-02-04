require 'mechanize'
require_relative '../model/giveaway'

module Parser
  class DiscussionParser
    def initialize()
      @robot = Mechanize.new
    end

    def parse(discussion_id)
      url = "http://www.steamgifts.com/discussion/#{discussion_id.gsub('*', '')}/"
      puts "--: #{url}"

      page = @robot.get url

      giveaway = Model::Giveaway.new
      giveaway.uri = url
      giveaway.title = page.title
      giveaway.not_enterable = true

      # do we have a description? If not, we don't really need to follow links
      description = page.css('.comment__display-state .markdown').first
      if !description.nil?
        giveaway.description = description.content

        description.css("a").each do |link|
          giveaway.linked_urls << URI.join(page.uri, link.attr('href'))
        end
      end

      giveaway
    end
  end
end
