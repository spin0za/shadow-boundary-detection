% clear;
epsilon = 2;
% files = dir('test/*.jpg');
% k = 34;
% img = imread(strcat('test/', files(k).name));
img = imread('demo.jpg');
img = im2double(img);
imHeight = size(img, 1);
imWidth = size(img, 2);

% [mag,dir]=imgradient(rgb2gray(img));
% % rm = find(mag < 10);
% % mag(rm) = 0;
% [X, Y] = meshgrid(1:imWidth, 1:imHeight);
% mesh(X, Y, mag);

% shadowInfo = load_xml(strcat('test/', strrep(files(k).name, '.jpg', '.xml')));
shadowInfo = load_xml('demo.xml');
xCoords = arrayfun(@(p) str2double(p.x), shadowInfo.shadowCoords.pt);
yCoords = arrayfun(@(p) str2double(p.y), shadowInfo.shadowCoords.pt);
xCoords = xCoords-.5;
yCoords = yCoords-.5;
% non-shadow features
edges = edge(rgb2gray(img), 'canny');
[row, col] = find(edges);
edgeNum = length(row);
% remove canny edges that are likely shadows
rm = zeros(edgeNum, 1);
for m = 1:edgeNum
%     diff = abs([row(m)-yCoords, col(m)-xCoords]);
    diff = sqrt((row(m)-yCoords).^2+(col(m)-xCoords).^2);
%     if ~isempty(find(diff(:, 1) < epsilon & diff(:, 2) < epsilon, 1))
    if ~isempty(find(diff < epsilon, 1))
        rm(m) = m;
    end
end
rm = find(rm);
img((xCoords-1)*imHeight+yCoords) = 255;
img((xCoords-1)*imHeight+yCoords+imHeight*imWidth) = 0;
img((xCoords-1)*imHeight+yCoords+2*imHeight*imWidth) = 0;
figure;
imshow(img);
% img((col(rm)-1)*imHeight+row(rm)) = 255;
% img((col(rm)-1)*imHeight+row(rm)+imHeight*imWidth) = 0;
% img((col(rm)-1)*imHeight+row(rm)+2*imHeight*imWidth) = 0;
% figure;
% imshow(img);
% probImg = zeros(imHeight, imWidth);
% probImg((col-1)*imHeight+row) = 1;
% figure;
% imshow(probImg);
% probImg = zeros(imHeight, imWidth);
% probImg((col(rm)-1)*imHeight+row(rm)) = 1;
% figure;
% imshow(probImg);
% probImg = zeros(imHeight, imWidth);
% probImg((xCoords-1)*imHeight+yCoords) = 1;
% figure;
% imshow(probImg);