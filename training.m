clear;
load traindata.mat;
dim = size(instance, 2);
% % normalize
% for k = 1:dim
%     instance(:, k) = mapminmax(instance(:, k));
% end
% svmtrain uses Gaussian RBF by default
classifier = svmtrain(label, instance, '-b 1');
save classifier.mat classifier;