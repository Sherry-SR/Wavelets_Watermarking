clc;
clear;
close all;
RawFilename = '../Data/CTS1/000075.dcm';
InfoDataName = '../Data/InfoS1/000075.txt';
fileID = fopen(InfoDataName,'r');
WM = textscan(fileID,'%s %s','Delimiter','|');
fclose(fileID);
IMAGE = double(dicomread(RawFilename));
HEADER = dicominfo(RawFilename);
figure;imshow(IMAGE,[]);title('original image');

%%%%%%%%%%%%%%%%%%%%%%%% Haar Filter %%%%%%%%%%%%%%%%%%%%%%%%
%{
p = [1 2 1]/2;
h0 = poly(-1);
f0 = deconv(p,h0);
h0 = sqrt(2)*h0/sum(h0);
f0 = sqrt(2)*f0/sum(f0);
h1 = f0.*[1 -1];
f1 = h0.*[-1 1];
%}

%%%%%%%%%%%%%%%%%%%%%%%% Info Blocks %%%%%%%%%%%%%%%%%%%%%%%%
PatientInfo_Idx = find(strcmp(WM{1},'PatientInfo'));
ImageInfo_Idx = find(strcmp(WM{1},'ImageInfo'));
Diagnosis_Idx = find(strcmp(WM{1},'Diagnosis'));
PhysicianInfo_Idx = find(strcmp(WM{1},'PhysicianInfo'));
PatientInfo = {WM{1}(PatientInfo_Idx+1:ImageInfo_Idx-1),WM{2}(PatientInfo_Idx+1:ImageInfo_Idx-1)};
ImageInfo = {WM{1}(ImageInfo_Idx+1:Diagnosis_Idx-1),WM{2}(ImageInfo_Idx+1:Diagnosis_Idx-1)};
Diagnosis = {WM{1}(Diagnosis_Idx+1:PhysicianInfo_Idx-1),WM{2}(Diagnosis_Idx+1:PhysicianInfo_Idx-1)};
PhysicianInfo = {WM{1}(PhysicianInfo_Idx+1:end),WM{2}(PhysicianInfo_Idx+1:end)};

%%%%%%%%%%%%%%%%%%%%%%%% 2D 3level DWT %%%%%%%%%%%%%%%%%%%%%%%%
Level = 3;
[a,h,v,d] = haart2(IMAGE,Level);

% construct image in wavelets domain for display
Im = a;
for i = Level:-1:1
    Im = [Im h{i};v{i} d{i}];
end

%%%%%%%%%%%%%%%%%%%%%%%% watermark encode %%%%%%%%%%%%%%%%%%%%%%%%
bin_len = 8;
pos_shift = 16;
d{1} = double(watermark_encode(int64(2*d{1}),Diagnosis,bin_len,pos_shift))/2;
d{2} = double(watermark_encode(int64(2*d{2}),PhysicianInfo,bin_len,pos_shift))/2;
v{1} = double(watermark_encode(int64(2*v{1}),PatientInfo,bin_len,pos_shift))/2;
h{1} = double(watermark_encode(int64(2*h{1}),ImageInfo,bin_len,pos_shift))/2;

Im_re = ihaart2(a,h,v,d);
figure;imshow(Im_re,[]);title('watermarking image');

%%%%%%%%%%%%%%%%%%%%%%%% evaluation %%%%%%%%%%%%%%%%%%%%%%%%

% construct image in wavelets domain for display
Im_co = a;
for i = Level:-1:1
    Im_co = [Im_co h{i};v{i} d{i}];
end
figure;imshow(Im,[]);title('original image in wavelets domain');
figure;imshow(Im_co,[]);title('watermarking image in wavelets domain');

[m,n] = size(IMAGE);
Im_re_scale = rescale(Im_re);
IMAGE_scale = rescale(IMAGE);
figure;imshow(Im_co-Im,[]);title('differential image in wavelets domain');
figure;imshow(Im_re_scale-IMAGE_scale,[]);title('differential image in spatial domain');
MSE = sum(sum((Im_re_scale-IMAGE_scale).*(Im_re_scale-IMAGE_scale)))/(m*n);
SNR = snr(IMAGE_scale,IMAGE_scale-Im_re_scale);
PSNR = psnr(Im_re_scale,IMAGE_scale);

%%%%%%%%%%%%%%%%%%%%%%%% watermark decode %%%%%%%%%%%%%%%%%%%%%%%%
bin_len2 = 8;
pos_shift2 = 16;
[a2,h2,v2,d2] = haart2(Im_re,Level);
Diagnosis_re = watermark_decode(int64(2*d2{1}),bin_len2,pos_shift2);
PhysicianInfo_re = watermark_decode(int64(2*d2{2}),bin_len2,pos_shift2);
PatientInfo_re = watermark_decode(int64(2*v2{1}),bin_len2,pos_shift2);
ImageInfo_re = watermark_decode(int64(2*h2{1}),bin_len2,pos_shift2);
