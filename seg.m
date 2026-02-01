%% 数字图像处理实验：图像分割（完整优化版）
% 功能：
% 1. 边缘检测算子对比 (circuit.tif)
% 2. 阈值分割对比实验 (blobs.tif)，包含去噪预处理
%
% 作者：[您的姓名]
% 学号：[您的学号]
% 日期：202X年X月X日

clc; clear; close all;

%% =============================================================
%  第1题：边缘检测算子对比 (circuit.tif)
% =============================================================
disp('正在运行第1题：边缘检测...');

% 1. 读取图像
I1 = imread('circuit.tif');
% 容错处理：确保是灰度图
if size(I1,3) == 3
    I1 = rgb2gray(I1);
end

% 2. 使用五种算子进行边缘检测 (系统自动计算最佳阈值)
BW_sobel   = edge(I1, 'sobel');
BW_prewitt = edge(I1, 'prewitt');
BW_roberts = edge(I1, 'roberts');
BW_log     = edge(I1, 'log');   % LoG算子自带高斯平滑
BW_canny   = edge(I1, 'canny'); % Canny算子自带高斯平滑

% 3. 提取五种算子的共同边缘 (逻辑与运算)
BW_common = BW_sobel & BW_prewitt & BW_roberts & BW_log & BW_canny;

% 4. 显示第1题结果
% 结果图1：五种算子效果对比
figure('Name', '第1题：边缘检测算子对比', 'NumberTitle', 'off', 'Color', 'w');
subplot(2,3,1); imshow(I1);          title('原始图像');
subplot(2,3,2); imshow(BW_sobel);   title('Sobel');
subplot(2,3,3); imshow(BW_prewitt); title('Prewitt');
subplot(2,3,4); imshow(BW_roberts); title('Roberts');
subplot(2,3,5); imshow(BW_log);     title('LoG');
subplot(2,3,6); imshow(BW_canny);   title('Canny (效果最佳)');

% 结果图2：共同边缘
figure('Name', '第1题：共同边缘', 'NumberTitle', 'off', 'Color', 'w');
imshow(BW_common);
title('五种算子共同检测出的边缘');


%% =============================================================
%  第2题：阈值分割实验 (blobs.tif) - 含去噪与对比
% =============================================================
disp('正在运行第2题：阈值分割...');

% 1. 读取图像
I2_raw = imread('blobs.tif');
if size(I2_raw,3) == 3
    I2_raw = rgb2gray(I2_raw);
end

% 2. 图像预处理：去噪
% 使用 3x3 中值滤波器去除椒盐噪声，保留边缘细节
I2_denoised = medfilt2(I2_raw, [3 3]);

% 3. 方法A：按题目理论计算 (Theory)
% 题目参数：背景均值60，目标均值170 -> 理论最佳阈值 T = 115
T_theory_val = 115;
BW_theory = I2_denoised > T_theory_val; 

% 4. 方法B：按图片实际最佳阈值 (Otsu算法)
% 自动计算去噪后图像的最佳阈值
T_otsu_norm = graythresh(I2_denoised); % 返回 [0, 1]
T_otsu_val = T_otsu_norm * 255;        % 转换为 [0, 255]
BW_otsu = imbinarize(I2_denoised, T_otsu_norm);

% 5. 显示第2题结果 (含直方图双阈值对比)
figure('Name', '第2题：去噪与阈值分割对比', 'NumberTitle', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 400]);

% 子图1：去噪后的图像
subplot(1,4,1); 
imshow(I2_denoised); 
title('预处理：中值滤波去噪后');

% 子图2：灰度直方图 (基于去噪图像)
subplot(1,4,2); 
imhist(I2_denoised); 
title('灰度直方图 (去噪后)');
hold on;
% 绘制理论阈值线 (红色虚线)
line([T_theory_val T_theory_val], ylim, 'Color', 'r', 'LineWidth', 1.5, 'LineStyle', '--');
text(T_theory_val-20, max(ylim)*0.85, '理论值:115', 'Color', 'r', 'FontSize', 9, 'FontWeight', 'bold');
% 绘制Otsu阈值线 (蓝色点划线)
line([T_otsu_val T_otsu_val], ylim, 'Color', 'b', 'LineWidth', 1.5, 'LineStyle', '-.');
text(T_otsu_val+5, max(ylim)*0.7, ['自适应:' num2str(round(T_otsu_val))], 'Color', 'b', 'FontSize', 9, 'FontWeight', 'bold');
hold off;

% 子图3：理论阈值结果
subplot(1,4,3); 
imshow(BW_theory); 
title(['理论分割结果 (T=' num2str(T_theory_val) ')']);
xlabel('由于阈值偏低，目标略显粘连');

% 子图4：Otsu最佳结果
subplot(1,4,4); 
imshow(BW_otsu); 
title(['最佳分割结果 (T=' num2str(round(T_otsu_val)) ')']);
xlabel('自适应阈值，目标分离清晰');

disp('所有实验运行完成！请查看生成的图片窗口。');