require 'uri'

module Model
  class Giveaway
    attr_accessor :uri, :title, :description, :linked_urls

    def initialize
      @linked_urls = Set.new
    end

    def id
      self.class.id_from_uri(uri)
    end

    # returns the ids of all linked giveaways
    def linked_giveaway_ids
      @linked_urls.select { |u| u.host == "www.steamgifts.com" and u.path.start_with?('/giveaway/') }.map { |u| self.class.id_from_uri(u) }
    end

    # compare this to another giveaway
    def <=> other
      title <=> other.title
    end

    def self.id_from_uri(uri)
      URI(uri).path.split('/')[2]
    end
  end
end
