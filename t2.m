%% 实验① 背景与目标区域 ΔI/I
clear all; close all; clc;

N = 255;               % 背景大小
T = 41;                % 目标区域大小
pos = ceil(N/2);

% 四种情况
background_vals = [255 255 20 20]/255.0;
target_vals = [20 75 200 75]/255.0;
titles = {'Bright bg, Dark target','Bright bg, Medium target','Dark bg, Bright target','Dark bg, Medium target'};

figure
for i = 1:4
    back = ones(N,N)*background_vals(i);
    tval = target_vals(i);
    back(pos-20:pos+20, pos-20:pos+20) = tval;

    tratio = abs(background_vals(i)-tval)/background_vals(i);
    subplot(2,2,i)
    imshow(back)
    title([titles{i} '  ΔI/I=' num2str(tratio,'%0.3f')])
end
