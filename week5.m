%% 实验5 空间滤波（尽量复用 demo 写法）
% 参考: DIP5b_demo.m 中的 imread / fspecial / imfilter / medfilt2 等用法
% 任务概览：
% ① 平滑线性滤波（均值/高斯）：模板 3x3、9x9、27x27，并给出模板矩阵
% ② 中值滤波（非线性）去椒盐噪声：模板 3x3、9x9、27x27
% ③ 拉普拉斯算子（二阶微分锐化）：4邻域(90°) 与 8邻域(45°) 两种模板；显示滤波结果与叠加锐化结果
% ④ 非锐化掩蔽与高提升滤波：给出步骤、模板图、最终效果图
% ⑤ Sobel 梯度（一阶微分）锐化：梯度幅值图 + 两个不同阈值二值图

clear all; close all; clc;

%% 读入灰度图像（复用 demo 风格：indir/ifname，兼容默认样例图）
indir = 'C:\\Users\\Sheep\\Desktop\\chapter3_pics\\';   % 按需修改
ifname = 'Fig0326(a)(embedded_square_noisy_512).tif';          % 按需修改
if exist(fullfile(indir, ifname),'file')
    f = imread(fullfile(indir, ifname));
else
    % 回退到内置样例
    f = imread('cameraman.tif');
end
if size(f,3) > 1, f = rgb2gray(f); end
f = im2double(f);

%% ① 平滑线性滤波：均值 & 高斯（3/9/27）
ks = [3, 9, 27];
figure('Name','① 平滑线性滤波 (Average & Gaussian)');
for i = 1:numel(ks)
    k = ks(i);
    % 均值模板（直接给出矩阵）
    w_avg = fspecial('average', k);
    % 高斯模板（遵循常用经验：sigma ≈ k/6）
    sigma = max(0.1, k/6);
    w_gauss = fspecial('gaussian', k, sigma);

    g_avg = imfilter(f, w_avg, 'corr', 'replicate');   % 复用 demo：'corr','replicate'
    g_gau = imfilter(f, w_gauss, 'corr', 'replicate');

    % 展示模板矩阵（命令行）
    fprintf('\n[Averaging %dx%d kernel]\n', k,k); disp(w_avg(1:min(k,7),1:min(k,7))); % 打印左上角 7x7 以免刷屏
    fprintf('[Gaussian  %dx%d kernel, sigma=%.3f]\n', k,k,sigma); disp(w_gauss(1:min(k,7),1:min(k,7)));

    % 结果展示
    subplot(3,4,(i-1)*4+1); imshow(f,[]); title(sprintf('Original (for %dx%d)',k,k));
    subplot(3,4,(i-1)*4+2); imshow(g_avg,[]); title(sprintf('Average %dx%d',k,k));
    subplot(3,4,(i-1)*4+3); imshow(g_gau,[]); title(sprintf('Gaussian %dx%d',k,k));
    subplot(3,4,(i-1)*4+4); imshowpair(g_avg,g_gau,'montage'); title('Avg vs Gau');
end

%% ② 中值滤波（非线性）去椒盐噪声：3/9/27
% 先人为加入椒盐噪声，便于对比
f_sp = imnoise(f, 'salt & pepper', 0.05);   % 噪声密度可调
figure('Name','② 中值滤波去椒盐噪声');

% 固定显示原图和带噪声图（放在第一列）
subplot(3,3,1); imshow(f,[]);    title('Original');
subplot(3,3,2); imshow(f_sp,[]); title('Salt & Pepper');

% 循环显示不同模板的中值滤波结果（每行对应一个模板）
for i = 1:numel(ks)
    k = ks(i);
    g_med = medfilt2(f_sp, [k k]);
    % 子图位置：第i行第3列（3行3列网格，索引为 i*3）
    subplot(3,3,i*3); 
    imshow(g_med,[]); 
    title(sprintf('Median %dx%d',k,k));
end

