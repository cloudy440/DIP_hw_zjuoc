
%% EXP6_SOLUTION.M
% 实验6：数字图像傅里叶变换（可直接运行的参考答案 + 模板）
% 说明：尽量复用课程 demo 的写法（fft2/fftshift/log 显示、相角等）。
% 如果你的课件 PDF 中给出的矩阵或图像文件名不同，只需在对应“TODO”处替换。
% -------------------------------------------------------------------------
% 作者：ChatGPT
% 日期：2025-11-04

%% 环境清理（与 demo 保持一致风格）
clear; close all; clc;

%% ======================== 实验6-1 两幅小图像的DFT与卷积 =====================
% 任务：计算两幅小图像 f、g 的二维离散傅里叶变换（幅度与相角），以及它们的卷积结果。
% 使用思路：直接用 fft2 / ifft2；卷积用 conv2（full），并用频域乘法做一次验证。

% ================== 在这里粘贴/填写 PDF 中的 f、g（按需要修改） ==================
% TODO: 将下面的 f_user、g_user 替换为实验PDF中的矩阵。
% 例如：f_user = [0 1 0; 1 4 1; 0 1 0];
%      g_user = [0 -1 0; -1 6 -1; 0 -1 0];
f_user = [0 1 0; 1 4 1; 0 1 0];
g_user = [0 -1 0; -1 6 -1; 0 -1 0];

% -------------------- 示例矩阵（若与你PDF一致，可直接使用） --------------------
% 如果不确定，请保留上面的 f_user/g_user；示例矩阵只是演示。
f = f_user;
g = g_user;

% 计算DFT（未频移）
Ff = fft2(f);
Fg = fft2(g);

% 计算DFT（中心频移，便于观察低频）
Ff_c = fftshift(Ff);
Fg_c = fftshift(Fg);

% 可视化（幅度采用 log(1+|F|)，相角 angle(F)）
figure('Name','Exp6-1: DFT of f & g');
subplot(2,4,1); imagesc(f); axis image off; title('f (spatial)'); colorbar;
subplot(2,4,2); imshow(log(1+abs(Ff)),[]); title('|F_f| (log)');
subplot(2,4,3); imshow(log(1+abs(Ff_c)),[]); title('|F_f| after fftshift (log)');
subplot(2,4,4); imshow(angle(Ff),[]); title('∠F_f');

subplot(2,4,5); imagesc(g); axis image off; title('g (spatial)'); colorbar;
subplot(2,4,6); imshow(log(1+abs(Fg)),[]); title('|F_g| (log)');
subplot(2,4,7); imshow(log(1+abs(Fg_c)),[]); title('|F_g| after fftshift (log)');
subplot(2,4,8); imshow(angle(Fg),[]); title('∠F_g');

% 线性卷积（空间域）
Y_conv = conv2(f, g, 'full');

% 用频域乘法做验证（零填充到卷积尺寸）
out_sz = size(f) + size(g) - 1;
Y_freq = ifft2( fft2(f, out_sz(1), out_sz(2)) .* fft2(g, out_sz(1), out_sz(2)) );

% 误差检查
fprintf('Exp6-1: ||Y_{conv} - Y_{freq}||_F = %.3e\n', norm(Y_conv - real(Y_freq), 'fro'));

% 显示卷积结果
figure('Name','Exp6-1: Convolution result');
subplot(1,2,1); imagesc(Y_conv); axis image; colorbar; title('y = f * g (conv2, full)');
subplot(1,2,2); imagesc(real(Y_freq)); axis image; colorbar; title('y via IFFT(FFT·FFT)');


%% ================= 实验6-2 连续信号 cos(2π n t) 的周期/频率/奈奎斯特 =================
% 题意：f(t)=cos(2π n t)，周期 = 1/n（秒），频率 = n（Hz）；最低奈奎斯特取样率 fs_N = 2n。
% 低于 fs_N 取样将发生混叠（频谱折叠），高于 fs_N 则可无混叠重建。下面给出一个可视化小实验。

n = 5;                   % 设定一个例子频率 n=5Hz，可按需修改
T0 = 1/n;                % 周期
fs_low  = 1.5*n;         % 低于Nyquist（=2n）的采样率 -> 混叠
fs_high = 8*n;           % 高于Nyquist的采样率 -> 无混叠
dur = 1.2;               % 模拟时长

t = linspace(0, dur, 20000);           % 近似“连续时间”用于参考曲线
x = cos(2*pi*n*t);

% 低采样率
tL = 0:1/fs_low:dur;
xL = cos(2*pi*n*tL);

% 高频率采样
tH = 0:1/fs_high:dur;
xH = cos(2*pi*n*tH);

figure('Name','Exp6-2: Sampling demo');
plot(t,x,'LineWidth',1); hold on;
stem(tL,xL,'.','MarkerSize',10); 
stem(tH,xH,'.','MarkerSize',10); hold off;
legend('continuous (ref)','samples @ 1.5n (< 2n, alias)','samples @ 8n (> 2n)');
xlabel('Time (s)'); ylabel('Amplitude'); title('cos(2\pi n t) sampling (aliasing vs no aliasing)');
grid on;


%% ===== 实验6-3 自选一幅灰度图像：2D DFT/IDFT、幅度、相角、重建图 =====
% 尽量复用 demo 的写法：im2double -> fft2 -> angle/abs -> fftshift -> log显示

