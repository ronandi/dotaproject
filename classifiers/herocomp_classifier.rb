require 'cross_validation'
require './base'

data_file = '../data/VectorPlayerData.txt'

class DotaClassifier < BaseDotaClassifier

  #Classifier #1, multiply each teams win rate. The one with the higher probability wins
  def classify1(heroes)
    radiant_roles, dire_roles = count_roles(heroes)
    radiant_team = heroes[0..4]
    rad_prob = radiant_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    rad_prob *= (@radiant_wins.to_f / (@radiant_wins + @dire_wins))

    radiant_roles.each do |role, count|
      rad_prob *= (@role_record[role][:win][count].to_f / (@role_record[role][:lose][count] + @role_record[role][:win][count]))
    end

    dire_team = heroes[5..9]
    dire_prob = dire_team.inject(1) do |result, hero|
      record = @hero_record[hero]
      result *= (record[WINS].to_f / (record[WINS] + record[LOSSES]))
    end
    dire_prob *= (@dire_wins.to_f / (@radiant_wins + @dire_wins))

    dire_roles.each do |role, count|
      dire_prob *= (@role_record[role][:win][count].to_f / (@role_record[role][:lose][count] + @role_record[role][:win][count]))
    end

    klass = 'Dire'
    klass = 'Radiant' if rad_prob > dire_prob
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
