require 'pp'
HERO_FILE = '../data/Heroes.txt'
DATA_FILE = '../data/VectorPlayerData.txt'
OUT_FILE = '../data/BigVectorPlayerData.txt'

hero_keys = {}
dire_offset = 90

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
