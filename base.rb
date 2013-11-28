#Data/Config
HERO_LIST = []
HERO_FILE = 'data/Heroes.txt'

#Array format
WINS = 0
LOSSES = 1

class BaseDotaClassifier
  @hero_list = []
  File.open(HERO_FILE).each do |hero|
    @hero_list << hero.chomp
  end

  def self.hero_list
    @hero_list
  end

  #Initialization
  def initialize
    @count = 0
    @hero_record = {}
    @radiant_wins = 0
    @dire_wins = 0
    BaseDotaClassifier.hero_list.each do |hero|
      @hero_record[hero] = [0, 0]
    end
  end

  def train(heroes, category)
    if (category == 'Radiant')
      @radiant_wins += 1
      heroes[0..4].each do |hero|
        @hero_record[hero][WINS] += 1
      end
      heroes[5..9].each do |hero|
        @hero_record[hero][LOSSES] += 1
      end
    end
    if (category == 'Dire')
      @dire_wins += 1
      heroes[0..4].each do |hero|
        @hero_record[hero][LOSSES] += 1
      end
      heroes[5..9].each do |hero|
        @hero_record[hero][WINS] += 1
      end
    end
  end
end

