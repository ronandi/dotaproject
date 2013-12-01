from __future__ import print_function
import numpy as np
from sklearn.cross_validation import train_test_split
from sklearn.grid_search import GridSearchCV
from sklearn.metrics import classification_report
from sklearn.svm import SVC

DATA_FILE = '../data/BigVectorPlayerData.txt'
DATA_SIZE = 5000

X = np.loadtxt(DATA_FILE, dtype=np.dtype(int), delimiter=',', usecols=range(180))[0:DATA_SIZE]
Y = np.loadtxt(DATA_FILE, dtype=np.dtype(int), delimiter=',', usecols=[180])[0:DATA_SIZE]

X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size = 0.5, random_state = 0)

tuned_params = [{'kernel': ['rbf'], 'gamma':[1e-10,1e-6, 1e-4, 1e-3, 1e-1, 1, 10, 100, 1000],
  'C': [1e-5, 1e-3, 1, 10, 50, 100, 1000]},
  {'kernel': ['linear'], 'C': [1e-5, 1e-3, 1, 10, 50, 100, 1000]}]

scores = ['accuracy']

for score in scores:
  print("# Tuning hyper-parameters for %s" % score)
  print()

  clf = GridSearchCV(SVC(C=1), tuned_params, cv=5, scoring = score, n_jobs=2)
  clf.fit(X_train, y_train)

  print("Best parameters set found on development set:")
  print()
  print(clf.best_estimator_)
  print("Grid scores on development set:")
  print()
  for params, mean_score, scores in clf.grid_scores_:
    print("%0.3f (+/-%0.03f) for %r"
        % (mean_score, scores.std() / 2, params))
  print()

  print("Detailed Classification Report:")
  print()
  print("The model is trained on the full development set.")
  print("The scores are computed on the full evaluation set.")
  print()
  y_true, y_pred = y_test, clf.predict(X_test)
  print(classification_report(y_true, y_pred))
  print()

