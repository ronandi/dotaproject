#Data/Config
HERO_LIST = []
HERO_FILE = '../data/Heroes.txt'
HERO_ROLE_FILE = '../data/HeroesWithRoles.txt'
ROLE_FILE = '../data/Roles.txt'

#Array format
WINS = 0
LOSSES = 1

class BaseDotaClassifier
  @hero_list = []
  @role_list = []
  @hero_role_mapping = {}
  File.open(HERO_FILE).each do |hero|
    @hero_list << hero.chomp
  end
  File.open(ROLE_FILE).each do |role|
    @role_list << role.chomp
  end
  File.open(HERO_ROLE_FILE).each do |hero_role|
    hero_role = hero_role.chomp.split(',')
    @hero_role_mapping[hero_role.first] = hero_role[1..-1]
  end

  def role_counts
    role_count_hash = {}
    BaseDotaClassifier.role_list.each do |role|
      role_count_hash[role] = 0
    end
    return role_count_hash
  end

  def count_roles(heroes)
    count = lambda do |team, counter|
      team.each do |hero|
        BaseDotaClassifier.hero_mapping[hero].each do |role|
          counter[role] += 1
        end
      end
      return counter
    end
    return count.call(heroes[0..4], role_counts), count.call(heroes[5..9], role_counts)
  end

  def self.hero_list
    @hero_list
  end
  def self.role_list
    @role_list
  end
  def self.hero_mapping
    @hero_role_mapping
  end

  #Initialization
  def initialize
    @count = 0
    @hero_record = {}
    @role_record = {}
    @radiant_wins = 0
    @dire_wins = 0
    BaseDotaClassifier.hero_list.each do |hero|
      @hero_record[hero] = [0, 0]
    end
    BaseDotaClassifier.role_list.each do |role|
      @role_record[role] = { win: Array.new(6,0), lose: Array.new(6,0) }
    end
  end

  def train(heroes, category)
    radiant_roles, dire_roles = count_roles(heroes)
    if (category == 'Radiant')
      radiant_roles.each { |role, count| @role_record[role][:win][count] += 1 }
      dire_roles.each { |role, count| @role_record[role][:lose][count] += 1 }
      @radiant_wins += 1
      heroes[0..4].each do |hero|
        @hero_record[hero][WINS] += 1
      end
      heroes[5..9].each do |hero|
        @hero_record[hero][LOSSES] += 1
      end
    end
    if (category == 'Dire')
      radiant_roles.each { |role, count| @role_record[role][:lose][count] += 1 }
      dire_roles.each { |role, count| @role_record[role][:win][count] += 1 }
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

