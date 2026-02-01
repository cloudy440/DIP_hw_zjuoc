clear all;
close all;
clc;

%% ========== 设置路径和读取数据文件 ==========
% 自动获取文件夹下所有数据文件
indir = 'E:\AppCache\MATLAB\DIP\SSTdata\';
fnames = dir([indir 'AQUA_MODIS*.nc']);

% 检查文件数量
if length(fnames) < 12
    error('文件数量不足12个月!');
end

% 初始化存储12个月数据的数组
mon_tol = nan(12,1);

%% ========== 读取第1个文件获取经纬度信息 ==========
i = 1;
str = fnames(i).name;
mon_tol(i) = str2num(str(16:17));

% 显示文件信息
ncdisp([indir str]);

% 读取经纬度
var = 'lon';
lon = ncread([indir str], var);
var = 'lat';
lat = ncread([indir str], var);

% 经纬度网格化
longrid = repmat(lon, 1, size(lat,1));
latgrid = repmat(lat', size(lon,1), 1);

%% ========== 任务1: 画3月份全球SST分布图并标注区域 ==========
% 找到3月份的文件
march_idx = 0;
for i = 1:length(fnames)
    str = fnames(i).name;
    month_num = str2num(str(16:17));
    if month_num == 3
        march_idx = i;
        break;
    end
end

if march_idx == 0
    error('未找到3月份数据文件!');
end

% 读取3月份SST数据
str = fnames(march_idx).name;
var = 'sst';
sst_march = ncread([indir str], var);

% 设置全球地图范围
latmin = -80;
latmax = 80;
lonmin = -180;
lonmax = 180;

% 绘制3月份全球SST分布图
figure('Position', [100, 100, 1200, 600]);
m_proj('Equidistant Cylindrical', 'long', [lonmin, lonmax], ...
       'lat', [latmin latmax]);
m_pcolor(longrid, latgrid, sst_march);
shading flat;
colorbar;
colormap(jet);
m_grid('fontsize', 10);

% 添加标题
title('3月份全球海表面温度分布', 'FontSize', 14, 'FontWeight', 'bold');

% 在全球图上标注目标区域 (28-34°N, 120-125°E)
hold on;
% 绘制红色方框
target_lon = [120 125 125 120 120];
target_lat = [28 28 34 34 28];
m_line(target_lon, target_lat, 'color', 'r', 'linewidth', 2.5, 'linestyle', '--');
m_text(122.5, 35.5, '目标区域', 'color', 'r', 'fontsize', 12, ...
       'fontweight', 'bold', 'HorizontalAlignment', 'center');
hold off;

% 保存图像
print(gcf, '-dpng', '-r200', [indir '图1_3月全球SST分布.png']);

%% ========== 任务2: 截取区域数据并读取全部12个月 ==========
% 定义目标区域
latmin_sub = 28;
latmax_sub = 34;
lonmin_sub = 120;
lonmax_sub = 125;

% 找到区域索引
ind1 = find(lon >= lonmin_sub & lon <= lonmax_sub);
ind2 = find(lat >= latmin_sub & lat <= latmax_sub);

% 截取经纬度网格
latgrid_sub = latgrid(ind1, ind2);
longrid_sub = longrid(ind1, ind2);

% 初始化存储12个月截取数据的三维数组
sst_sub_all = nan(length(ind1), length(ind2), 12);

% 读取全部12个月的数据并截取
for i = 1:length(fnames)
    str = fnames(i).name;
    month_num = str2num(str(16:17));
    
    % 读取SST数据
    var = 'sst';
    sst_temp = ncread([indir str], var);
    
    % 截取区域数据
    sst_sub_all(:, :, month_num) = sst_temp(ind1, ind2);
    
    fprintf('已读取第 %d 月数据\n', month_num);
end

% 保存截取的数据
save([indir 'sst_region_data.mat'], 'sst_sub_all', 'longrid_sub', ...
     'latgrid_sub', 'lon', 'lat', 'ind1', 'ind2');
disp('截取的区域数据已保存到 sst_region_data.mat');

%% ========== 任务2: 绘制1-12月份截取区域SST分布图 ==========
month_names = {'1月', '2月', '3月', '4月', '5月', '6月', ...
               '7月', '8月', '9月', '10月', '11月', '12月'};

figure('Position', [100, 100, 1600, 1200]);

for i = 1:12
    subplot(3, 4, i);
    
    % 提取当月数据
    sst_sub = sst_sub_all(:, :, i);
    
    % 设置地图投影
    m_proj('Equidistant Cylindrical', 'long', [lonmin_sub, lonmax_sub], ...
           'lat', [latmin_sub latmax_sub]);
    
    % 绘制SST数据
    m_pcolor(longrid_sub, latgrid_sub, sst_sub);
    shading flat;
    colormap(jet);
    
    % 添加colorbar (只在每行最后一个子图显示)
    if mod(i, 4) == 0
        colorbar('eastoutside');
    end
    
    % 添加网格
    m_grid('fontsize', 8);
    
    % 添加岸线
    m_gshhs_i('patch', [0.7 0.7 0.7], 'edgecolor', 'k');
    
    % 标题显示月份
    title(month_names{i}, 'FontSize', 12, 'FontWeight', 'bold');
end

% 添加总标题
sgtitle('1-12月份区域海表面温度分布 (28-34°N, 120-125°E)', ...
        'FontSize', 16, 'FontWeight', 'bold');

% 保存图像
print(gcf, '-dpng', '-r200', [indir '图2_1-12月区域SST分布.png']);

%% ========== 任务3: 计算月平均值和标准偏差 ==========
monthly_mean = nan(12, 1);
monthly_std = nan(12, 1);

for i = 1:12
    sst_month = sst_sub_all(:, :, i);
    % 计算空间平均(去除NaN值)
    valid_data = sst_month(~isnan(sst_month));
    monthly_mean(i) = mean(valid_data);
    monthly_std(i) = std(valid_data);
end

%% 创建结果表格并保存
months = (1:12)';
results_table = table(months, monthly_mean, monthly_std, ...
    'VariableNames', {'月份', '均值_摄氏度', '标准偏差_摄氏度'});

% 在命令窗口显示表格
disp('======================================');
disp('月平均海表面温度统计结果');
disp('区域: 28-34°N, 120-125°E');
disp('======================================');
disp(results_table);

% 保存表格为txt文件
fid = fopen([indir '月平均SST统计结果.txt'], 'w');
fprintf(fid, '======================================\n');
fprintf(fid, '月平均海表面温度统计结果\n');
fprintf(fid, '区域: 28-34°N, 120-125°E\n');
fprintf(fid, '======================================\n');
fprintf(fid, '月份\t均值(°C)\t标准偏差(°C)\n');
for i = 1:12
    fprintf(fid, '%d\t%.4f\t%.4f\n', i, monthly_mean(i), monthly_std(i));
end
fclose(fid);
disp(['统计结果已保存到: ' indir '月平均SST统计结果.txt']);

%% ========== 任务3: 绘制均值随月份变化曲线(带误差棒) ==========
figure('Position', [100, 100, 900, 550]);

% 绘制误差棒图
errorbar(months, monthly_mean, monthly_std, '-o', ...
         'LineWidth', 2.5, ...
         'MarkerSize', 10, ...
         'MarkerFaceColor', [0.2 0.5 0.8], ...
         'MarkerEdgeColor', [0.1 0.3 0.6], ...
         'Color', [0.2 0.5 0.8], ...
         'CapSize', 12);

% 设置坐标轴标签
xlabel('月份', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('海表面温度 (°C)', 'FontSize', 13, 'FontWeight', 'bold');
title('区域月平均海表面温度年变化 (28-34°N, 120-125°E)', ...
      'FontSize', 14, 'FontWeight', 'bold');

% 设置网格
grid on;
grid minor;
box on;

% 设置x轴刻度
xticks(1:12);
xticklabels(month_names);
xtickangle(45);

% 设置y轴范围
y_min = min(monthly_mean - monthly_std) - 1;
y_max = max(monthly_mean + monthly_std) + 1;
ylim([y_min y_max]);

% 添加图例
legend('月平均值 ± 标准偏差', 'Location', 'best', 'FontSize', 11);

% 美化图形
set(gca, 'FontSize', 11, 'LineWidth', 1.5);

% 保存图像
print(gcf, '-dpng', '-r200', [indir '图3_月平均SST年变化.png']);

%% ========== 保存所有工作空间变量 ==========
save([indir 'experiment_results.mat']);

%% 输出完成信息
disp(' ');
disp('======================================');
disp('实验完成! 所有结果已保存');
disp('======================================');
disp('生成的文件:');
disp(['  1. 图1_3月全球SST分布.png (200 dpi)']);
disp(['  2. 图2_1-12月区域SST分布.png (200 dpi)']);
disp(['  3. 图3_月平均SST年变化.png (200 dpi)']);
disp(['  4. 月平均SST统计结果.txt']);
disp(['  5. sst_region_data.mat (截取的区域数据)']);
disp(['  6. experiment_results.mat (所有变量)']);
disp(['保存路径: ' indir]);
disp('======================================');