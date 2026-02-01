clear all; close all; clc;
% 初始化：设置图像路径和参数
indir = 'E:\AppCache\MATLAB\DIP\'; % 图像路径（含1.tif/2.tif）
L = 256; % 8比特图像灰度级
alpha = 2; % 指数变换参数


% 任务①：幂律变换 s = c*r^γ
f1 = imread([indir '1.tif']); f1 = im2gray(f1); % 读取偏暗图
f2 = imread([indir '2.tif']); f2 = im2gray(f2); % 读取偏亮图
c = 1;
gamma1 = 0.5; % 暗图最佳增强参数
gamma2 = 2.5; % 亮图最佳增强参数
% 归一化并计算幂律变换
f1_norm = double(f1) / 255;
f2_norm = double(f2) / 255;
g1 = c * (f1_norm).^gamma1; % 1.tif增强结果
g2 = c * (f2_norm).^gamma2; % 2.tif增强结果
g1_uint8 = uint8(g1 * 255); % 转回[0,255]
g2_uint8 = uint8(g2 * 255);
% 绘制变换曲线
r_range = linspace(0, 1, 256); % 输入灰度范围（归一化）
s_range1 = c * (r_range).^gamma1; % 1.tif变换曲线
s_range2 = c * (r_range).^gamma2; % 2.tif变换曲线
% 显示结果（原图+增强图+前后直方图）
figure('Name', '实验4-任务①-暗图（1.tif）幂律变换');
subplot(2,2,1); imshow(f1); title('1.tif原图（偏暗）');
subplot(2,2,2); imshow(g1_uint8); title(['增强图（c=1, γ=' num2str(gamma1) '）']);
subplot(2,2,3); imhist(f1); title('1.tif原图直方图'); xlim([0 255]);
subplot(2,2,4); imhist(g1_uint8); title('1.tif增强后直方图'); xlim([0 255]);
figure('Name', '实验4-任务①-亮图（2.tif）幂律变换');
subplot(2,2,1); imshow(f2); title('2.tif原图（偏亮）');
subplot(2,2,2); imshow(g2_uint8); title(['增强图（c=1, γ=' num2str(gamma2) '）']);
subplot(2,2,3); imhist(f2); title('2.tif原图直方图'); xlim([0 255]);
subplot(2,2,4); imhist(g2_uint8); title('2.tif增强后直方图'); xlim([0 255]);
figure('Name', '实验4-任务①-幂律变换曲线');
plot(r_range, s_range1, 'b-', 'LineWidth', 2); hold on;
plot(r_range, s_range2, 'r-', 'LineWidth', 2);
xlabel('输入灰度 r (归一化)'); ylabel('输出灰度 s (归一化)');
legend(['1.tif（暗图，γ=' num2str(gamma1) '）'], ['2.tif（亮图，γ=' num2str(gamma2) '）']);
grid on;


% 任务②：分段线性变换（增强+二值化）
f_enhance = imread([indir '1.tif']); % 1.tif（偏暗低对比度，用于增强）
f_binary = imread([indir '2.tif']);  % 2.tif（灰度图，用于二值化）
f_enhance = im2gray(f_enhance); % 确保单通道
f_binary = im2gray(f_binary);
% 构造分段线性变换分段点
r_enhance = [0, 50, 200, 255]; % 输入灰度分段点（增强）
s_enhance = [0, 30, 230, 255]; % 输出灰度分段点（增强）
r_binary = [0, 128, 255]; % 输入灰度分段点（二值化）
s_binary = [0, 0, 255];   % 输出灰度分段点（二值化）
% 分段线性变换函数
function s = piecewise_trans(r, r_pts, s_pts)
    s = zeros(size(r));
    for i = 1:length(r_pts)-1
        mask = (r >= r_pts(i)) & (r <= r_pts(i+1));
        s(mask) = s_pts(i) + (s_pts(i+1)-s_pts(i)) .* (r(mask) - r_pts(i)) / (r_pts(i+1)-r_pts(i));
    end
