require 'csv'

#CSV Indicies
HERO = 3
RADIANT = 4
WIN = 5

#Config
data_file = 'data/PlayerData.txt'
outfile = 'data/VectorPlayerData.txt'

#Drop header line
data = File.readlines(data_file).drop(1)

match_count = data.size / 10
current = 0

File.open(outfile, 'w') do |f|
  match_count.times do
    match_str = ""
    x, y = data[current].split(',')[RADIANT..WIN]
    winner = "Radiant"
    winner = "Dire" if y == 'False'
    puts "OH NOES" if x == 'False' #Sanity check

    match = data[current..current+9]
    match.each do |line|
      line = line.split(',')
      hero = line[HERO]
      match_str = match_str << hero << ','
    end
    match_str << winner
    f.puts match_str
    current = current + 10
  end
end
