clc;
clear;
close all;
%% ====================== read data ======================
RawFilename = '../Data/CTS1/000075.dcm';
InfoDataName = '../Data/InfoS1/000075.txt';
fileID = fopen(InfoDataName,'r');
WM = textscan(fileID,'%s %s','Delimiter','|');
fclose(fileID);
IMAGE = double(dicomread(RawFilename));
HEADER = dicominfo(RawFilename);

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
Level = 2;
[a,h,v,d] = haart2(IMAGE,Level);

% construct image in wavelet domain for display
Im = a;
for i = Level:-1:1
    Im = [Im h{i};v{i} d{i}];
end

%% ====================== watermark encode ======================
bin_len = 8;
code_len = 31;
pos_shift = 31;
Q = 32;
d{1} = double(watermark_encode(int64(2*Q*d{1}),Diagnosis,bin_len,pos_shift,code_len))/2/Q;
d{2} = double(watermark_encode(int64(2*Q*d{2}),PhysicianInfo,bin_len,pos_shift,code_len))/2/Q;
v{1} = double(watermark_encode(int64(2*Q*v{1}),PatientInfo,bin_len,pos_shift,code_len))/2/Q;
h{1} = double(watermark_encode(int64(2*Q*h{1}),ImageInfo,bin_len,pos_shift,code_len))/2/Q;

Im_re = ihaart2(a,h,v,d);
figure;
subplot(1,2,1);imshow(IMAGE,[]);title('original image');
subplot(1,2,2);imshow(Im_re,[]);title('watermarked image');

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
figure;
subplot(1,2,1);imshow(Im_co-Im,[]);title('differential image in wavelets domain');
subplot(1,2,2);imshow(Im_re-IMAGE,[]);title('differential image in spatial domain');
MSE = sum(sum((Im_re-IMAGE).*(Im_re-IMAGE)))/(m*n);
SNR = snr(IMAGE,IMAGE-Im_re);
PSNR = psnr(Im_re,IMAGE,max(max(IMAGE)));

%% ====================== watermark decode ======================

[a2,h2,v2,d2] = haart2(Im_re,Level);
Diagnosis_re = watermark_decode(int64(2*Q*d2{1}),bin_len,pos_shift,code_len);
PhysicianInfo_re = watermark_decode(int64(2*Q*d2{2}),bin_len,pos_shift,code_len);
PatientInfo_re = watermark_decode(int64(2*Q*v2{1}),bin_len,pos_shift,code_len);
ImageInfo_re = watermark_decode(int64(2*Q*h2{1}),bin_len,pos_shift,code_len);

%% ====================== attack testing ======================
attacktype = {'flip','gaussfilt','medfilt','modification','salt & pepper','gaussian'}; %example of using attack testing
parameter = {2, 0.2, 5, [32 0], 0.01, [0 0.01]};
AttackedImg = attack(Im_re,attacktype,parameter);
figure;
subplot(1,2,1);imshow(Im_re,[]);title('watermarked image');
subplot(1,2,2);imshow(AttackedImg{1},[]);title('watermarked image after attacking');
MSE2 = sum(sum((AttackedImg{1}-IMAGE).*(AttackedImg{1}-IMAGE)))/(m*n);
SNR2 = snr(IMAGE,IMAGE-AttackedImg{1});
PSNR2 = psnr(AttackedImg{1},IMAGE,max(max(IMAGE)));

%% ====================== watermark retrieve ======================

[a3,h3,v3,d3] = haart2(AttackedImg{1},Level);
Diagnosis_re2 = watermark_decode(int64(2*Q*d3{1}),bin_len,pos_shift,code_len);
PhysicianInfo_re2 = watermark_decode(int64(2*Q*d3{2}),bin_len,pos_shift,code_len);
PatientInfo_re2 = watermark_decode(int64(2*Q*v3{1}),bin_len,pos_shift,code_len);
ImageInfo_re2 = watermark_decode(int64(2*Q*h3{1}),bin_len,pos_shift,code_len);