clear;
load testdata.mat;
load classifier.mat;
[testLabel, accuracy, probEstimate] = svmpredict(label, instance, classifier, '-b 1');
auc = roc_curve(probEstimate(:, 1)*classifier.Label(1), label);