import numpy as np
from sklearn.naive_bayes import MultinomialNB
from sklearn import cross_validation

X = np.loadtxt('../data/VectorPlayerDataRolesOnly.txt', dtype=np.dtype(int), delimiter=',', usecols=range(24))
Y = np.loadtxt('../data/VectorPlayerDataRolesOnly.txt', dtype=np.dtype(int), delimiter=',', usecols=[24])

classifier = MultinomialNB()
scores = cross_validation.cross_val_score(classifier, X, Y, cv=10)

print "Accuracy: %f" % scores.mean()



