%%
function res = CSA_imaging_humanOptimized
close all;

R_nc = 20e3;            % 景中心斜距
Vr = 150;               % 雷达有效速度
Tr = 2.5e-6;            % 发射脉冲时宽
Kr = 20e12;             % 距离调频率
f0 = 5.3e9;             % 雷达工作频率
BW_dop = 80;            % 多普勒带宽
Fr = 60e6;              % 距离采样率
Fa = 200;               % 方位采样率
Naz = 1024;          	% 距离线数（即数据矩阵，行数）——这里修改为1024。
Nrg = 320;              % 距离线采样点数（即数据矩阵，列数）
sita_r_c = 0; %(0 * pi) / 180;	% 波束斜视角，0 度，这里转换为弧度
c = 3e8;                % 光速

R0 = R_nc * cos(sita_r_c);	% 与R_nc相对应的最近斜距，记为R0
lamda = c / f0;           % 波长
fnc = 2 * Vr * sin(sita_r_c) / lamda;     % 多普勒中心频率，根据公式（4.33）计算。
fact = 0.886;
La_real = fact * 2 * Vr * cos(sita_r_c) / BW_dop;  % 方位向天线长度，根据公式（4.36）
beta_bw = fact * lamda / La_real;              % 雷达3dB波束
La = beta_bw * R0;        % 合成孔径长度

NFFT_r = Nrg;           % 距离向FFT长度
NFFT_a = Naz;           % 方位向FFT长度

R_ref = R0;             % 参考目标选在场景中心，其最近斜距为 R_ref
fn_ref = fnc;        	% 参考目标的多普勒中心频率

delta_R0 = 0;       % 将目标1的波束中心穿越时刻，定义为方位向时间零点。
delta_R1 = 120; 	% 目标1和目标2的方位向距离差，120m
delta_R2 = 80;      % 目标2和目标3的距离向距离差，80m

x1 = R0;            % 目标1的距离向距离
y1 = delta_R0 + x1 * tan(sita_r_c);	% 目标1的方位向距离

x2 = x1;            % 目标2和目标1的距离向距离相同
y2 = y1 + delta_R1; % 目标2的方位向距离

x3 = x2 + delta_R2;                 % 目标3和目标2有距离向的距离差，为delta_R2
y3 = y2 + delta_R2 * tan(sita_r_c);  	% 目标3的方位向距离

x_range = [x1,x2,x3];
y_azimuth = [y1,y2,y3];

nc_1 = helpFun(y1, x1, sita_r_c, Vr);
nc_2 = helpFun(y2, x2, sita_r_c, Vr);
nc_3 = helpFun(y3, x3, sita_r_c, Vr);
nc_target = [nc_1,nc_2,nc_3];       % 定义该数组，便于处理。

%% 
fun = @(A)-A / 2 : A / 2 - 1;
tr = 2 * R0 / c +   fun(Nrg) / Fr;                % 距离时间轴
fr =                fun(NFFT_r) * ( Fr / NFFT_r );          % 距离频率轴
% 方位
ta =                fun(Naz) / Fa;                            % 方位时间轴
fa = fnc + fftshift(fun(NFFT_a) ) * ( Fa / NFFT_a );	% 方位频率轴

tr_mtx = ones(Naz,1) * tr;    % 距离时间轴矩阵，大小：Naz * Nrg
fr_mtx = ones(Naz,1) * fr;    % 距离频率轴矩阵，大小：Naz * Nrg
ta_mtx = ta.' * ones(1,Nrg);  % 方位时间轴矩阵，大小：Naz * Nrg

%% 
s_echo = zeros(Naz,Nrg);    % 用来存放生成的回波数据

A0 = 1;                     % 目标回波幅度，都设置为1.
onesArray = ones(1,Nrg);
value = (La / 2) / Vr;
ipi = 1j * pi;