%% ③ 拉普拉斯算子锐化：4 邻域(90°各向同性) & 8 邻域(45°含对角)
% 模板（给出矩阵）
w4 = [0 -1 0; -1 4 -1; 0 -1 0];                % 常用 4 邻域拉普拉斯（90°方向）
w8 = [-1 -1 -1; -1 8 -1; -1 -1 -1];            % 常用 8 邻域拉普拉斯（含 45°）

% 拉普拉斯响应
L4 = imfilter(f, w4, 'corr', 'replicate');
L8 = imfilter(f, w8, 'corr', 'replicate');

% 叠加锐化（常见做法：f + c * Laplacian）
c = 1.0;  % 可调强度
sharp4 = mat2gray(f + c*L4);
sharp8 = mat2gray(f + c*L8);

% 打印模板矩阵
fprintf('\n[Laplacian 4-neighbor kernel]\n'); disp(w4);
fprintf('[Laplacian 8-neighbor kernel]\n'); disp(w8);

figure('Name','③ 拉普拉斯：响应与叠加锐化');
subplot(2,3,1); imshow(f,[]);   title('Original');
subplot(2,3,2); imshow(L4,[]);  title('Laplacian (4-neigh)');
subplot(2,3,3); imshow(L8,[]);  title('Laplacian (8-neigh)');
subplot(2,3,5); imshow(sharp4,[]); title('Sharpened (4-neigh)');
subplot(2,3,6); imshow(sharp8,[]); title('Sharpened (8-neigh)');

%% ④ 非锐化掩蔽 & 高提升滤波
% 步骤：1) 低通(模糊) -> 2) 掩蔽 = 原图 - 模糊 -> 3) 非锐化：原图 + 掩蔽
% 高提升：原图 + k*掩蔽 (k>1)
wb = fspecial('gaussian', 5, 1.0);           % 模糊模板（给出）
blur = imfilter(f, wb, 'corr', 'replicate');
mask = f - blur;                              % 非锐化掩蔽
unsharp = mat2gray(f + mask);                 % k=1
k = 1.8;                                      % 高提升系数（可调）
highboost = mat2gray(f + k*mask);

% 显示模板
fprintf('\n[Unsharp blur kernel: Gaussian 5x5, sigma=1.0]\n'); disp(wb);

figure('Name','④ 非锐化掩蔽与高提升');
subplot(2,3,1); imshow(f,[]);       title('Original');
subplot(2,3,2); imshow(blur,[]);    title('Blur (LPF)');
subplot(2,3,3); imshow(mask,[]);    title('Unsharp Mask');
subplot(2,3,5); imshow(unsharp,[]); title('Unsharp (k=1)');
subplot(2,3,6); imshow(highboost,[]);title(sprintf('High-boost (k=%.1f)',k));

%% ⑤ Sobel 梯度：幅值 + 两个阈值二值化
% 复用 demo 的 imfilter 写法
wx = fspecial('sobel');
wy = wx';
Gx = imfilter(f, wx, 'corr', 'replicate');
Gy = imfilter(f, wy, 'corr', 'replicate');
Gmag = sqrt(Gx.^2 + Gy.^2);
Gshow = mat2gray(Gmag);

% 两个不同阈值（相对幅值归一化后取 0.2 与 0.35，可按需调整）
BW1 = imbinarize(Gshow, 0.20);
BW2 = imbinarize(Gshow, 0.35);

figure('Name','⑤ Sobel 梯度幅值与二值化');
subplot(2,2,1); imshow(f,[]);     title('Original');
subplot(2,2,2); imshow(Gshow,[]); title('Gradient Magnitude');
subplot(2,2,3 ); imshow(BW1);      title('Binary (T=0.20)');
subplot(2,2,4); imshow(BW2);      title('Binary (T=0.35)');

%% 额外说明
% 1) 为避免显示过曝，叠加或差分后用 mat2gray() 做可视化归一化；实际处理可保留原动态范围。
% 2) 大模板(27x27)会显著平滑细节；高提升系数 k 建议 1.5~2.0 之间按视觉调节。
% 3) 若输入图像已含强噪声，可先做中值/高斯平滑，再做梯度或锐化；阈值应随图像对比度与噪声而改动。