end
% 执行变换
g_enhance = uint8(piecewise_trans(double(f_enhance), r_enhance, s_enhance));
g_binary = uint8(piecewise_trans(double(f_binary), r_binary, s_binary));
% 显示结果
figure('Name', '实验4-任务②-分段线性增强（1.tif）');
subplot(2,2,1); imshow(f_enhance); title('1.tif原图（低对比度）');
subplot(2,2,2); imshow(g_enhance); title('分段线性增强图');
subplot(2,2,3); imhist(f_enhance); title('1.tif原图直方图'); xlim([0 255]);
subplot(2,2,4); imhist(g_enhance); title('1.tif增强后直方图'); xlim([0 255]);
figure('Name', '实验4-任务②-分段线性二值化（2.tif）');
subplot(2,2,1); imshow(f_binary); title('2.tif原图（灰度）');
subplot(2,2,2); imshow(g_binary); title('二值化图（阈值128）');
subplot(2,2,3); imhist(f_binary); title('2.tif原图直方图'); xlim([0 255]);
subplot(2,2,4); imhist(g_binary); title('2.tif二值化后直方图'); xlim([0 255]);
figure('Name', '实验4-任务②-分段线性变换曲线');
r_range = linspace(0, 255, 256);
s_range_enhance = piecewise_trans(r_range, r_enhance, s_enhance);
s_range_binary = piecewise_trans(r_range, r_binary, s_binary);
plot(r_range, s_range_enhance, 'b-o', 'LineWidth', 2); hold on;
plot(r_range, s_range_binary, 'r-o', 'LineWidth', 2);
xlabel('输入灰度 r'); ylabel('输出灰度 s');
legend('1.tif增强变换', '2.tif二值化变换'); grid on;


% 任务③：8比特图像比特平面分层
% 读取8比特灰度图（复用1.tif）
f = imread([indir '1.tif']); 
f = im2gray(f); % 确保为uint8单通道
% 验证原图像
disp(class(f)); % 输出"uint8"
disp([min(f(:)), max(f(:))]); % 输出"13 83"
figure; imshow(f); title('任务3原图像（1.tif）');

% 比特平面分层（用bitget按位提取）
bit_planes = zeros(size(f,1), size(f,2), 8, 'uint8'); % 存储8个比特平面
for k = 0:7
    bit_plane = bitget(f, k+1); % 提取第k+1位（MATLAB比特位从1开始计数）
    bit_planes(:,:,k+1) = uint8(bit_plane) * 255; % 0→0（黑），1→255（白）
end

% 显示比特平面结果图
figure('Name', '实验4-任务③-1.tif比特平面分层（修正按位运算）');
for k = 0:7
    subplot(2,4,k+1);
    imshow(bit_planes(:,:,k+1));
    title(['第' num2str(k) '位平面（权重2^' num2str(k) '）']);
end

% 第7位平面变换曲线
figure('Name', '实验4-任务③-第7位平面变换曲线（修正按位运算）');
r = uint8(0:255); % 8比特灰度范围
msb_bit = bitget(r, 8); % 提取第8位（对应2^7=128）
s_range = double(msb_bit) * 255; % 0→0，1→255
plot(double(r), s_range, 'b-', 'LineWidth', 2);
xlabel('输入灰度 r'); ylabel('输出灰度 s（第7位平面）');
xlim([0 255]); ylim([0 255]);
grid on;

% 第7位平面直方图
figure('Name', '实验4-任务③-第7位平面直方图（修正后）');
imhist(bit_planes(:,:,8)); % 第8个通道对应第7位平面（k=7）
title('1.tif第7位平面直方图（修正按位运算）'); 
xlim([0 255]);


