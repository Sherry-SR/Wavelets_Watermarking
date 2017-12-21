clc;
clear;
close all;
%% ====================== read data ======================
RawFilename = '../Data/CTS1/000075.dcm';
InfoDataName = '../Data/InfoS1/000075.txt';
fileID = fopen(InfoDataName,'r');
WM = textscan(fileID,'%s %s','Delimiter','|');
fclose(fileID);
IMAGE_RAW = double(dicomread(RawFilename));
HEADER = dicominfo(RawFilename);
IMAGE = rescale(IMAGE_RAW);

%% ====================== ROI segmentation ======================
%[B, MaskImg] = segmentation(IMAGE); %example of using segmentation

%% ====================== Haar Filter ======================
%{
p = [1 2 1]/2;
h0 = poly(-1);
f0 = deconv(p,h0);
h0 = sqrt(2)*h0/sum(h0);
f0 = sqrt(2)*f0/sum(f0);
h1 = f0.*[1 -1];
f1 = h0.*[-1 1];
%}

%% ====================== Info Blocks ======================
PatientInfo_Idx = find(strcmp(WM{1},'PatientInfo'));
ImageInfo_Idx = find(strcmp(WM{1},'ImageInfo'));
Diagnosis_Idx = find(strcmp(WM{1},'Diagnosis'));
PhysicianInfo_Idx = find(strcmp(WM{1},'PhysicianInfo'));
PatientInfo = {WM{1}(PatientInfo_Idx+1:ImageInfo_Idx-1),WM{2}(PatientInfo_Idx+1:ImageInfo_Idx-1)};
ImageInfo = {WM{1}(ImageInfo_Idx+1:Diagnosis_Idx-1),WM{2}(ImageInfo_Idx+1:Diagnosis_Idx-1)};
Diagnosis = {WM{1}(Diagnosis_Idx+1:PhysicianInfo_Idx-1),WM{2}(Diagnosis_Idx+1:PhysicianInfo_Idx-1)};
PhysicianInfo = {WM{1}(PhysicianInfo_Idx+1:end),WM{2}(PhysicianInfo_Idx+1:end)};

%% ====================== 2D 3level DWT ======================
Level = 3;
[a,h,v,d] = haart2(IMAGE,Level);

% construct image in wavelets domain for display
Im = a;
for i = Level:-1:1
    Im = [Im h{i};v{i} d{i}];
end

%% ====================== watermark encode ======================
bin_len = 8;
pos_shift = 16;
d{1} = double(watermark_encode(int64(2*255*d{1}),Diagnosis,bin_len,pos_shift))/2/255;
d{2} = double(watermark_encode(int64(2*255*d{2}),PhysicianInfo,bin_len,pos_shift))/2/255;
v{1} = double(watermark_encode(int64(2*255*v{1}),PatientInfo,bin_len,pos_shift))/2/255;
h{1} = double(watermark_encode(int64(2*255*h{1}),ImageInfo,bin_len,pos_shift))/2/255;

Im_re = ihaart2(a,h,v,d);
figure;
subplot(1,2,1);imshow(IMAGE);title('original image');
subplot(1,2,2);imshow(Im_re);title('watermarked image');

%% ====================== evaluation ======================

% construct image in wavelets domain for display
Im_co = a;
for i = Level:-1:1
    Im_co = [Im_co h{i};v{i} d{i}];
end
figure;
subplot(1,2,1);imshow(Im,[]);title('original image in wavelets domain');
subplot(1,2,2);imshow(Im_co,[]);title('watermarked image in wavelets domain');

[m,n] = size(IMAGE);
Im_re_scale = rescale(Im_re);
IMAGE = rescale(IMAGE);
figure;
subplot(1,2,1);imshow(Im_co-Im,[]);title('differential image in wavelets domain');
subplot(1,2,2);imshow(Im_re_scale-IMAGE,[]);title('differential image in spatial domain');
MSE = sum(sum((Im_re_scale-IMAGE).*(Im_re_scale-IMAGE)))/(m*n);
SNR = snr(IMAGE,IMAGE-Im_re_scale);
PSNR = psnr(Im_re_scale,IMAGE);

%% ====================== watermark decode ======================
bin_len2 = 8;
pos_shift2 = 16;
[a2,h2,v2,d2] = haart2(Im_re,Level);
Diagnosis_re = watermark_decode(int64(2*255*d2{1}),bin_len2,pos_shift2);
PhysicianInfo_re = watermark_decode(int64(2*255*d2{2}),bin_len2,pos_shift2);
PatientInfo_re = watermark_decode(int64(2*255*v2{1}),bin_len2,pos_shift2);
ImageInfo_re = watermark_decode(int64(2*255*h2{1}),bin_len2,pos_shift2);

%% ====================== attack testing ======================
attacktype = {'gaussian'}; %example of using attack testing
parameter = {[0 0.01]};
AttackedImg = attack(Im_re,attacktype,parameter);
Im_re_scale = rescale(Im_re);
AttackedImg_scale = rescale(AttackedImg{1});
figure;
subplot(1,2,1);imshow(Im_re_scale);title('watermarked image');
subplot(1,2,2);imshow(AttackedImg_scale);title('watermarked image after attacked');
MSE2 = sum(sum((AttackedImg_scale-IMAGE).*(AttackedImg_scale-IMAGE)))/(m*n);
SNR2 = snr(IMAGE,IMAGE-AttackedImg_scale);
PSNR2 = psnr(AttackedImg_scale,IMAGE);

%% ====================== watermark retrieve ======================
bin_len3 = 8;
pos_shift3 = 16;
[a3,h3,v3,d3] = haart2(AttackedImg{1},Level);
Diagnosis_re2 = watermark_decode(int64(2*255*d3{1}),bin_len3,pos_shift3);
PhysicianInfo_re2 = watermark_decode(int64(2*255*d3{2}),bin_len3,pos_shift3);
PatientInfo_re2 = watermark_decode(int64(2*255*v3{1}),bin_len3,pos_shift3);
ImageInfo_re2 = watermark_decode(int64(2*255*h3{1}),bin_len3,pos_shift3);