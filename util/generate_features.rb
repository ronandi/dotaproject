require 'pp'
#CSV Indicies
HERO = 3

#Config
data_file = '../data/HeroesWithRoles.txt'
outfile = '../data/Features.txt'

File.open(outfile, 'w') do |f|
  features = File.open(data_file, 'r').map do |line|
    line = line.chomp.split(',')
    line[1..line.size]
  end
  features.flatten.uniq.each { |feature| f.puts feature }
end