% 任务④：直方图均衡化
% 复用任务①的1.tif（f1）、2.tif（f2）
% 普通直方图均衡
g1_histeq = histeq(f1, 256); % 1.tif（暗图）均衡结果
g2_histeq = histeq(f2, 256); % 2.tif（亮图）均衡结果
% 自适应直方图均衡（CLAHE）
g1_clahe = adapthisteq(f1);
g2_clahe = adapthisteq(f2);
% 计算CDF曲线
hnorm1 = imhist(f1) / numel(f1); % 归一化直方图
cdf1 = cumsum(hnorm1); % 累积分布函数
% 显示结果
figure('Name', '实验4-任务④-暗图（1.tif）直方图均衡');
subplot(2,3,1); imshow(f1); title('1.tif原图（偏暗）');
subplot(2,3,2); imshow(g1_histeq); title('普通均衡');
subplot(2,3,3); imshow(g1_clahe); title('自适应均衡');
subplot(2,3,4); imhist(f1); title('1.tif原图直方图'); xlim([0 255]);
subplot(2,3,5); imhist(g1_histeq); title('普通均衡直方图'); xlim([0 255]);
subplot(2,3,6); imhist(g1_clahe); title('自适应均衡直方图'); xlim([0 255]);
figure('Name', '实验4-任务④-1.tif均衡变换曲线');
subplot(1,2,1); plot(f1(:), g1_histeq(:), '.', 'MarkerSize', 1);
xlabel('输入灰度 f'); ylabel('输出灰度 g'); title('像素映射曲线'); xlim([0 255]); ylim([0 255]);
subplot(1,2,2); plot(linspace(0,255,256), cdf1*255, 'r-', 'LineWidth', 2);
xlabel('输入灰度 f'); ylabel('输出灰度 g'); title('CDF变换曲线'); xlim([0 255]); ylim([0 255]);
figure('Name', '实验4-任务④-亮图（2.tif）直方图均衡');
subplot(2,3,1); imshow(f2); title('2.tif原图（偏亮）');
subplot(2,3,2); imshow(g2_histeq); title('普通均衡');
subplot(2,3,3); imshow(g2_clahe); title('自适应均衡');
subplot(2,3,4); imhist(f2); title('2.tif原图直方图'); xlim([0 255]);
subplot(2,3,5); imhist(g2_histeq); title('普通均衡直方图'); xlim([0 255]);
subplot(2,3,6); imhist(g2_clahe); title('自适应均衡直方图'); xlim([0 255]);


% 任务⑤：3比特图像直方图均衡计算
L = 8; % 3比特，灰度级0~7
MN = 64*64; % 总像素数（64×64=4096）
r_levels = 0:7; % 原灰度级
n_k = [560, 920, 1040, 705, 356, 267, 170, 78]; % 原灰度级像素数
p_r = n_k / MN; % 原灰度级概率
% 计算均衡化
cdf = cumsum(p_r); % 累积分布函数
s_levels = round((L-1)*cdf); % 均衡后灰度级
% 统计新灰度级
[s_unique, ~, idx] = unique(s_levels);
n_s = accumarray(idx, n_k);
p_s = n_s / MN;
% 输出结果表格
fprintf('实验4-任务⑤ 直方图均衡计算结果\n');
fprintf('原灰度级f\t原像素数n_k\t原概率p_r\tCDF\t均衡后灰度级s\t新像素数n_s\t新概率p_s\n');
for i = 1:length(r_levels)
    fprintf('%d\t\t%d\t\t%.2f\t\t%.2f\t%d\t\t', ...
        r_levels(i), n_k(i), p_r(i), cdf(i), s_levels(i));
    s_idx = find(s_unique == s_levels(i), 1);
    if ~isempty(s_idx)
        fprintf('%d\t\t%.3f\n', n_s(s_idx), p_s(s_idx));
    else
        fprintf('0\t\t0.000\n');
    end
end
% 显示直方图
figure('Name', '实验4-任务⑤-均衡前后直方图');
subplot(1,2,1); bar(r_levels, p_r, 'b'); title('均衡前直方图'); xlabel('灰度级'); ylabel('概率');
subplot(1,2,2); bar(s_unique, p_s, 'r'); title('均衡后直方图'); xlabel('灰度级'); ylabel('概率');


