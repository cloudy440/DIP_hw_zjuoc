%% MATLAB 脚本：海表面温度数据分析与可视化 (基于单个包含多年数据的NetCDF文件)

clc; clear; close all;

% =========================================================================
% 用户配置部分
% =========================================================================
% 数据文件所在的文件夹路径
indir = 'E:\AppCache\MATLAB\DIP\SSTdata\'; 
% 数据文件名（假设是一个包含多年月平均数据的大文件）
ifname = 'AQUA_MODIS.20020701_20230731.L3m.MC.SST.sst.4km.nc'; 
% 存储输出图像的文件夹路径 (会自动创建)
output_dir = 'E:\AppCache\MATLAB\DIP\SST_Output_SingleFile\'; 

% 定义全球范围（用于Part 1）
global_lonmin = -180; global_lonmax = 180;
global_latmin = -90; global_latmax = 90;

% 定义局部区域范围（用于Part 1和Part 2, Part 3）
region_latmin = 28; region_latmax = 34;
region_lonmin = 120; region_lonmax = 125;

% 月份名称（用于绘图和表格）
month_names = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

% =========================================================================
% 脚本开始
% =========================================================================

% 检查并创建输出目录
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('Output directory created: %s\n', output_dir);
end

full_filepath = [indir ifname];
if ~exist(full_filepath, 'file')
    error('文件不存在: %s. 请检查文件路径和文件名。', full_filepath);
end

fprintf('--- 正在显示文件信息 ---\n');
ncdisp(full_filepath); % 显示文件详细信息

% 读取SST数据, 经度, 纬度
var_sst = 'sst';
var_lon = 'lon';
var_lat = 'lat';
var_time = 'time'; % 假设时间变量名为 'time'

sst_full = ncread(full_filepath, var_sst);
lon = ncread(full_filepath, var_lon);
lat = ncread(full_filepath, var_lat);

% --- 读取时间信息并处理 ---
% 注意: NetCDF文件中的时间通常以某种基准日期（例如'days since 1970-01-01'）表示
% 您需要根据 ncdisp 显示的 'units' 属性来正确解析时间
time_var_info = ncinfo(full_filepath, var_time);
time_units = time_var_info.Attributes(ismember({time_var_info.Attributes.Name}, 'units')).Value;
fprintf('时间单位: %s\n', time_units);

