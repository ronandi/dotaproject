require 'pp'
HERO_FILE = '../data/Heroes.txt'
HERO_ROLE_FILE = '../data/HeroesWithRoles.txt'
ROLE_FILE = '../data/Roles.txt'
DATA_FILE = '../data/VectorPlayerData.txt'
OUT_FILE = '../data/BigVectorPlayerData.txt'

role_list = []
hero_list = []
hero_keys = {}
hero_role_mapping = {}
dire_offset = 90

File.open(HERO_FILE).each do |hero|
  hero_list << hero.chomp
end
File.open(ROLE_FILE).each do |role|
  role_list << role.chomp
end
File.open(HERO_ROLE_FILE).each do |hero_role|
  hero_role = hero_role.chomp.split(',')
  hero_role_mapping[hero_role.first] = hero_role[1..-1]
end

File.open(HERO_FILE).each_with_index do |hero, index|
  hero_keys[hero.chomp] = index
end

matches = IO.read(DATA_FILE).split($/)

File.open(OUT_FILE, 'w') do |f|
  matches.each do |match|
    match_vector = Array.new(181,0)
    match = match.split(',')
    match[0..4].each do |hero|
      match_vector[hero_keys[hero]] = 1
    end
    match[5..9].each do |hero|
      match_vector[hero_keys[hero] + dire_offset] = 1
    end
    match_vector[180] = 1
    match_vector[180] = 2 if match[10] == 'Dire'
    f.puts match_vector.join(',')
  end
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
