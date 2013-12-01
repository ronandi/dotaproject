require 'pp'
HERO_FILE = '../data/Heroes.txt'
HERO_ROLE_FILE = '../data/HeroesWithRoles.txt'
ROLE_FILE = '../data/Roles.txt'
DATA_FILE = '../data/VectorPlayerData.txt'
OUT_FILE = '../data/VectorPlayerDataRolesOnly.txt'

@role_list = []
@hero_list = []
@hero_keys = {}
@hero_role_mapping = {}
dire_offset = 102

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

File.open(HERO_FILE).each_with_index do |hero, index|
  @hero_keys[hero.chomp] = index
end

matches = IO.read(DATA_FILE).split($/)

def role_counts
  role_count_hash = {}
  @role_list.each do |role|
    role_count_hash[role] = 0
  end
  return role_count_hash
end

def count_roles(heroes)
  count = lambda do |team, counter|
    team.each do |hero|
      @hero_role_mapping[hero].each do |role|
        counter[role] += 1
      end
    end
    return counter
  end
  return count.call(heroes[0..4], role_counts), count.call(heroes[5..9], role_counts)
end

File.open(OUT_FILE, 'w') do |f|
  matches.each do |match|
    match_vector = Array.new(25,0)
    match = match.split(',')

    radiant_roles, dire_roles = count_roles(match)

    radiant_roles.each_with_index do |(role,count),index|
      match_vector[index]= count
    end

    dire_roles.each_with_index do |(role, count), index|
      match_vector[12+index]= count
    end
    match_vector[24] = 1
    match_vector[24] = 2 if match[10] == 'Dire'
    f.puts match_vector.join(',')
  end
end