for k = 1:3                 % 生成k个目标的原始回波数据
    R_n = sqrt(repmat(x_range(k),Naz,Nrg).^2 + (Vr .* ta_mtx - repmat(y_azimuth(k),Naz,Nrg)).^2);% 目标k的瞬时斜距
    w_range = ((abs(tr_mtx - 2 .* R_n ./ c)) <= (repmat(Tr / 2,Naz,Nrg)));     % 距离向包络，即距离窗

    w_azimuth = (abs(ta - nc_target(k)) <= value);    % 行向量
    w_azimuth = w_azimuth.' * onesArray;    % 生成Naz * Nrg的矩阵

    s_k = A0 .* w_range .* w_azimuth .* exp(-(4 * ipi * f0) .* R_n ./ c) .* exp((ipi * Kr) .* (tr_mtx - 2 .* R_n ./ c).^2);

    s_echo = s_echo + s_k;  % 所有点目标回波信号之和   
end

figure
str1 = '距离时域（采样点）';
str2 = '方位时域（采样点）';

helpFun2(1, @real, s_echo, '（a）实部', str1, str2);
text(300,-70,'图1，原始数据');       % 给图1进行文字说明 

helpFun2(2, @imag, s_echo, '（b）虚部', str1, str2);
helpFun2(3, @abs, s_echo, '（c）幅度', str1, str2);
helpFun2(4, @angle, s_echo, '（d）相位', str1, str2);

figure

helpFun6(1,@abs,@(arg)fft(arg,[],1),s_echo,'RD 频谱幅度')
helpFun6(2,@angle,@(arg)fft(arg,[],1),s_echo,'RD 频谱相位')
helpFun6(3,@abs,@fft2,s_echo,'二维频谱幅度')
helpFun6(4,@angle,@fft2,s_echo,'二维频谱幅度')