% 假设 time_units 是 'days since YYYY-MM-DD' 或类似
% 这里需要根据实际情况调整时间解析逻辑
% 示例：假设是 'days since 2002-07-01' 或类似的 Julian Date
time_raw = ncread(full_filepath, var_time);
% 这里是一个通用的解析示例，您可能需要根据 `ncdisp` 结果中的 `units` 属性进行调整
% 常见的 units 例子: 'days since 1858-11-17 00:00:00' (Matlab's datenum base)
% 'hours since 1900-01-01 00:00:00'
% 这里我们先假设时间数据可以直接转换为日期序列，或者您能提供时间的 units 信息
% 比如，如果 units 是 'days since 2002-07-01 00:00:00', 那么:
% datestr(datenum('2002-07-01 00:00:00') + time_raw)
% 如果 time_raw 已经是 MatLAB 的 datenum 格式（不常见），则直接使用
% 
% 鉴于 `ncdisp` 的输出中通常会包含 `units` 信息，假设时间是 'days since YYYY-MM-DD'
% 我们可以尝试从 `time_units` 字符串中解析基准日期
base_date_str_match = regexp(time_units, 'since\s(\d{4}-\d{2}-\d{2})', 'tokens', 'once');
if ~isempty(base_date_str_match)
    base_date_str = base_date_str_match{1};
    base_datenum = datenum(base_date_str, 'yyyy-mm-dd');
    time_datenum = base_datenum + time_raw; % 假设 time_raw 是天数
else
    % 如果不能自动解析，需要手动设置基准日期，或者检查 ncdisp 输出
    warning('未能自动解析时间单位的基准日期。请检查ncdisp输出并手动调整时间解析。');
    % 假设一个默认的基准日期，例如文件名的开始日期
    % 假设文件名是 'AQUA_MODIS.YYYYMMDD_YYYYMMDD.L3m...'
    start_date_from_filename = ifname(regexp(ifname,'\d{8}','once'):regexp(ifname,'\d{8}','once')+7);
    base_datenum = datenum(start_date_from_filename, 'yyyymmdd');
    time_datenum = base_datenum + time_raw; % 假设 time_raw 是天数
end

% 提取每个时间步的月份
[~, months, ~] = datevec(time_datenum); 

% 假设 SST 数据的填充值（NoDataValue）远大于实际温度，我们将其设为 NaN
sst_full(sst_full > 100 | sst_full < -10) = NaN; % 移除异常值，根据实际情况调整

% 经纬度网格化
longrid = repmat(lon, 1, length(lat));
latgrid = repmat(lat', length(lon), 1);

% =========================================================================
% (1) 画出3月份月平均海表面温度全球空间分布图
% =========================================================================

fprintf('\n--- 正在执行任务 (1): 绘制全球3月份SST分布图 ---\n');

% 找到所有3月份的数据索引
march_indices = find(months == 3);

if isempty(march_indices)
    error('在数据文件中未找到任何3月份的数据。');
end

% 计算所有3月份的平均值 (气候平均)
sst_march_clim = nanmean(sst_full(:,:,march_indices), 3); % 在第三维度（时间维度）上求平均

figure('Name', 'March Global SST', 'Position', [100 100 900 600]);
m_proj('Equidistant Cylindrical', 'long', [global_lonmin, global_lonmax], ...
       'lat', [global_latmin, global_latmax]);
m_pcolor(longrid, latgrid, sst_march_clim);
shading flat;
cbar = colorbar;
ylabel(cbar, 'SST (\circC)', 'FontSize', 12);
colormap(jet);

m_grid('tickdir', 'out', 'xtick', -180:60:180, 'ytick', -90:30:90, ...
       'linewidth', 0.8, 'fontsize', 10);
m_coast('line', 'Color', 'k', 'LineWidth', 0.8);

title('March Climatological Mean Global Sea Surface Temperature', 'FontSize', 14);

% 用方框标出空间范围 28-34ºN, 120-125ºE
box_lon = [region_lonmin, region_lonmax, region_lonmax, region_lonmin, region_lonmin];
box_lat = [region_latmin, region_latmin, region_latmax, region_latmax, region_latmin];
m_line(box_lon, box_lat, 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');
m_text(mean(region_lonmin:region_lonmax), region_latmax + 2, 'Target Region', 'Color', 'r', 'FontSize', 10, 'HorizontalAlignment', 'center');

print(gcf, '-dpng', '-r200', [output_dir 'Global_SST_March_Climatology.png']);
fprintf('3月份全球SST气候平均图已保存至 %sGlobal_SST_March_Climatology.png\n', output_dir);
close(gcf);

% =========================================================================
% (2) 截取1-12月份空间范围28-34ºN，120-125ºE的海表面温度月平均数据，
%     存出截取的海表面温度数据块，并画出1-12月份截取数据空间分布图
% =========================================================================

fprintf('\n--- 正在执行任务 (2): 截取区域数据并绘制月度气候平均SST图 ---\n');

% 找到指定区域的经纬度索引
ind_lon = find(lon >= region_lonmin & lon <= region_lonmax);
ind_lat = find(lat >= region_latmin & lat <= region_latmax);

if isempty(ind_lon) || isempty(ind_lat)
    error('指定的区域 (%.1f-%.1fN, %.1f-%.1fE) 在数据范围内没有对应经纬度点。', ...
          region_latmin, region_latmax, region_lonmin, region_lonmax);
end

% 截取区域的经纬度网格（用于绘图）
longrid_sub = longrid(ind_lon, ind_lat);
latgrid_sub = latgrid(ind_lon, ind_lat);

% 预分配存储截取数据的空间 (Lon_dim x Lat_dim x 12个月) - 存放气候平均值
sst_subset_monthly_clim = nan(length(ind_lon), length(ind_lat), 12);

for m = 1:12
    fprintf('正在处理 %s 月份气候数据...\n', month_names{m});
    
    % 找到所有该月份的数据索引
    current_month_indices = find(months == m);
    if isempty(current_month_indices)
        warning('在数据文件中未找到任何 %s 月份的数据。将跳过此月份。', month_names{m});
        continue;
    end
    
    % 计算所有该月份的平均值 (气候平均)
    sst_current_clim = nanmean(sst_full(:,:,current_month_indices), 3);
    
    % 截取当前月份气候平均的SST数据
    sst_sub_current_clim = sst_current_clim(ind_lon, ind_lat);
    sst_subset_monthly_clim(:,:,m) = sst_sub_current_clim; % 存储截取的气候平均数据块
    
    % 绘制当前月份的区域SST图
    figure('Name', sprintf('%s Regional Climatological SST', month_names{m}), 'Position', [100 100 700 600]);
    m_proj('Equidistant Cylindrical', 'long', [region_lonmin, region_lonmax], ...
           'lat', [region_latmin, region_latmax]);
    m_pcolor(longrid_sub, latgrid_sub, sst_sub_current_clim);
    shading flat;
    cbar = colorbar;
    ylabel(cbar, 'SST (\circC)', 'FontSize', 10);
    colormap(jet);
    
    m_grid('tickdir', 'out', 'xtick', region_lonmin:1:region_lonmax, 'ytick', region_latmin:1:region_latmax, ...
           'linewidth', 0.8, 'fontsize', 9);
    m_gshhs_i('patch', [.7 .7 .7], 'edgecolor', 'k');
    
    title_str = sprintf('%s Climatological Mean SST (%.1f-%.1fN, %.1f-%.1fE)', ...
                        month_names{m}, region_latmin, region_latmax, region_lonmin, region_lonmax);
    title(title_str, 'FontSize', 12);
    
    print(gcf, '-dpng', '-r200', [output_dir 'Regional_SST_Climatology_' month_names{m} '.png']);
    fprintf('%s 月区域SST气候平均图已保存。\n', month_names{m});
    close(gcf);
end
fprintf('所有月份的区域SST气候平均数据已截取并保存为图像。\n');


% =========================================================================
% (3) 将截取的1-12月份空间范围28-34ºN，120-125ºE的海表面温度月平均数据
%     按月进行空间平均，计算均值和标准偏差，用表格给出计算结果，并画出
%     均值随月份变化的曲线，同时用误差棒标上标准偏差。
% =========================================================================

fprintf('\n--- 正在执行任务 (3): 计算并绘制月度均值和标准偏差 ---\n');

monthly_means_clim = nan(1, 12);
monthly_stds_clim = nan(1, 12);

for m = 1:12
    % 这里使用的是之前计算好的气候平均区域数据
    current_month_data_clim = sst_subset_monthly_clim(:,:,m); 
    
    monthly_means_clim(m) = nanmean(current_month_data_clim(:)); 
    monthly_stds_clim(m) = nanstd(current_month_data_clim(:));
end

% 结果表格显示
fprintf('\n--------------------------------------------------------------\n');
fprintf('  月度空间平均SST及标准偏差 (28-34N, 120-125E) - 气候平均\n');
fprintf('--------------------------------------------------------------\n');
fprintf('%-10s %-15s %-15s\n', '月份', '均值 (℃)', '标准偏差 (℃)');
fprintf('--------------------------------------------------------------\n');
for m = 1:12
    fprintf('%-10s %-15.2f %-15.2f\n', month_names{m}, monthly_means_clim(m), monthly_stds_clim(m));
end
fprintf('--------------------------------------------------------------\n');

% 绘制均值随月份变化的曲线，用误差棒标上标准偏差
figure('Name', 'Monthly SST Climatological Mean and Std Dev', 'Position', [100 100 800 500]);
errorbar(1:12, monthly_means_clim, monthly_stds_clim, 'o-', ...
         'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'Color', 'b');
grid on;
xlabel('月份', 'FontSize', 12);
ylabel('海表面温度 (\circC)', 'FontSize', 12);
title('月平均海表面温度及标准偏差 (28-34N, 120-125E) - 气候平均', 'FontSize', 14);
xticks(1:12);
xticklabels(month_names);
xlim([0.5 12.5]);
ylim_min = min(monthly_means_clim - monthly_stds_clim);
ylim_max = max(monthly_means_clim + monthly_stds_clim);
if ~isnan(ylim_min) && ~isnan(ylim_max)
    ylim([ylim_min - 0.5, ylim_max + 0.5]);
end


print(gcf, '-dpng', '-r200', [output_dir 'Monthly_SST_Climatology_Mean_Std_Curve.png']);
fprintf('月度SST气候平均值和标准偏差曲线图已保存至 %sMonthly_SST_Climatology_Mean_Std_Curve.png\n', output_dir);
close(gcf);

fprintf('\n--- 所有任务已完成！ ---\n');