% 任务⑥：单调变换
f = imread([indir '2.tif']); 
f = im2gray(f); % 确保单通道灰度图（uint8类型）
C = 30; 
L_target = 256; 
L_minus1 = L_target - 1; 
% 修正数据类型：r_min/r_max转为double
r_min = double(min(f(:)));
r_max = double(max(f(:)));
% 单调变换
if r_max == r_min 
    g = uint8(ones(size(f)) * C);
else
    g = C + (L_minus1 - C) * (double(f) - r_min) / (r_max - r_min);
    g = uint8(g);
end
% 验证结果
g_min = min(g(:));
g_max = max(g(:));
fprintf('\n实验4-任务⑥ 单调变换结果\n');
fprintf('原图像灰度范围：[%d, %d]\n', r_min, r_max);
fprintf('变换后灰度范围：[%d, %d]（目标：[%d, %d]）\n', g_min, g_max, C, L_minus1);
% 显示结果
figure('Name', '实验4-任务⑥-单调变换（2.tif）');
subplot(2,2,1); imshow(f); title('2.tif原图');
subplot(2,2,2); imshow(g); title(['变换后（最低' num2str(C) ',最高255）']);
subplot(2,2,3); imhist(f); title('2.tif原图直方图'); xlim([0 255]);
subplot(2,2,4); imhist(g); title('2.tif变换后直方图'); xlim([0 255]);
% 绘制变换曲线
figure('Name', '实验4-任务⑥-单调变换曲线');
r_range = linspace(r_min, r_max, 256);
s_range = C + (L_minus1 - C) * (r_range - r_min) / (r_max - r_min);
plot(r_range, s_range, 'b-', 'LineWidth', 2);
xlabel('输入灰度 r'); ylabel('输出灰度 s'); grid on;


% 任务⑦：基于e^(-αr²)的变换曲线构造
A = 1; B = 1;
r_range = linspace(0, 2, 1000); % r范围足够观察趋势
% 构造3种变换曲线
s_a = A * (1 - exp(-alpha * r_range.^2)); % 曲线a（0→A）
s_b = B/4 + (3*B/4) * (1 - exp(-alpha * r_range.^2)); % 曲线b（B/4→B）
s_c = A/3 + (2*A/3) * exp(-alpha * r_range.^2); % 曲线c（A→A/3）
% 显示曲线
figure('Name', '实验4-任务⑦-指数变换曲线');
subplot(1,3,1); plot(r_range, s_a, 'b-', 'LineWidth', 2);
title('曲线a（0→A）'); xlabel('r'); ylabel('s=T(r)'); grid on; ylim([0 A]);
subplot(1,3,2); plot(r_range, s_b, 'r-', 'LineWidth', 2);
title('曲线b（B/4→B）'); xlabel('r'); ylabel('s=T(r)'); grid on; ylim([0 B]);
subplot(1,3,3); plot(r_range, s_c, 'g-', 'LineWidth', 2);
title('曲线c（A→A/3）'); xlabel('r'); ylabel('s=T(r)'); grid on; ylim([0 A]);


% 任务⑧：证明两次直方图均衡结果相同
f = imread([indir '1.tif']); 
f = im2gray(f); % 确保单通道灰度图
% 两次均衡
g1 = histeq(f, 256); % 第一次均衡
g2 = histeq(g1, 256); % 第二次均衡
% 验证一致性
pixel_diff = sum(abs(double(g1(:)) - double(g2(:))));
fprintf('\n实验4-任务⑧ 两次均衡一致性验证\n');
fprintf('两次均衡后像素差异总和：%d（理论应为0，离散误差可忽略）\n', pixel_diff);
% 显示结果
figure('Name', '实验4-任务⑧-两次直方图均衡对比（1.tif）');
subplot(1,3,1); imshow(f); title('1.tif原图');
subplot(1,3,2); imshow(g1); title('第一次均衡');
subplot(1,3,3); imshow(g2); title('第二次均衡');
% 直方图对比
figure('Name', '实验4-任务⑧-两次均衡直方图对比');
subplot(1,2,1); imhist(g1); title('第一次均衡直方图'); xlim([0 255]);
subplot(1,2,2); imhist(g2); title('第二次均衡直方图'); xlim([0 255]);