%%
s_rd        = s_echo .* exp(-2 * ipi * fnc .* (ta.' * onesArray)); 	% 数据搬移
S_RD        = fft(s_rd,NFFT_a,1);  % 进行方位向傅里叶变换，得到距离多普勒域频谱

D_fn_Vr     = helpFun3(lamda, fa.', Vr);
D_fn_Vr_mtx = D_fn_Vr * onesArray;  % 形成矩阵，大小：Nrg * Naz

D_fn_ref_Vr = helpFun3(lamda, fn_ref, Vr);

K_src       = 2 * Vr^2 * f0^3 .* D_fn_Vr.^3 ./ (c * R_ref * (fa.').^2);   % 列向量，使用R_ref处的值 
K_src_mtx   = K_src * onesArray;  % 形成矩阵
Km          = Kr ./ (1 - Kr ./ K_src_mtx); % 矩阵，这是变换到距离多普勒域的距离调频率。

s_sc        = exp(ipi .* Km .* (D_fn_ref_Vr ./ D_fn_Vr_mtx - 1) .* (tr_mtx - 2 * R_ref ./ (c .* D_fn_Vr_mtx)).^2);

S_RD_1 = S_RD .* s_sc; % 相位相乘，实现“补余RCMC”

% 作图
helpFun4(S_RD,'原始数据变换到距离多普勒域，幅度')
helpFun4(S_RD_1,'距离多普勒域，补余RCMC后，幅度')

%% 
S_2df_1 = fft(S_RD_1,NFFT_r,2); % 进行距离向FFT，变换到二维频域。距离零频在两端

H1      = exp(ipi .* D_fn_Vr_mtx ./ (D_fn_ref_Vr .* Km) .* fr_mtx.^2)...
       .* exp(4 * ipi / c .* (1 ./ D_fn_Vr_mtx - 1 / D_fn_ref_Vr) .* R_ref .* fr_mtx);

H1      = fftshift(H1,2); % 左右半边互换，距离零频在两端。

S_2df_2 = S_2df_1 .* H1; % 在二维频域，相位相乘，实现距离压缩，SRC，一致RCMC

S_RD_2  = ifft(S_2df_2,NFFT_r,2); % 进行距离IFFT，回到距离多普勒域，完成所有距离处理。

% 作图
helpFun4(S_2df_1,'变换到二维频域')
helpFun4(S_2df_2,'相位相乘，实现距离压缩，SRC，一致RCMC后，二维频域')
helpFun4(S_RD_2,'完成距离压缩，SRC，一致RCMC后，距离多普勒域')

%%
R0_RCMC = (c / 2) .* tr;   % 随距离线变化的R0，记为R0_RCMC，用来计算方位MF。

Haz     = exp(4 * ipi .* (D_fn_Vr * R0_RCMC) .* f0 ./ c);       % 方位MF

H2      = exp(-4 * ipi .* Km ./ (c^2) .* (1 - D_fn_Vr_mtx ./ D_fn_ref_Vr)...
       .* ((1 ./ D_fn_Vr) * R0_RCMC - R_ref ./ D_fn_Vr_mtx).^2); 	% 附加相位校正项

S_RD_3  = S_RD_2 .* Haz .* H2;           % 距离多普勒域，相位相乘

s_image = ifft(S_RD_3,NFFT_a,1); 	% 完成成像过程，得到成像结果为：s_image

% 作图
helpFun4(S_RD_3,'距离多普勒域，进行了相位相乘后（方位MF和附加相位校正）')
helpFun4(s_image,'成像结果')

%%
NN = 20;

tg_1_x = rem( R0 * tan(sita_r_c) / Vr * Fa , Naz );
if tg_1_x < Naz / 2
    direction = 1;
else
    direction = -1;
end
tg_1_x = tg_1_x + direction * (Naz / 2 + 1);

tg_1_x   = round(tg_1_x);    	% 四舍五入，得到整数值，作为点目标的方位中心坐标。
tg_1_y   = round(Nrg / 2);
target_1 = helpFun5(s_image, tg_1_x, NN, tg_1_y, Fr, Fa, Vr);

tg_2_x   = tg_1_x + delta_R1 / Vr * Fa;
tg_2_y   = tg_1_y;
target_2 = helpFun5(s_image, tg_2_x, NN, tg_2_y, Fr, Fa, Vr);

tg_3_x   = fix(tg_2_x + delta_R2 * tan(sita_r_c) / Vr * Fa);
tg_3_y   = tg_2_y + 2 * delta_R2 / c * Fr;
target_3 = helpFun5(s_image, tg_3_x, NN, tg_3_y, Fr, Fa, Vr);

res.target_1 = target_1;
res.target_2 = target_2;
res.target_3 = target_3;
res.s_image = s_image;
res.s_echo = s_echo;
res.tg_1_x = tg_1_x;
res.tg_1_y = tg_1_y;
res.tg_2_x = tg_2_x;
res.tg_2_y = tg_2_y;
res.tg_3_x = tg_3_x;
res.tg_3_y = tg_3_y;
end

function nc_1 = helpFun(y1, x1, sita_r_c, Vr)
nc_1 = (y1 - x1 * tan(sita_r_c)) / Vr;    % 目标1的波束中心穿越时刻。
end

function helpFun2(idx, fun, s_echo, str0, str1, str2)
subplot(2,2,idx);
imagesc(fun(s_echo));
title(str0);
xlabel(str1);
ylabel(str2);
end

function D_fn_Vr = helpFun3(lamda, fn, Vr)
D_fn_Vr = sqrt(1 - lamda^2  * fn.^2 / (4 * Vr^2));    % 参考频率fn_ref处的徙动因子，是常数。
end

function helpFun4(value,str)
figure
imagesc(abs(value));
title(str);
end

function target_1 = helpFun5(s_image, tg_x, NN, tg_y, Fr, Fa, Vr)
target_1 = target_analysis( s_image(tg_x - NN:tg_x + NN,tg_y - NN:tg_y + NN),Fr,Fa,Vr);
end

function helpFun6(idx,fun1,fun2,value,str)
subplot(2,2,idx);
imagesc(fun1(fun2(value)));
title(str);
end
