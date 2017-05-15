function img = video_stab(img, block)
%% Video stabilization with SURF features and FREAK descriptors
% BaDoi N. Phan January 5th, 2017
% code adapted from Matlab 2016b documentation page
% https://www.mathworks.com/help/vision/examples/
% video-stabilization-using-point-feature-matching.html

%% SURF feature parameters to detect bright regions for tracking
numOctave = 10;
numScales = 6;
metricThresh = 250;
jump = 20;

%% Get image dimensions and movie length, make into grayscale image
[~, ~, T] = size(img);
img = mat2gray(img); 

%% detect features for first frame
tform = affine2d(eye(3)); %stationary transformation
pointsA = detectSURFFeatures(img(:,:,block),'NumOctaves', numOctave,...
    'MetricThreshold',metricThresh,'NumScaleLevels',numScales);
[featuresA, pointsA] = extractFeatures(img(:,:,block), pointsA);

while block < T-jump
    %% detect features for second frame
    pointsB = detectSURFFeatures(img(:,:,block+jump),'NumOctaves', numOctave,...
        'MetricThreshold',metricThresh,'NumScaleLevels',numScales);
    [featuresB, pointsB] = extractFeatures(img(:,:,block+jump), pointsB);
    % figure; imshow(img(:,:,block+jump)); hold on; plot(pointsB);
    
    %% Match features
    indexPairs = matchFeatures(featuresA, featuresB);
    pointsAm = pointsA(indexPairs(:, 1), :);
    pointsBm = pointsB(indexPairs(:, 2), :);
    % figure; showMatchedFeatures(img(:,:,block), img(:,:,block+jump), pointsAm, pointsBm);
    
    %% estimate similarity transformation
    try
        [tform, ~, ~] = estimateGeometricTransform(pointsBm, pointsAm, 'similarity');
        pointsA = pointsB; %old frameB is new frameA
        featuresA = featuresB;
    catch ME
        % do nothing and move onto next frame
    end
    
    %% warp image with last valid transformation estimation
    for i = 1:jump %change all frames up to jump
        img(:,:,block+i) = imwarp(img(:,:,block+i), tform,...
            'OutputView', imref2d(size(img(:,:,block+1))));
    end
    block = block + jump; %
    % figure; showMatchedFeatures(img(:,:,block), img(:,:,block+1), pointsAm, pointsBmp);
end





