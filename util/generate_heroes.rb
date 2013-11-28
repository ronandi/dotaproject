#CSV Indicies
HERO = 3

#Config
data_file = '../data/PlayerData.txt'
outfile = '../data/Heroes.txt'

File.open(outfile, 'w') do |f|
  heroes = File.open(data_file, 'r').drop(1).map { |line| line.split(',')[HERO] }
  heroes.uniq.each { |hero| f.puts hero }
end
