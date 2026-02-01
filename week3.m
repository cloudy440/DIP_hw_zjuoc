%% 实验3 灰度内插和几何变换（复用demo流程）
clear; close all; clc;

% ---------- 共同素材 ----------
% 把下面两个文件名改成本机上的路径或放到当前工作目录：
fname1 = 'face00.jpg';   % 例如：你的第一张人脸
fname2 = 'face01.jpg';   % 例如：你的第二张人脸

I1 = imread(fname1);
I2 = imread(fname2);
if size(I1,3)==3, I1 = rgb2gray(I1); end
if size(I2,3)==3, I2 = rgb2gray(I2); end

%% ① 不同灰度级量化 (1,2,3,...,8bit)
figure('Name','① 量化级数对比'); 
bits = 1:8; % 1~8 bit
for k = 1:8
    L = 2^bits(k);                      % 量化级数
    Iq = uint8( round( double(I1)/255 * (L-1) ) * (255/(L-1)) );
    subplot(2,4,k); imshow(Iq);
    title(sprintf('%d-bit (%d levels)',bits(k),L));
end
% 结论：当量化级数很少(如1~3bit)时，会出现明显的"伪轮廓/色带"(banding)，
% 因为连续灰度被挤压到少量离散级，引起量化误差与梯度断层。

%% ② 取样与内插：放大2倍/缩小0.5倍（最近邻/双线性/双三次）
scale_up   = 2.0;
scale_down = 0.5;

I_up_nn   = imresize(I1, scale_up,   'nearest');
I_up_bl   = imresize(I1, scale_up,   'bilinear');
I_up_bc   = imresize(I1, scale_up,   'bicubic');

I_dn_nn   = imresize(I1, scale_down, 'nearest');
I_dn_bl   = imresize(I1, scale_down, 'bilinear');
I_dn_bc   = imresize(I1, scale_down, 'bicubic');

figure('Name','② 放大/缩小与内插对比');
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I_up_nn); title('×2 Nearest');
nexttile; imshow(I_up_bl); title('×2 Bilinear');
nexttile; imshow(I_up_bc); title('×2 Bicubic');
nexttile; imshow(I_dn_nn); title('×0.5 Nearest');
nexttile; imshow(I_dn_bl); title('×0.5 Bilinear');
nexttile; imshow(I_dn_bc); title('×0.5 Bicubic');
% 观感：最近邻快但锯齿；双线性更平滑；双三次细节/过渡更自然。

%% ③ 仿射矩阵举例：水平镜像、平移、垂直偏移(剪切)
% 3a) 水平镜像：x' = -x + W-1, y' = y
W = size(I1,2);  H = size(I1,1);
T_mirror = [ -1  0  W-1;
              0  1   0 ;
              0  0   1 ];
tform_m  = affine2d(T_mirror');
I_mirror = imwarp(I1, tform_m, 'OutputView', imref2d([H W]));

% 3b) 平移：向右tx、向下ty
tx = 40; ty = 30;
T_trans = [ 1 0 tx;
            0 1 ty;
            0 0  1 ];
I_trans = imwarp(I1, affine2d(T_trans'), 'OutputView', imref2d([H W]));

% 3c) 垂直偏移(沿y剪切)：x' = x, y' = y + kx
k = 0.3;
T_shearV = [ 1  0  0;
             k  1  0;
             0  0  1 ];
I_shearV = imwarp(I1, affine2d(T_shearV'), 'OutputView', imref2d([H W]));

figure('Name','③ 仿射变换示例');
subplot(2,2,1); imshow(I1);       title('Original');
subplot(2,2,2); imshow(I_mirror); title('Horizontal Mirror');
subplot(2,2,3); imshow(I_trans);  title(sprintf('Translate (%d,%d)',tx,ty));
subplot(2,2,4); imshow(I_shearV); title(sprintf('Vertical Shear k=%.2f',k));
% 以上矩阵即为要求给出的变换矩阵。

%% ④ 人脸配准（复用 demo 的交互流程）
% 打开交互式控制点选取界面：把 I2 配到 I1 上（I1为base，I2为input）
% 在 cpselect 窗口 File->Save Points to Workspace... 选择 structure with all points
% 变量名默认 cpstruct，随后使用其点对进行仿射/相似变换估计。
% 参见讲义与demo：cpselect -> cp2tform -> imtransform/imwarp
% （如果你已保存过点对，可直接跳过 cpselect，用 inps/baps 变量）
cpselect(I2, I1);   % 手动点选后，点击保存到工作区（结构体）

% ---- 点对变量（保存后运行以下几行）----
% inps = cpstruct.inputPoints;  % moving/input points
% baps = cpstruct.basePoints;   % fixed/base points
% tform = cp2tform(inps, baps, 'affine');        % 或 'similarity'
% I_reg = imtransform(I2, tform);                % 复用demo风格
% figure('Name','④ 配准结果');
% subplot(1,3,1); imshow(I1);    title('Base (I1)');
% subplot(1,3,2); imshow(I_reg); title('Registered I2');
% subplot(1,3,3); imshow(I2);    title('Original I2');
% tform.tdata.T  % 查看仿射矩阵（或 tform.tdata 里的参数）
% 同步记录：给出所选的基准点对 (inps,baps) 和得到的几何变换矩阵。

%% ⑤ 两幅人脸瞳孔坐标→平移/转动/尺度
% 第一张： (83,231),(437,244)  第二张：(64,281),(479,370)
p1a=[83,231]'; p2a=[437,244]';   % 图1左右瞳孔
p1b=[64,281]'; p2b=[479,370]';   % 图2左右瞳孔

va = p2a - p1a;  vb = p2b - p1b;
da = hypot(va(1),va(2));  db = hypot(vb(1),vb(2));   % 两眼间距
s  = db/da;                                  % 尺度
tha= atan2(va(2),va(1)); thb = atan2(vb(2),vb(1));
theta = thb - tha;                           % 旋转角(弧度)，逆时针为正

R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
t = p1b - s*R*p1a;                           % 平移向量

fprintf('⑤ 结果：scale = %.4f, rotation = %.4f rad (%.2f°), translation = [tx,ty] = [%.2f, %.2f]\\n',...
    s, theta, theta*180/pi, t(1), t(2));

% 相似变换的齐次矩阵（从图1到图2）：
T_sim = [ s*R  t; 0 0 1 ]

%% ⑥ 14mm×14mm、2048×2048，拍 0.5 m 处平面，镜头 35mm
% 成像公式 1/f = 1/u + 1/v，放大率 m = v/u
f = 35e-3; u = 0.5;                  % f=35mm, u=0.5m
v = 1/(1/f - 1/u);
m = v/u;
objW_mm = 14 / m;                    % 物面对应宽度 (mm)
px_per_mm_obj = 2048 / objW_mm;      % 物面每毫米像素数
lp_per_mm = px_per_mm_obj / 2;       % 线对/毫米（Nyquist近似）

fprintf('⑥ 物面宽度≈%.1f mm, 分辨率≈%.2f px/mm, 线对/毫米≈%.2f lp/mm\\n',...
    objW_mm, px_per_mm_obj, lp_per_mm);
