clc;clear;close all;

imdir='E:\AppCache\MATLAB\robot2026\';
ifname='pool3.jpg';

fpic=imread([imdir ifname]);
fgray=rgb2gray(fpic);

figure
subplot(1,2,1)
imshow(fpic)
subplot(1,2,2)
imshow(fgray)

figure
subplot(1,2,1)
imshow(double(fgray))
subplot(1,2,2)
imshow(im2double(fgray))


%%
% clc;clear;close all;
bval=200/255.0;
back=nan(201,201);
back(:,:)=bval;

tval=20/255.0;
pos=ceil(201/2);
back(pos-20:pos+20,pos-20:pos+20)=tval;

tratio=abs(bval-tval)./bval;

figure
imshow(back)
title(tratio)





