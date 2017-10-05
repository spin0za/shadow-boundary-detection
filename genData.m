function genData(str)

files = dir(strcat(str, '*.jpg'));
instNum = length(files);
% instNum = 5;
epsilon = 2;
dim = 36;
if strcmp(str, 'train/')
    M = 30000;
    maxRowS = 300000;
    maxRowNS = 5000000;
else
    M = 10000;
    maxRowS = 100000;
    maxRowNS = 1700000;
end
shadowList = zeros(maxRowS, 4);
nonShadowList = zeros(maxRowNS, 4);

sizeS = 0;
sizeNS = 0;
for k = 1:instNum
    img = imread(strcat(str, files(k).name));
    
    % shadow features
    shadowInfo = load_xml(strcat(str, strrep(files(k).name, '.jpg', '.xml')));
    xCoords = arrayfun(@(p) str2double(p.x), shadowInfo.shadowCoords.pt);
    yCoords = arrayfun(@(p) str2double(p.y), shadowInfo.shadowCoords.pt);
    xCoords = xCoords-.5;
    yCoords = yCoords-.5;
    shadowList(sizeS+1:sizeS+length(xCoords), 1) = xCoords;
    shadowList(sizeS+1:sizeS+length(xCoords), 2) = yCoords;
    shadowList(sizeS+1:sizeS+length(xCoords), 3) = 1;
    shadowList(sizeS+1:sizeS+length(xCoords), 4) = k;
    sizeS = sizeS+length(xCoords);
    
    % non-shadow features
    [row, col] = find(edge(rgb2gray(img), 'canny'));
    edgeNum = length(row);
    % remove canny edges that are likely shadows
    rm = zeros(edgeNum, 1);
    for m = 1:edgeNum
        diff = sqrt((row(m)-yCoords).^2+(col(m)-xCoords).^2);
        if ~isempty(find(diff < epsilon, 1))
            rm(m) = m;
        end
    end
    rm = find(rm);
    row(rm) = [];
    col(rm) = [];
    nonShadowList(sizeNS+1:sizeNS+length(col), 1) = col;
    nonShadowList(sizeNS+1:sizeNS+length(col), 2) = row;
    nonShadowList(sizeNS+1:sizeNS+length(col), 3) = -1;
    nonShadowList(sizeNS+1:sizeNS+length(col), 4) = k;
    sizeNS = sizeNS+length(col);
end

sample = randperm(sizeS, M);
shadowList = shadowList(sample, :);
sample = randperm(sizeNS, M);
nonShadowList = nonShadowList(sample, :);

label = ones(2*M, 1);
instance = zeros(2*M, dim);
sizeInst = 0;
for k = 1:instNum
    kSIndices = find(shadowList(:, 4) == k);
    if isempty(kSIndices)
        continue;
    end
    kNSIndices = find(nonShadowList(:, 4) == k);
    if isempty(kNSIndices)
        continue;
    end
    img = imread(strcat(str, files(k).name));
    instance(sizeInst+1:sizeInst+length(kSIndices), :) =...
        buildFeatures(img, shadowList(kSIndices, 1:2), length(kSIndices));
    instance(sizeInst+length(kSIndices)+1:sizeInst+length(kSIndices)+length(kNSIndices), :) =...
        buildFeatures(img, nonShadowList(kNSIndices, 1:2), length(kNSIndices));
    label(sizeInst+length(kSIndices)+1:sizeInst+length(kSIndices)+length(kNSIndices)) = -1;
    sizeInst = sizeInst+length(kSIndices)+length(kNSIndices);
end

if strcmp(str, 'train/')
    save traindata.mat instance label;
else
    save testdata.mat instance label;
end

end