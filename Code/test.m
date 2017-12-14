clc;
clear;
close all;
RawFilename = '../Data/CTS1/000000.dcm';
IMAGE = double(dicomread(RawFilename));
HEADER = dicominfo(RawFilename);
figure;imshow(IMAGE,[]);