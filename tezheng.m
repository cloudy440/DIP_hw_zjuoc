clc; clear; close all;

% --- 实验设置 ---
image_files = {'1.bmp', '2.bmp', '3.bmp'};
file_titles = {'图1 (随机)', '图2 (近似对称)', '图3 (完全对称)'};

fprintf('正在计算空间对称性指标 (灵敏度优化版)...\n');
disp('------------------------------------------------------------------------');
fprintf('%-10s | %-15s | %-12s | %-10s\n', '文件名', '图像描述', '平均误差(px)', '对称性指标(S)');
disp('------------------------------------------------------------------------');

for k = 1:length(image_files)
    % 1. 读取与预处理
    try
        img = imread(image_files{k});
    catch
        error(['找不到文件: ' image_files{k} '，请确保图片在当前Matlab路径下。']);
    end
    
    if size(img, 3) > 1
        img = rgb2gray(img);
    end
    bw = imbinarize(img);
    
    % 2. 提取质心
    stats = regionprops(bw, 'Centroid');
    centroids = cat(1, stats.Centroid);
    
    if isempty(centroids)
        fprintf('%-10s | %-15s | %-12s | %-10s\n', image_files{k}, '无目标', 'N/A', 'N/A');
        continue;
    end
    
    % 3. 计算指标
    [score, mean_error] = calc_symmetry_measure(centroids);
    
    % 4. 输出结果
    fprintf('%-10s | %-15s | %-12.4f | %-10.4f\n', image_files{k}, file_titles{k}, mean_error, score);
    
    % 5. 可视化验证 (可选，方便查看对称中心)
    figure(k);
    imshow(img); hold on;
    plot(centroids(:,1), centroids(:,2), 'r+');
    center = mean(centroids, 1);
    plot(center(1), center(2), 'go', 'MarkerSize', 8, 'LineWidth', 2);
    title([file_titles{k} ' S=' num2str(score, '%.2f')]);
end
disp('------------------------------------------------------------------------');


% --- 核心算法函数 ---
function [score, E] = calc_symmetry_measure(points)
    % 1. 计算几何中心
    center_pt = mean(points, 1);
    
    % 2. 生成理想镜像点 (P_mirror = 2*Center - P)
    points_mirror = 2 * center_pt - points;
    
    % 3. 计算匹配误差 (Symmetry Distance)
    % 计算点集间距离矩阵
    dists_matrix = pdist2(points_mirror, points);
    
    % 找到每个镜像点距离原点集最近的距离
    min_dists = min(dists_matrix, [], 2);
    
    % E = 平均移动距离 (像素)
    E = mean(min_dists);
    
    % 4. 转换为指标 S
    % 修改：将alpha从0.1提高到1.0，增加区分度
    alpha = 1.0; 
    score = 1 / (1 + alpha * E);
end