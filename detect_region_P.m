function [fgmask, bgmask] = detect_region_P(imgP)
%% Two-pass high activity region detection with adaptive thresholding
% BaDoi N. Phan, January 5th, 2017
% high activity image must be created with 
% unlabeled_caimaging_video function
% imgBW is an uint16 image counting activity

%% Detection parameters
pad = 5; % how much to pad the black border
sens = 3e-1;
Nhood = 64;
stat = 'mean';
foreground = 'dark';
se = strel('disk',3);

%% remove black border
tmp = mat2gray(imgaussfilt(imgP,3));
[~, L] = bwboundaries(tmp>mean2(tmp)); % border will have 0 activity
stats = regionprops(L>1); % border label will be 1
boundBox = round(getfield(stats,'BoundingBox'));
imgBWbounded = imgP(boundBox(2)+pad:boundBox(4)-pad,...
    boundBox(1)+pad:boundBox(3)-pad);

%% sqrt and tophat transform activity image
imgBWR = mat2gray(sqrt(imgBWbounded));
imgTH = imadjust(mat2gray(imgBWbounded)-imgaussfilt(mat2gray(imgBWbounded),30));
imgTH = imgaussfilt(imgTH,10);

%% first pass blob detection
tmp = imgTH;
inputImg = 1-tmp;

Thresh = adaptthresh(inputImg,sens,'ForegroundPolarity',foreground,...
    'Statistic',stat,'NeighborhoodSize',2*floor(size(inputImg)/Nhood)+1);
imgBW1 = imbinarize(tmp,Thresh);
% imshowpair(imgBWR, imgBW1)

%% exclude regions detected in first pass
tmp = tmp - tmp.*imgaussfilt(imdilate(mat2gray(imgBW1),strel('disk',20)),10);
tmp = mat2gray(tmp);
% imshow(tmp)

%% second pass
inputImg = 1-tmp;
Thresh = adaptthresh(inputImg,.6,'ForegroundPolarity',foreground,...
    'Statistic',stat,'NeighborhoodSize',2*floor(size(inputImg)/Nhood)+1);
imgBW2 = imbinarize(tmp,Thresh);
imshowpair(imgTH*10, imgBW1*2+imgBW2)

%% label cells
fgmask = zeros(size(imgBW));
fgmask(boundBox(2)+pad:boundBox(4)-pad, boundBox(1)+pad:boundBox(3)-pad) ...
    = bwlabel(imgBW1+imgBW2);

%% find inactive background mask
bgmask = zeros(size(imgBW));
bgmask(boundBox(2)+pad:boundBox(4)-pad,boundBox(1)+pad:boundBox(3)-pad)...
    = imopen(imgBWbounded < min(imgBWbounded(:)),se);


