function [img, fgmask, bgmask] = unlabeled_caimaging_video(filename)
%% Takes unlabeled CA imaging data and finds regions of high activity
% BaDoi N. Phan, January 5th, 2017
% depends on detect_region(activityImage) and video_stab(driftyVideo)

filename = '/users/bphan/tcf4/hc_imaging/images/GCaMP6s-TCF4het_67800-8_P14_121516_1/GCaMP6s-TCF4het_67800-8_P14_121516_1_MMStack.ome.tif';
%filename = '/Users/BaDoiPhan/Desktop/GCaMP6s-TCF4het_67800-8_P14_121516_1_MMStack.ome.tif';

%% import video
InfoImage=imfinfo(filename);
M=InfoImage(1).Height;
N=InfoImage(1).Width;
T=length(InfoImage);
%T=100;
img=zeros(M,N,T,'uint16');
for i=1:T
   img(:,:,i)=imread(filename,'Index',i,'Info',InfoImage);
end
img = mat2gray(img);

clear InfoImage

%% find number of black frames, stabilize drifty video
block = 1;
minBlackFrame = 0.1176;
while(mean2(img(:,:,block))< minBlackFrame)
    block = block+1;
end
block = block + 5;
img = video_stab(img,block); %drift stabilized image

%% Sliding window average normalization image
win = 50;
imgF0 = zeros(size(img));
for i = 1:T 
    buff  = min(600,i+win);
    imgF0(:,:,i) = mean(img(:,:,i:buff),3);
end

imgF = (img-imgF0)./imgF0; %intensity stabilized image
clear imgF0 buff win

%% Find intensity difference image
se = strel('disk',5);

imgP = zeros([M N]);
for i = block:T-1 
    tmp = mat2gray(imgF(:,:,i)-imgF(:,:,i-1));
    % tmp = imopen(tmp,se);
    tmp = wiener2(tmp,[30,30]);
    zscores = (tmp-mean2(tmp))./std(tmp(:));
    P = (normcdf(abs(zscores),0,1)-.5)/.5;
    P(P<.85) = 0; %less than 20% chance is noise
    imgP = imgP + P;
    % imshow(bw);
end

% imshow(mat2gray(imgP)*50)

[fgmask, bgmask] = detect_cell_edge(imgP);