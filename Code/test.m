clc;
clear;
close all;
RawFilename = '../Data/CTS1/000004.dcm';
InfoDataName = '../Data/InfoS1/000004.txt';
WM = readtable(InfoDataName);
IMAGE = double(dicomread(RawFilename));
HEADER = dicominfo(RawFilename);
figure;imshow(IMAGE,[]);
[a,h,v,d] = haart2(IMAGE,4);
figure;imshow(a,[]);
%wh1 = zeros(size(h{1}));
%uint8(cell2mat(table2array(WM(find(strcmp(table2array(WM(:,1)),'Name')),2))))