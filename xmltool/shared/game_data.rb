module XMLTool
  class GameData
    @classes = %w(warrior berserker slayer archer sorcerer lancer priest elementalist soulless engineer assassin fighter glaiver)
    @races = %w(human aman castanic highelf baraka popori)

    def self.classes
      @classes
    end

    def self.races
      @races
    end
  end
end