% 任务⑨：连续灰度变换（匹配目标PDF）
% 定义PDF并计算CDF及逆函数
r1 = linspace(0, 0.5, 256); F_r1 = 2*r1.^2; % 0≤r≤0.5的CDF
r2 = linspace(0.5, 1, 256); F_r2 = 4*r2 - 2*r2.^2 - 1; % 0.5<r≤1的CDF
t = linspace(0, 1, 512); F_z_inv = t / 2; % 目标CDF逆函数
% 计算变换函数T(r)=F_z⁻¹(F_r(r))
T_r1 = F_z_inv(round(F_r1 * 511) + 1);
T_r2 = F_z_inv(round(F_r2 * 511) + 1);
% 显示PDF、CDF、变换曲线
figure('Name', '实验4-任务⑨-PDF、CDF与变换曲线');
subplot(2,2,1); plot([r1, r2], [4*r1, 4*(1-r2)], 'b-', 'LineWidth', 2);
title('原PDF p_r(r)'); xlabel('r'); ylabel('p_r(r)'); xlim([0 1]); ylim([0 2.5]);
subplot(2,2,2); plot([0, 0.5, 1], [0, 1, 1], 'r-', 'LineWidth', 2);
title('目标PDF p_z(z)'); xlabel('z'); ylabel('p_z(z)'); xlim([0 1]); ylim([0 2.5]);
subplot(2,2,3); plot([r1, r2], [F_r1, F_r2], 'g-', 'LineWidth', 2);
title('原CDF F_r(r)'); xlabel('r'); ylabel('F_r(r)'); xlim([0 1]); ylim([0 1]);
subplot(2,2,4); plot([r1, r2], [T_r1, T_r2], 'm-', 'LineWidth', 2);
title('变换函数 T(r)'); xlabel('r'); ylabel('z=T(r)'); xlim([0 1]); ylim([0 0.5]);
% 模拟验证
f_sim = zeros(512, 512);
for i = 1:512
    for j = 1:512
        r = rand(); % [0,1]均匀随机数
        if r <= 0.5
            f_sim(i,j) = sqrt(r/2); % 逆变换采样p_r(r)=4r
        else
            f_sim(i,j) = 1 - sqrt((1 - r)/2); % 逆变换采样p_r(r)=4(1-r)
        end
    end
end
f_sim = uint8(f_sim * 255); % 映射到[0,255]
% 应用变换T(r)
g_sim = zeros(size(f_sim));
f_double = double(f_sim) / 255; % 归一化到[0,1]
mask1 = f_double <= 0.5;
mask2 = f_double > 0.5;
g_sim(mask1) = (f_double(mask1)).^2; % T(r)=r²（0≤r≤0.5）
g_sim(mask2) = 2*f_double(mask2) - (f_double(mask2)).^2 - 0.5; % T(r)=2r-r²-0.5
g_sim = uint8(g_sim * 255); % 映射到[0,255]
% 显示模拟结果
figure('Name', '实验4-任务⑨-模拟图像变换验证');
subplot(2,2,1); imshow(f_sim); title('符合p_r的模拟图');
subplot(2,2,2); imshow(g_sim); title('变换后符合p_z的图');
subplot(2,2,3); imhist(f_sim); title('模拟图直方图（近似p_r）'); xlim([0 255]);
subplot(2,2,4); imhist(g_sim); title('变换后直方图（近似p_z）'); xlim([0 255]);