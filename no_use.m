%% 实验5 空间滤波
clear all; close all; clc;

%% 读入灰度图像
indir = 'C:\\Users\\Sheep\\Desktop\\chapter3_pics\\';   % 图像路径
ifname = 'Fig0326(a)(embedded_square_noisy_512).tif';   % 目标图像名
if exist(fullfile(indir, ifname),'file')
    f = imread(fullfile(indir, ifname));
else
    f = imread('cameraman.tif');  % 无目标图时用内置样例
end
if size(f,3) > 1, f = rgb2gray(f); end  % 转为灰度图
f = im2double(f);  % 转为双精度便于计算

%% ① 平滑线性滤波：均值 & 高斯（3/9/27）
ks = [3, 9, 27];  % 模板尺寸
figure('Name','① 平滑线性滤波 (Average & Gaussian)');
for i = 1:numel(ks)
    k = ks(i);
    w_avg = fspecial('average', k);  % 均值模板
    sigma = max(0.1, k/6);  % 高斯sigma经验值（k/6）
    w_gauss = fspecial('gaussian', k, sigma);  % 高斯模板

    % 线性滤波（相关操作，边缘复制填充）
    g_avg = imfilter(f, w_avg, 'corr', 'replicate');
    g_gau = imfilter(f, w_gauss, 'corr', 'replicate');

    % 打印模板（限制显示范围避免刷屏）
    fprintf('\n[Averaging %dx%d kernel]\n', k,k); disp(w_avg(1:min(k,7),1:min(k,7)));
    fprintf('[Gaussian  %dx%d kernel, sigma=%.3f]\n', k,k,sigma); disp(w_gauss(1:min(k,7),1:min(k,7)));

    % 结果显示
    subplot(3,4,(i-1)*4+1); imshow(f,[]); title(sprintf('Original (for %dx%d)',k,k));
    subplot(3,4,(i-1)*4+2); imshow(g_avg,[]); title(sprintf('Average %dx%d',k,k));
    subplot(3,4,(i-1)*4+3); imshow(g_gau,[]); title(sprintf('Gaussian %dx%d',k,k));
    subplot(3,4,(i-1)*4+4); imshowpair(g_avg,g_gau,'montage'); title('Avg vs Gau');
end

%% ② 中值滤波去椒盐噪声（3/9/27）
f_sp = imnoise(f, 'salt & pepper', 0.05);  % 添加椒盐噪声（密度0.05）
figure('Name','② 中值滤波去椒盐噪声');
% 固定显示原图和噪声图
subplot(3,3,1); imshow(f,[]); title('Original');
subplot(3,3,2); imshow(f_sp,[]); title('Salt & Pepper');
% 不同尺寸模板中值滤波
for i = 1:numel(ks)
    k = ks(i);
    g_med = medfilt2(f_sp, [k k]);  % 中值滤波
    subplot(3,3,i*3); imshow(g_med,[]); title(sprintf('Median %dx%d',k,k));
end

%% ③ 拉普拉斯算子锐化（4邻域 & 8邻域）
% 拉普拉斯模板
w4 = [0 -1 0; -1 4 -1; 0 -1 0];  % 4邻域（90°方向）
w8 = [-1 -1 -1; -1 8 -1; -1 -1 -1];  % 8邻域（含45°）

% 拉普拉斯响应计算
L4 = imfilter(f, w4, 'corr', 'replicate');
L8 = imfilter(f, w8, 'corr', 'replicate');

% 叠加锐化（原图 + 拉普拉斯响应，强度系数c=1.0）
c = 1.0;
sharp4 = mat2gray(f + c*L4);
sharp8 = mat2gray(f + c*L8);

% 打印模板
fprintf('\n[Laplacian 4-neighbor kernel]\n'); disp(w4);
fprintf('[Laplacian 8-neighbor kernel]\n'); disp(w8);

% 结果显示
figure('Name','③ 拉普拉斯：响应与叠加锐化');
subplot(2,3,1); imshow(f,[]); title('Original');
subplot(2,3,2); imshow(L4,[]); title('Laplacian (4-neigh)');
subplot(2,3,3); imshow(L8,[]); title('Laplacian (8-neigh)');
subplot(2,3,5); imshow(sharp4,[]); title('Sharpened (4-neigh)');
subplot(2,3,6); imshow(sharp8,[]); title('Sharpened (8-neigh)');

%% ④ 非锐化掩蔽与高提升滤波
wb = fspecial('gaussian', 5, 1.0);  % 模糊模板（5x5高斯，sigma=1.0）
blur = imfilter(f, wb, 'corr', 'replicate');  % 低通滤波（模糊图）
mask = f - blur;  % 细节掩蔽图（原图 - 模糊图）
unsharp = mat2gray(f + mask);  % 非锐化掩蔽（k=1）
k = 1.8;  % 高提升系数（>1）
highboost = mat2gray(f + k*mask);  % 高提升滤波

% 打印模板
fprintf('\n[Unsharp blur kernel: Gaussian 5x5, sigma=1.0]\n'); disp(wb);

% 结果显示
figure('Name','④ 非锐化掩蔽与高提升');
subplot(2,3,1); imshow(f,[]); title('Original');
subplot(2,3,2); imshow(blur,[]); title('Blur (LPF)');
subplot(2,3,3); imshow(mask,[]); title('Unsharp Mask');
subplot(2,3,5); imshow(unsharp,[]); title('Unsharp (k=1)');
subplot(2,3,6); imshow(highboost,[]); title(sprintf('High-boost (k=%.1f)',k));

%% ⑤ Sobel 梯度锐化
wx = fspecial('sobel');  % Sobel水平梯度模板
wy = wx';  % Sobel垂直梯度模板（水平模板转置）
Gx = imfilter(f, wx, 'corr', 'replicate');  % x方向梯度
Gy = imfilter(f, wy, 'corr', 'replicate');  % y方向梯度
Gmag = sqrt(Gx.^2 + Gy.^2);  % 梯度幅值
Gshow = mat2gray(Gmag);  % 幅值归一化显示

% 不同阈值二值化
BW1 = imbinarize(Gshow, 0.20);  % 阈值0.20
BW2 = imbinarize(Gshow, 0.35);  % 阈值0.35

% 结果显示
figure('Name','⑤ Sobel 梯度幅值与二值化');
subplot(2,2,1); imshow(f,[]); title('Original');
subplot(2,2,2); imshow(Gshow,[]); title('Gradient Magnitude');
subplot(2,2,3); imshow(BW1); title('Binary (T=0.20)');
subplot(2,2,4); imshow(BW2); title('Binary (T=0.35)');
