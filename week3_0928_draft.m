clc; clear; close all;

indir = 'C:\Users\DS\Desktop\课程攻略(大三上)\DIP\3\';
fname1 = 'face00.jpg';
fname2 = 'face01.jpg';

fbase = imread([indir fname2]);
ftar = imread([indir fname1]);

fbase = rgb2gray(fbase);
ftar = rgb2gray(ftar);

figure
subplot(1,2,1);
imshow(fbase);
subplot(1,2,2);
imshow(ftar);

cpselect(ftar, fbase);
inps = cpstruct.inputPoints;
baps = cpstruct.basePoints;

tform = cp2form(inps, baps, 'affine');
Iout = imtransform(ftar, tform);

figure
subplot(1,3,1);
imshow(fbase);
subplot(1,3,2);
imshow(ftar);
subplot(1,3,3);
imshow(Iout);



















