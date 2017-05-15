function [fgmask, bgmask] = detect_region(imgBW)
%% Two-pass high activity region detection with adaptive thresholding
% BaDoi N. Phan, January 5th, 2017
% high activity image must be created with 
% unlabeled_caimaging_video function
% imgBW is an uint16 image counting activity

%% Detection parameters
pad = 5; % how much to pad the black border
sens = 1e-6;
Nhood = 4;
stat = 'mean';
foreground = 'dark';
se = strel('disk',10);

%% remove black border
stats = regionprops(imfill(imgBW>1,'holes')); % area inside border
[~,I] = max(cell2mat({stats(:).Area})); %find biggest region
boundBox =round(stats(I).BoundingBox); %bounding box of region
imgBWbounded = imgBW(boundBox(2)+pad:boundBox(4)-pad,...
    boundBox(1)+pad:boundBox(3)-pad);

%% sqrt and tophat transform activity image
imgBWR = mat2gray(sqrt(imgBWbounded));
imgTH = imadjust(mat2gray(imgBWbounded)-imgaussfilt(mat2gray(imgBWbounded),30));

%% first pass blob detection
tmp = mat2gray(imopen(imgTH,se));
inputImg = 1-tmp;

T = adaptthresh(inputImg,sens,'ForegroundPolarity',foreground,...
    'Statistic',stat,'NeighborhoodSize',2*floor(size(inputImg)/Nhood)+1);
imgBW1 = imbinarize(tmp,T);
%imshowpair(imgBWR, imgBW1)

%% exclude regions detected in first pass
tmp = tmp - tmp.*imgaussfilt(imdilate(mat2gray(imgBW1),strel('disk',20)),10);
tmp = mat2gray(tmp);
% imshow(tmp)

%% second pass
inputImg = 1-tmp;
T = adaptthresh(inputImg,sens,'ForegroundPolarity',foreground,...
    'Statistic',stat,'NeighborhoodSize',2*floor(size(inputImg)/Nhood)+1);
imgBW2 = imbinarize(tmp,T);
%imshowpair(imgBWR, imgBW1*2+imgBW2)

%% label cells
fgmask = zeros(size(imgBW));
fgmask(boundBox(2)+pad:boundBox(4)-pad, boundBox(1)+pad:boundBox(3)-pad) ...
    = bwlabel(imgBW1+imgBW2);

%% find inactive background mask
bgmask = zeros(size(imgBW));
bgmask(boundBox(2)+pad:boundBox(4)-pad,boundBox(1)+pad:boundBox(3)-pad)...
    = imopen(imgBWbounded <= min(imgBWbounded(:)),se);
