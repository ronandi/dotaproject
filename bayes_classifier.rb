require 'cross_validation'

#Data/Config
HERO_LIST = []
HERO_FILE = 'data/Heroes.txt'
data_file = 'data/VectorPlayerData.txt'

#Array format
WINS = 0
LOSSES = 1

File.open(HERO_FILE).each do |hero|
  HERO_LIST << hero.chomp
end

class DotaClassifier

  #Initialization
  def initialize
    @count = 0
    @hero_record = {}
    @radiant_wins = 0
    @dire_wins = 0
    HERO_LIST.each do |hero|
      @hero_record[hero] = [0, 0]
    end
  end

  def start_training
    File.open(data_file).each do |data|
      data = data.chomp.split(',')
      train(data[0..9], data.last)
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

  #Classifier #1, multiply each teams win rate. The one with the higher probability wins
  def classify1(heroes)
    radiant_team = heroes[0..4]
    rad_prob = radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    rad_prob *= (@radiant_wins.to_f / (@radiant_wins + @dire_wins))

    dire_team = heroes[5..9]
    dire_prob = dire_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    dire_prob *= (@dire_wins.to_f / (@radiant_wins + @dire_wins))


    klass = 'Dire'
    klass = 'Radiant' if rad_prob > dire_prob
    #puts "Rad prob: #{rad_prob}, Dire prob: #{dire_prob}, Class: #{klass}"

    return 'Radiant' if rad_prob > dire_prob
    return 'Dire'
  end
end

def keys_for(expected, actual)
  if expected ==  "Radiant"
    actual == "Radiant" ? :tp : :fp
  elsif expected == "Dire"
    actual == "Dire" ? :tn : :fn
  end
end

runner = CrossValidation::Runner.create do |r|
  r.documents = IO.read(data_file).split($/)
  #r.folds = 10
  r.percentage = 0.1
  r.classifier = lambda {DotaClassifier.new}
  r.fetch_sample_class = lambda { |sample| sample.split(',').last }
  r.fetch_sample_value = lambda { |sample| sample.split(',')[0..9] }
  r.matrix = CrossValidation::ConfusionMatrix.new(method(:keys_for))
  r.training = lambda { |classifier, doc|
    val =  doc.split(',')[0..9]
    klass = doc.split(',').last
    classifier.train val, klass
  }
  r.classifying = lambda { |classifier, doc|
    classifier.classify1 doc
  }
end

mat = runner.run
puts "Accuracy: #{mat.accuracy}"
puts "Error: #{mat.error}"
puts "F1 Score: #{mat.f1}"
puts "Precision: #{mat.precision}"
puts "Recall: #{mat.recall}"
#Classifier #2 multiply each teams win probability and the opposite teams lose probability. Higher prob wins
#Classifier #3 Run unmodified naive bayes on 'standardized feature vector'
