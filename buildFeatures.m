% Calculating features for all edge (candidate) pixels
function features = buildFeatures(img, edgePixels, featNum)

dim = 36;
features = zeros(featNum, dim);
% gradient threshold to determine edge width
thresh = 0.1;
% compute 1st feature: Gaussian filter size = 2*support+1
sigma = 1;
support = 2;
sizeFilter = 2*support+1;
maxStep = 10;

imHeight = size(img, 1)+2*maxStep;
imWidth = size(img, 2)+2*maxStep;
nChannel = size(img, 3);
img = im2double(img);
for sc = 0:2
    imgCopy = img;
    if sc ~= 0
        smoothGaussWidth = 6*sc+1;
        f = fspecial('gaussian', smoothGaussWidth, sc);
        for k = 1:nChannel
            img(:, :, k) = conv2(img(:, :, k), f, 'same');
        end
    end
    % expand image to avoid pixels out of bounds
    Gmag = zeros(imHeight, imWidth, nChannel);
    Gdir = zeros(imHeight, imWidth, nChannel);
    imgNew = zeros(imHeight, imWidth, nChannel);
    for k = 1:nChannel
        imgNew(1:imHeight, 1:imWidth, k) = padarray(img(:, :, k), [maxStep, maxStep], 'replicate');
        [Gmag(:, :, k), Gdir(:, :, k)] = imgradient(imgNew(:, :, k));
    end
    img = imgNew;
    clear imgNew;
    
    % loop through all edge pixels
    for p = 1:featNum
        pixel = edgePixels(p, :);
        x = pixel(1)+maxStep;
        y = pixel(2)+maxStep;
        
        %% color gradient direction
        gamma(1:nChannel) = Gdir(y, x, :);
        gamma = gamma*pi/180;
        % 3rd feature
        gammaDiff = min([abs(gamma-gamma([2, 3, 1])); 2*pi-abs(gamma-gamma([2, 3, 1]))]);
        
        %% illumination ratio & color gradient magnitude
        % build oriented DoG filter
        [u, v] = meshgrid(-support:support, -support:support);
        theta = pi/2-gamma;
        % leave out the constant coefficient
        DoG = zeros(sizeFilter, sizeFilter, nChannel);
        meanLeft = zeros(1, nChannel);
        meanRight = zeros(1, nChannel);
        for k = 1:nChannel
            DoG(:, :, k) = -(u.*cos(theta(k))+v.*sin(theta(k))).*exp(-(u.^2+v.^2)/(2*sigma^2));
        end
        DoG(DoG<0) = 0;
        for k = 1:nChannel
            DoG(:, :, k) = DoG(:, :, k)./sum(sum(DoG(:, :, k)));
            meanLeft(k) = sum(sum(DoG(sizeFilter:-1:1, sizeFilter:-1:1, k).*img(y-support:y+support, x-support:x+support, k)));
            % rotate 180 degrees and convolve
            meanRight(k) = sum(sum(DoG(:, :, k).*img(y-support:y+support, x-support:x+support, k)));
        end
        t = min([meanLeft; meanRight])./max([meanLeft; meanRight]);
%         disp(nChannel);
%         disp(meanLeft);
%         disp(meanRight);
        % 1st feature
        t = [sum(t)/3, t(1)/t(3), t(2)/t(3)];
        % 2nd feature
        mag(1:nChannel) = Gmag(y, x, :);
        delta = mag./max([meanLeft; meanRight]);
        
        %% edge width
        % [stepX, stepY]
        step = [cos(gamma'), sin(gamma')];
        w = zeros(1, nChannel);
        for k = 1:nChannel
            ridge = zeros(2, 2);
            for dir = 1:2
                xk = uint32(x+(-1)^dir*(1:maxStep)*step(k, 1));
                yk = uint32(y+(-1)^dir*(1:maxStep)*step(k, 2));
                ridge(dir, :) = double([xk(maxStep), yk(maxStep)]);
                idk = (xk-1)*imHeight+yk;
                id = find(Gmag(idk+(k-1)*imHeight*imWidth) < thresh*Gmag(y, x, k), 1);
                id = idk(id);
                if ~isempty(id)
                    ridge(dir, :) = double([ceil(id/imHeight), mod(id, imHeight)]);
                end
            end
            w(k) = norm(ridge(2, :)-ridge(1, :));
        end
        
        % 4th feature
        w = [sum(w)/3, w(1)/w(2), w(1)/w(3)];
        
        %%
        features(p, 12*sc+1:12*sc+3) = t;
        features(p, 12*sc+4:12*sc+6) = delta;
        features(p, 12*sc+7:12*sc+9) = gammaDiff;
        features(p, 12*sc+10:12*sc+12) = w;
    end
    img = imgCopy;
end

end