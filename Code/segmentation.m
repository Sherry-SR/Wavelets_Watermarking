clc;
clear;
close all;
RawFilename = '../Data/CTS1/000075.dcm';
IMAGE = double(dicomread(RawFilename));
%get binary image
ProImg = rescale(IMAGE);
threshold = graythresh(ProImg);
ProImg = imbinarize(ProImg,threshold);
figure;imshow(ProImg,[]);

%get lung
MaskImg = imfill(ProImg,'holes');
MaskImg = ~(ProImg|~MaskImg);
% select conneted components of 400<=area<=100000]
L = bwlabeln(MaskImg);
S = regionprops(L, 'Area');
MaskImg = ismember(L, find([S.Area] >= 800 & [S.Area] <= 100000));
%fill lung
MaskImg = imfill(MaskImg,'holes');
SE = strel('square',35);
MaskImg = imclose(MaskImg,SE);
figure;imshow(MaskImg,[]);

%get boundary
[B,L] = bwboundaries(MaskImg);
figure;imshow(IMAGE,[]);
hold on;
for i = 1:length(B)
    plot(B{i}(:,2),B{i}(:,1),'r', 'LineWidth', 1);
end
hold off;