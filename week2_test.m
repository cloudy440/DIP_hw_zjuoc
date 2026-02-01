%% 实验2-题①：生成背景+目标，计算 ΔI/I 并显示

clear; close all; clc;

% 画布/目标尺寸
H = 255; W = 255;           % 背景大小
tH = 41;  tW = 41;          % 目标区域大小（中心方块）
cy = ceil(H/2); cx = ceil(W/2);

% 四种组合：(背景 I, 目标 t) 取值
% 背景 I = 255 或 20；目标 t = 200 或 75；都给出 0~1 归一化与 0~255 两种写法
cases = { ...
    struct('I',255,'t',200,'Istr','I=255','tstr','t=200'), ...
    struct('I',255,'t',75, 'Istr','I=255','tstr','t=75' ), ...
    struct('I',20, 't',200,'Istr','I=20' ,'tstr','t=200'), ...
    struct('I',20, 't',75, 'Istr','I=20' ,'tstr','t=75' )};

figure('Name','Q1: 背景+目标显示（imshow按0-1显示）','Color','w');
tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

for k = 1:numel(cases)
    I8 = uint8(ones(H,W) * cases{k}.I);     % 背景（0~255）
    t8 = uint8(cases{k}.t);
    % 在中心写入目标块
    r = (cy - floor(tH/2)):(cy + ceil(tH/2)-1);
    c = (cx - floor(tW/2)):(cx + ceil(tW/2)-1);
    I8(r,c) = t8;

    % 归一化到0~1以符合 imshow 默认期望
    I = im2double(I8);

    % 计算 ΔI/I，按题意：ΔI = |I_bkg - I_tgt|，再除以 I_bkg
    bval = double(cases{k}.I)/255.0;
    tval = double(cases{k}.t)/255.0;
    tratio = abs(bval - tval) / bval;

    nexttile;
    imshow(I);
    title(sprintf('%s, %s,  \\DeltaI/I=%.4f', cases{k}.Istr, cases{k}.tstr, tratio), 'Interpreter','tex');

    % 同时在命令行打印
    fprintf('[%s, %s]  ΔI/I = %.6f\n', cases{k}.Istr, cases{k}.tstr, tratio);
end
