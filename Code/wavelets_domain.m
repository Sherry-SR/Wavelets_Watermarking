clc;
clear;
close all;
RawFilename = '../Data/CTS1/000004.dcm';
InfoDataName = '../Data/InfoS1/000004.txt';
WM = readtable(InfoDataName);
IMAGE = double(dicomread(RawFilename));
HEADER = dicominfo(RawFilename);
figure;imshow(IMAGE,[]);title('original image');

%%%%%%%%%%%%%%%%%%%%%%%% Haar Filter %%%%%%%%%%%%%%%%%%%%%%%%
p = [1 2 1]/2;
h0 = poly(-1);
f0 = deconv(p,h0);
h0 = sqrt(2)*h0/sum(h0);
f0 = sqrt(2)*f0/sum(f0);
h1 = f0.*[1 -1];
f1 = h0.*[-1 1];

%%%%%%%%%%%%%%%%%%%%%%%% 2D 4level DWT %%%%%%%%%%%%%%%%%%%%%%%%
Im = dwt2d(IMAGE,h0,h1,4);
figure;imshow(Im,[]);title('original image in wavelets domain');

%%%%%%%%%%%%%%%%%%%%%%%% watermark encode %%%%%%%%%%%%%%%%%%%%%%%%
bin_len = 8;
pos_shift = 16;
Im_temp = int64(2*Im(257:end,257:end));
Im_co = Im;
Im_co(257:end,257:end) = double(watermark_encode(Im_temp,WM,bin_len,pos_shift))/2;
Im_re = idwt2d(Im_co,f0,f1,4);
figure;imshow(Im_co,[]);title('watermarking image in wavelets domain');
figure;imshow(Im_re,[]);title('watermarking image');
%figure;imshow(Im_co-Im,[]);title('differential image in wavelets domain');
%figure;imshow(Im_re-IMAGE,[]);title('differential image in spatial domain');

%%%%%%%%%%%%%%%%%%%%%%%% watermark decode %%%%%%%%%%%%%%%%%%%%%%%%
bin_len2 = 8;
pos_shift2 = 16;
Im2 = dwt2d(Im_re,h0,h1,1);
information = watermark_decode(int64(2*Im_co(257:end,257:end)),bin_len2,pos_shift2);

%%%%%%%%%%%%%%%%%%%%%%%% evaluation %%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = size(IMAGE);
Im_re_scale = rescale(Im_re);
IMAGE_scale = rescale(IMAGE);
MSE = sum(sum((Im_re_scale-IMAGE_scale).*(Im_re_scale-IMAGE_scale)))/(m*n);
PSNR = psnr(Im_re_scale,IMAGE_scale);


