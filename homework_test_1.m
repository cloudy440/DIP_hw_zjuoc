clear all;
close all;
clc;

%% ========== 参数设置 ==========
% 数据路径（请根据实际情况修改）
indir = 'C:\Users\DS\Desktop\课程攻略(大三上)\DIP\SSTdata\';
outdir = indir; % 输出目录

% 获取所有nc文件
fnames = dir([indir 'AQUA_MODIS*.nc']);
fprintf('找到 %d 个数据文件\n', length(fnames));

% 定义截取区域
latmin_sub = 28;
latmax_sub = 34;
lonmin_sub = 120;
lonmax_sub = 125;

%% ========== 任务1：画出3月份全球SST分布图，并标出截取区域 ==========
fprintf('\n========== 任务1：绘制3月份全球SST分布图 ==========\n');

% 找到3月份的文件
month_target = 3;
file_idx = 0;
for i = 1:length(fnames)
    str = fnames(i).name;
    month = str2num(str(16:17));
    if month == month_target
        file_idx = i;
        break;
    end
end

if file_idx == 0
    error('未找到3月份数据文件！');
end

% 读取3月份数据
str = fnames(file_idx).name;
fprintf('正在处理文件: %s\n', str);

% 读取sst数据和经纬度
sst_march = ncread([indir str], 'sst');
lon = ncread([indir str], 'lon');
lat = ncread([indir str], 'lat');

