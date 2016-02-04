module Model
  class Game
    # app/sub id used by Steam
    attr_accessor :steam_id
    attr_accessor :name

    def == other
      steam_id == other.steam_id
    end
  end
end