% 尝试若干常见文件名；若不存在则用 MATLAB 自带 'cameraman.tif'
candidates = { ...
    'Fig0427(a)(woman).tif', ...
    'woman.tif', ...
    'Fig0424(a)(rectangle).tif', ...
    'cameraman.tif', ...
    'peppers.png' ...
    };
img = [];
for k = 1:numel(candidates)
    if exist(candidates{k},'file')
        img = imread(candidates{k}); break;
    end
end
if isempty(img)
    warning('未找到示例图像，自动生成一幅 256x256 的棋盘格。');
    img = checkerboard(16,8,8) > 0.5;
end
if size(img,3) > 1, img = rgb2gray(img); end
f2d = im2double(img);

F = fft2(f2d);
F_c = fftshift(F);
A  = abs(F);
A_c = abs(F_c);
P  = angle(F);

% 逆变换重建
f_rec = ifft2(F);

figure('Name','Exp6-3: 2D DFT/IDFT of a grayscale image');
subplot(2,3,1); imshow(f2d,[]); title('Original');
subplot(2,3,2); imshow(log(1+A),[]); title('|F| (log)');
subplot(2,3,3); imshow(P,[]); title('Phase ∠F');
subplot(2,3,4); imshow(log(1+A_c),[]); title('|F| after fftshift (log)');
subplot(2,3,5); imshow(real(f_rec),[]); title('Reconstructed (real(IFFT))');
subplot(2,3,6); imshow(angle(F),[]); title('∠F (again)'); % 与 demo 展示风格一致


%% ============= 实验6-4 若干序列的 N 点离散傅里叶变换（解析+数值） ==============
% (1) x(n) = δ(n)            -> X[k] = 1, ∀k
% (2) x(n) = δ(n-n0)         -> X[k] = e^{-j 2π k n0 / N}
% 给出解析式并用 fft 数值印证。

N  = 8;     % 可按需修改
n0 = 3;     % 满足 0 < n0 < N

% (1) δ(n)
x1 = zeros(1,N); x1(1) = 1;       % 注意 MATLAB 下标从 1 开始，δ(n)在 n=0 对应索引1
X1 = fft(x1, N);

% (2) δ(n-n0)
x2 = zeros(1,N);
x2(n0+1) = 1;                      % n0 -> 索引 n0+1
X2 = fft(x2, N);

% 构造解析表达验证
k = 0:N-1;
X1_ana = ones(1,N);
X2_ana = exp(-1i*2*pi*k*n0/N);

fprintf('Exp6-4: max|X1 - 1| = %.3e\n', max(abs(X1 - X1_ana)));
fprintf('Exp6-4: max|X2 - e^{-j2πkn0/N}| = %.3e\n', max(abs(X2 - X2_ana)));


%% ===== 实验6-5 x(n), h(n) 的DFT与卷积：稀疏δ序列（解析+数值双重验证） =====
% x(n) = 3δ(n) + 2δ(n-2) + 4δ(n-3)
% h(n) =   δ(n) + 5δ(n-2) +   δ(n-3)
% (1) DFT：X[k] = 3 + 2 e^{-j2πk·2/N} + 4 e^{-j2πk·3/N}
%           H[k] = 1 + 5 e^{-j2πk·2/N} +   e^{-j2πk·3/N}
% (2) 卷积 y(n) = x(n)*h(n)
%     解析可得：y(n) = 3δ(n) + 17δ(n-2) + 7δ(n-3) + 10δ(n-4) + 22δ(n-5) + 4δ(n-6)

% 构造有限长序列（至少覆盖到 n=6）
L = 7;                % n = 0..6
x = zeros(1,L);       x(1)=3; x(3)=2; x(4)=4;  % 索引1->n=0, 3->n=2, 4->n=3
h = zeros(1,L);       h(1)=1; h(3)=5; h(4)=1;  % 索引1->n=0, 3->n=2, 4->n=3

% 卷积（线性）
y_lin = conv(x,h,'full');  % 长度 13，覆盖 n=0..12（多数为0，非零只到 n=6)

% 给出解析系数（便于对照）
y_analytic = zeros(1,13);
y_analytic(1) = 3;    % n=0
y_analytic(3) = 17;   % n=2
y_analytic(4) = 7;    % n=3
y_analytic(5) = 10;   % n=4
y_analytic(6) = 22;   % n=5
y_analytic(7) = 4;    % n=6

fprintf('Exp6-5: ||y_{lin} - y_{analytic}||_∞ = %.3e\n', max(abs(y_lin - y_analytic)));

% 用DFT验证卷积定理：选择 N >= length(y_lin)
N2 = 16;  % 也可以用 N2 = 2^nextpow2(length(y_lin))
X = fft(x,N2);
H = fft(h,N2);
Y = X .* H;
y_ifft = ifft(Y,'symmetric');   % 取实部（该例应为实数）

% 对比前 length(y_lin) 点
fprintf('Exp6-5: ||y_{lin} - y_{ifft}(1:%d)||_∞ = %.3e\n', length(y_lin), max(abs(y_lin - y_ifft(1:length(y_lin)))));

% 可视化 y(n)
figure('Name','Exp6-5: Convolution y(n) from sparse deltas');
stem(0:numel(y_lin)-1, y_lin,'filled'); grid on;
xlabel('n'); ylabel('y(n)'); title('y(n) = x(n) * h(n)');


%% ============================ 运行结束 ============================
disp('All sections finished. 请根据实验PDF把矩阵/图像文件名替换到 TODO 处即可提交。');

