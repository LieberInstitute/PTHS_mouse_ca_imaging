function [fgmask, bgmask] = detect_cell_edge(imgP)
%% Two-pass high activity region detection with adaptive thresholding
% BaDoi N. Phan, January 5th, 2017
% high activity image must be created with 
% unlabeled_caimaging_video function
% imgBW is an uint16 image counting activity

%% remove black border
pad = 5; % how much to pad the black border
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

%% Use edge detection to find active cell regions
se = strel('disk',10);
imgEdge = edge(imgTH,'Prewitt');
imgEdge = imclose(imdilate(imgEdge,se),se);
imgEdge = imfill(imgEdge,'holes');
% imshow(imgEdge)

%% label cells
fgmask = zeros(size(imgP));
fgmask(boundBox(2)+pad:boundBox(4)-pad, boundBox(1)+pad:boundBox(3)-pad) ...
    = bwlabel(imgEdge);
% imshowpair(imgTH,imgEdge)

%% find inactive background mask
bgmask = zeros(size(imgP));
bgmask(boundBox(2)+pad:boundBox(4)-pad,boundBox(1)+pad:boundBox(3)-pad)...
    = imopen(imgBWbounded <= min(imgBWbounded(:)),se);