% 经纬度网格化
longrid = repmat(lon, 1, size(lat,1));
latgrid = repmat(lat', size(lon,1), 1);

% 绘制全球SST分布图
figure('Position', [100, 100, 1200, 600])
m_proj('Equidistant Cylindrical', 'long', [-180, 180], 'lat', [-80, 80]);
m_pcolor(longrid, latgrid, sst_march);
shading flat
h = colorbar;
ylabel(h, 'SST (°C)', 'FontSize', 11);
colormap(jet);
m_grid('linestyle', 'none', 'tickdir', 'out', 'linewidth', 1.5, ...
       'fontsize', 10);
title('March Global Sea Surface Temperature', 'FontSize', 14, 'FontWeight', 'bold');

% 在全球图上标出截取区域（红色方框）
m_line([lonmin_sub lonmax_sub lonmax_sub lonmin_sub lonmin_sub], ...
       [latmin_sub latmin_sub latmax_sub latmax_sub latmin_sub], ...
       'color', 'r', 'linewidth', 2.5);
m_text(lonmin_sub-5, latmin_sub-2, '28-34°N, 120-125°E', ...
       'color', 'r', 'fontsize', 10, 'fontweight', 'bold');

% 保存图像
print(gcf, '-dpng', '-r200', [outdir 'Task1_March_Global_SST.png']);
fprintf('✓ 任务1完成：已保存 Task1_March_Global_SST.png\n');

%% ========== 任务2：截取1-12月份数据并绘图 ==========
fprintf('\n========== 任务2：截取并绘制1-12月份区域SST分布 ==========\n');

% 找到截取区域的索引
ind_lon = find(lon >= lonmin_sub & lon <= lonmax_sub);
ind_lat = find(lat >= latmin_sub & lat <= latmax_sub);

% 提取子区域的经纬度网格
longrid_sub = longrid(ind_lon, ind_lat);
latgrid_sub = latgrid(ind_lon, ind_lat);

% 初始化存储
sst_sub_all = cell(12, 1);
months_available = false(12, 1);

% 读取所有月份数据
for i = 1:length(fnames)
    str = fnames(i).name;
    month = str2num(str(16:17));
    
    if month >= 1 && month <= 12
        fprintf('读取第 %d 月数据...\n', month);
        
        % 读取sst数据
        sst_temp = ncread([indir str], 'sst');
        
        % 截取数据
        sst_sub = sst_temp(ind_lon, ind_lat);
        
        % 存储截取的数据
        sst_sub_all{month} = sst_sub;
        months_available(month) = true;
    end
end

% 保存截取的数据
save([outdir 'SST_Subset_Data.mat'], 'sst_sub_all', 'longrid_sub', ...
     'latgrid_sub', 'lon', 'lat', 'ind_lon', 'ind_lat');
fprintf('✓ 已保存截取的SST数据至 SST_Subset_Data.mat\n');

% 绘制1-12月份截取区域的SST分布图
figure('Position', [50, 50, 1600, 1200])
for month = 1:12
    if months_available(month)
        subplot(3, 4, month)
        
        m_proj('Equidistant Cylindrical', 'long', [lonmin_sub, lonmax_sub], ...
               'lat', [latmin_sub latmax_sub]);
        m_pcolor(longrid_sub, latgrid_sub, sst_sub_all{month});
        shading flat
        colorbar;
        colormap(jet);
        caxis([min(min(sst_sub_all{month})), max(max(sst_sub_all{month}))]);
        m_grid('linestyle', 'none', 'tickdir', 'out', 'fontsize', 8);
        m_gshhs_i('color', 'k'); % 添加高精度岸线
        
        title(sprintf('Month %d', month), 'FontSize', 11, 'FontWeight', 'bold');
    else
        subplot(3, 4, month)
        text(0.5, 0.5, sprintf('Month %d\nNo Data', month), ...
             'HorizontalAlignment', 'center', 'FontSize', 12);
        axis off;
    end
end

% 保存图像
print(gcf, '-dpng', '-r200', [outdir 'Task2_Monthly_SST_Subset.png']);
fprintf('✓ 任务2完成：已保存 Task2_Monthly_SST_Subset.png\n');

%% ========== 任务3：计算空间平均值和标准偏差 ==========
fprintf('\n========== 任务3：统计分析和绘制月度变化曲线 ==========\n');

% 初始化
monthly_mean = zeros(12, 1);
monthly_std = zeros(12, 1);

% 计算每个月的空间平均值和标准偏差
for month = 1:12
    if months_available(month)
        sst_data = sst_sub_all{month};
        % 去除NaN值后计算
        valid_data = sst_data(~isnan(sst_data));
        
        if ~isempty(valid_data)
            monthly_mean(month) = mean(valid_data);
            monthly_std(month) = std(valid_data);
        else
            monthly_mean(month) = NaN;
            monthly_std(month) = NaN;
        end
    else
        monthly_mean(month) = NaN;
        monthly_std(month) = NaN;
    end
end

% 创建并显示表格
months = (1:12)';
results_table = table(months, monthly_mean, monthly_std, ...
                      'VariableNames', {'Month', 'Mean_SST_degC', 'Std_SST_degC'});

fprintf('\n======== 月度SST统计结果 ========\n');
disp(results_table);

% 保存表格为CSV文件
writetable(results_table, [outdir 'Task3_SST_Statistics.csv']);
fprintf('✓ 已保存统计表格至 Task3_SST_Statistics.csv\n');

% 绘制均值随月份变化的曲线，带误差棒
figure('Position', [100, 100, 900, 600])
errorbar(months, monthly_mean, monthly_std, 'o-', 'LineWidth', 2, ...
         'MarkerSize', 10, 'MarkerFaceColor', 'b', 'Color', 'b', ...
         'CapSize', 10);
hold on;
plot(months, monthly_mean, '-', 'LineWidth', 1.5, 'Color', [0.3 0.3 0.8]);
grid on;
box on;

xlabel('Month', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Sea Surface Temperature (°C)', 'FontSize', 13, 'FontWeight', 'bold');
title({'Monthly Mean SST with Standard Deviation', ...
       sprintf('Region: %d-%d°N, %d-%d°E', latmin_sub, latmax_sub, ...
               lonmin_sub, lonmax_sub)}, ...
      'FontSize', 14, 'FontWeight', 'bold');
xlim([0.5 12.5]);
xticks(1:12);
set(gca, 'FontSize', 11);

% 添加图例
legend('Mean SST ± Std', 'Mean SST', 'Location', 'best');

% 保存图像
print(gcf, '-dpng', '-r200', [outdir 'Task3_Monthly_SST_Curve.png']);
fprintf('✓ 任务3完成：已保存 Task3_Monthly_SST_Curve.png\n');

%% ========== 实验总结 ==========
fprintf('\n========================================\n');
fprintf('所有任务完成！\n');
fprintf('输出文件：\n');
fprintf('  1. Task1_March_Global_SST.png - 3月份全球SST分布图\n');
fprintf('  2. Task2_Monthly_SST_Subset.png - 1-12月份区域SST分布图\n');
fprintf('  3. Task3_SST_Statistics.csv - 月度SST统计表格\n');
fprintf('  4. Task3_Monthly_SST_Curve.png - 月度SST变化曲线\n');
fprintf('  5. SST_Subset_Data.mat - 截取的SST数据\n');
fprintf('========================================\n');