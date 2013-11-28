require 'cross_validation'
require '../base'

data_file = '../data/VectorPlayerData.txt'

class DotaClassifier < BaseDotaClassifier

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
    return klass
  end

  #Classifier #2 multiply each teams win probability and the opposite teams lose probability. Higher prob wins
  def classify2(heroes)
    radiant_team = heroes[0..4]
    dire_team = heroes[5..9]

    rad_prob = radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    rad_prob *= dire_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[LOSSES].to_f / (record[WINS] + record[LOSSES]))
    end
    rad_prob *= (@radiant_wins.to_f / (@radiant_wins + @dire_wins))

    dire_prob = dire_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    dire_prob *= radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[LOSSES].to_f / (record[WINS] + record[LOSSES]))
    end
    dire_prob *= (@dire_wins.to_f / (@radiant_wins + @dire_wins))

    klass = 'Dire'
    klass = 'Radiant' if rad_prob > dire_prob
    #puts "Rad prob: #{rad_prob}, Dire prob: #{dire_prob}, Class: #{klass}"
    return klass
  end

  #Classifier #3 Compare probability of Win to probability of Lose for each team.
  def classify3(heroes)
    radiant_team = heroes[0..4]
    dire_team = heroes[5..9]

    rad_prob_win = radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    rad_prob_lose = radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[LOSSES].to_f / (record[WINS] + record[LOSSES]))
    end
    rad_prob_win *= (@radiant_wins.to_f / (@radiant_wins + @dire_wins))
    rad_prob_lose *= (@dire_wins.to_f / (@radiant_wins + @dire_wins))

    dire_prob_win = dire_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    dire_prob_lose = radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[LOSSES].to_f / (record[WINS] + record[LOSSES]))
    end
    dire_prob_win *= (@dire_wins.to_f / (@radiant_wins + @dire_wins))
    dire_prob_lose *= (@radiant_wins.to_f / (@radiant_wins + @dire_wins))

    rad_class = ""
    dire_class = ""
    if rad_prob_win > rad_prob_lose
      rad_class = "Radiant"
    else
      rad_class = "Dire"
    end

    if dire_prob_win > dire_prob_lose
      dire_class = "Dire"
    else
      dire_class = "Radiant"
    end

    if rad_class == dire_class
      klass = rad_class
    elsif rad_class == "Radiant" && dire_class == "Dire"
      #klass = "Dire"
    elsif rad_class == "Dire" && dire_class == "Radiant"
      #klass = "Dire"
    end

    #klass = 'Dire'
    #klass = 'Radiant' if rad_prob > dire_prob
    #puts "Rad prob: #{rad_prob}, Dire prob: #{dire_prob}, Class: #{klass}"
    return klass
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
  r.folds = 10
  #r.percentage = 0.1
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

#Classifier #4 Run unmodified naive bayes on 'standardized feature vector'
