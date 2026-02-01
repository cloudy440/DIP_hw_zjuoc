%% 实验内容 3：图像二维离散傅里叶变换与反变换
% 说明：本代码自动读取 MATLAB 内置图像 'cameraman.tif'。
% 如果需要使用自己的图片，请更改下方 filename 变量。

clear all;
close all;
clc;

% --- 1. 读取图像 ---
% 使用 MATLAB 内置的摄影师灰度图
filename = 'cameraman.tif'; 

try
    f = imread(filename);
catch
    error('找不到图片文件。请确保图片路径正确或使用 MATLAB 内置图片。');
end

% 将图像转换为 double 类型以进行数学运算
f = im2double(f);

% 如果是彩色图像，转换为灰度图
if size(f, 3) == 3
    f = rgb2gray(f);
end

% --- 2. 二维离散傅里叶变换 (DFT) ---
F = fft2(f);

% --- 3. 频谱中心化 ---
% 将零频分量从左上角移到频谱中心
Fc = fftshift(F);

% --- 4. 计算幅度谱和相位谱 ---
% 幅度谱 (使用 log(1+abs) 变换以增强视觉效果，因为低频能量非常大)
S = log(1 + abs(Fc));

% 相位谱 (直接取 angle)
P = angle(Fc);

% --- 5. 傅里叶反变换 (重建图像) ---
% 使用原始的 F (未中心化) 进行反变换
fr = ifft2(F);

% 取实部 (理论上虚部极小，但计算误差可能产生微小虚部)
fr = real(fr);

% --- 6. 绘图显示 ---
figure('Name', '实验内容3: 傅里叶变换与反变换', 'NumberTitle', 'off');

% (1) 原始图像
subplot(2, 2, 1);
imshow(f);
title('原始灰度图像');

% (2) 频谱幅度图
subplot(2, 2, 2);
imshow(S, []); % [] 表示自动缩放显示范围
title('频谱幅度图 (Log变换)');
xlabel('u (频率)'); ylabel('v (频率)');

% (3) 频谱相角图
subplot(2, 2, 3);
imshow(P, []);
title('频谱相角图');

% (4) 重建图像
subplot(2, 2, 4);
imshow(fr, []);
title('傅里叶逆变换重建图像');

disp('代码运行完毕。请保存生成的 Figure 图片。');