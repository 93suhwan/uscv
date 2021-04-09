from matplotlib import pyplot as plt
from sklearn.metrics import roc_curve, auc, roc_auc_score
import pandas as pd
import numpy as np

f = open('./result.sh', 'r')
vuls, countermeasures = [], []
lines = f.readlines()

for line in lines:
  items = line.split(" ")
  if(items[0] == 'vul=('):
    for item in items[1:-1]:
      vuls.append(item.replace('\"', ''))
  elif(items[0] == 'countermeasure=('):
    for item in items[1:-1]:
      countermeasures.append(item.replace('\"', ''))
    break

TP = pd.read_csv("./result/data/TP.txt", delimiter='\t+', engine='python')
FP = pd.read_csv("./result/data/FP.txt", delimiter='\t+', engine='python')
FN = pd.read_csv("./result/data/FN.txt", delimiter='\t+', engine='python')
TN = pd.read_csv("./result/data/TN.txt", delimiter='\t+', engine='python')

TP = TP.apply(pd.to_numeric, errors='coerce')
FP = FP.apply(pd.to_numeric, errors='coerce')
FN = FN.apply(pd.to_numeric, errors='coerce')
TN = TN.apply(pd.to_numeric, errors='coerce')

vulTotal = TP.loc['Total'].tolist()
numTotal = FP.loc['Total'].tolist()

TP = TP.drop(['Total', TP.filter(regex='result/data', axis=0).index[0]]).values
FP = FP.drop(['Total', FP.filter(regex='result/data', axis=0).index[0]]).values
FN = FN.drop(['Total', FN.filter(regex='result/data', axis=0).index[0]]).values
TN = TN.drop(['Total', TN.filter(regex='result/data', axis=0).index[0]]).values

conditions = np.array([[0 if np.isnan(elem) else 1 for elem in row] for row in TP])
totalNum= vulTotal[0] + numTotal[0]

np.seterr(divide='ignore')
PRECISION = np.nan_to_num((TP / (TP + FP)) * 100)
RECALL = np.nan_to_num((TP / vulTotal) * 100)
ACC = np.nan_to_num(((TP + TN) / totalNum) * 100)
F1 = np.nan_to_num((2 * (RECALL * PRECISION) / (RECALL + PRECISION)))
exit()
conditions=conditions.T
TP=np.nan_to_num(TP.T)
FP=np.nan_to_num(FP.T)
FN=np.nan_to_num(FN.T)
TN=np.nan_to_num(TN.T)
F1=F1.T

N = np.arange(len(vuls))

# Except SAFE data
for i in range(len(vuls) - 1):
  fig = plt.figure(figsize=(5, 5))
  ax = fig.add_subplot(111)
  ax.bar(N, F1[i], color='b')
  plt.xticks(rotation=90, fontsize=14, fontweight='bold')
  plt.yticks(fontsize=14, fontweight='bold')
  plt.ylim([0, 100])
  plt.grid(axis='y')
  ax.set_xticks(N)
  ax.set_xticklabels(countermeasures)
  plt.tight_layout()
  plt.savefig('result/data/F1_score_' + vuls[i], dpi=600)

def one_zero(TP, FP, FN, TN):
  Y, P = [], []
  for i in range(TP):
    Y.append(1)
    P.append(1)
  for i in range(TN):
    Y.append(0)
    P.append(0)
  for i in range(FP):
    Y.append(0)
    P.append(1)
  for i in range(FN):
    Y.append(1)
    P.append(0)
  return Y, P

Y = [[] for i in range(len(vuls) - 1)]
P = [[] for i in range(len(vuls) - 1)]

for vul in range(len(vuls) - 1):
  for countermeasure in range(len(countermeasures)):
    Y_list, P_list = one_zero(int(TP[vul][countermeasure]), int(FP[vul][countermeasure]), int(FN[vul][countermeasure]), int(TN[vul][countermeasure]))
    Y[vul].append(Y_list)
    P[vul].append(P_list)

def rocvis(true, prob, label, cond):
  if not cond:
    return
  fpr, tpr, thresholds = roc_curve(true, prob)
  roc_auc = roc_auc_score(true, prob)
  plt.plot(fpr, tpr, label = label + " (AUC=" + str(round(roc_auc, 3)) + ")")

for vul in range(len(vuls) - 1):
  fig, ax = plt.subplots(figsize=(10, 10))

  for countermeasure in range(len(countermeasures)):
    rocvis(Y[vul][countermeasure], P[vul][countermeasure], countermeasures[countermeasure], conditions[vul][countermeasure])
  plt.legend(fontsize=20, loc="lower right")
  plt.xticks(fontsize=25, fontweight="bold")
  plt.yticks(fontsize=25, fontweight="bold")
  plt.xlabel("1 - Specificity", fontsize=25, fontweight="bold")
  plt.ylabel("Sensitivity", fontsize=25, fontweight="bold")
  plt.rcParams["font.weight"] = "bold"
  plt.title("ROC Curve for " + vuls[vul], fontsize=25, fontweight="bold")
  plt.savefig("result/data/Roc_curve_" + vuls[vul], dpi=600)
