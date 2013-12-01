import numpy as np
from sklearn.naive_bayes import BernoulliNB
from sklearn import cross_validation

X = np.loadtxt('BigVectorPlayerData.txt', dtype=np.dtype(int), delimiter=',', usecols=range(180))
Y = np.loadtxt('BigVectorPlayerData.txt', dtype=np.dtype(int), delimiter=',', usecols=[180])

classifier = BernoulliNB()
scores = cross_validation.cross_val_score(classiifer, X, Y, cv=10)

print "Accuracy: %f", scores.mean()



