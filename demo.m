load classifier.mat;
ratioLowToHigh = 0.4;
threshHigh = 0.8;
threshLow = ratioLowToHigh*threshHigh;
neighbor = [1 0; 1 1; 0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1];

img = imread('demo.jpg');
imHeight = size(img, 1);
imWidth = size(img, 2);
[row, col] = find(edge(rgb2gray(img), 'canny'));
testFeat = buildFeatures(img, [col, row], length(row));
testLabel = zeros(length(row), 1);
[testLabel, accuracy, probEstimate] = svmpredict(testLabel, testFeat, classifier, '-b 1');

% edge linking
probImg = zeros(imHeight, imWidth);
probImg((col-1)*imHeight+row) = probEstimate(:, 1);
% highly-probable shadow
[rowH, colH] = find(probImg>=threshHigh);
probImg((colH-1)*imHeight+rowH) = 1;
% lowly-probable shadow
[rowL, colL] = find(probImg<threshLow);
probImg((colL-1)*imHeight+rowL) = 0;
% middle-range probable shadow
[rowM, colM] = find(probImg>=threshLow & probImg<threshHigh);
midProbList = (colM-1)*imHeight+rowM;
for p = 1:length(rowH)
    eightConn = repmat([rowH(p), colH(p)], [8, 1])+neighbor;
    eightConnList = (eightConn(:, 2)-1)*imHeight+eightConn(:, 1);
    validList = intersect(eightConnList, midProbList);
    probImg(validList) = 1;
    midProbList = setdiff(midProbList, validList);
end
probImg(midProbList) = 0;

% display
[rowS, colS] = find(probImg);
img((colS-1)*imHeight+rowS) = 255;
img((colS-1)*imHeight+rowS+imHeight*imWidth) = 0;
img((colS-1)*imHeight+rowS+2*imHeight*imWidth) = 0;
imshow(img);