%% Producing Fig. 8 ARS

close all;
warning off;
N = 16;   % Antenna Number
K = 4;    % Users Number
L = 20;   % Length of Frame
power = 1; % Total Transmit Power
amp = sqrt(power / N); % Amplitude of the Transmit Signal

% randn('state',1);
rng("default")
H = (randn(N,K) + 1i * randn(N,K)) / sqrt(2); % Channel

% y = QPSK_mapper(msg_bits).';  % Desired Symbol
y = QPSK_mapper([0,0,0,1,1,1,1,0]).';
y_wave = sqrt(power) *[real(y);imag(y)]; % Equivalent Real Desired Symbol

for ii = N:-1:1
    for nn = 1:L
        fact = 1i * pi * (nn - 1) / L;
        X0(ii,nn) = exp(fact * (2 * ii + nn - 1));  % Reference Radar Signal (LFM)
    end
end
ee = 1; % Inf Norm Similarity
H_wave = amp *[real(H),imag(H);- imag(H),real(H)]; % Equivalent Real Channel
x0 = X0(:,4); %Reference Radar Signal Vector
delta = acos(1 - ee^2 / 2);

l(:,1) = angle(x0) - delta;
u(:,1) = angle(x0) + delta;     %Initialized Upper and Lower Bound

max_iternum = 1000; %Maximum Iteration Number
epsl = 1e-4; %Tolerence
epsl1 = 1e-6;

%------------- Parameter Initialization
[x,LB] = QCQP_LB1( H_wave,y_wave,N,l,u);          %Initialized LB and x
[x_nml1,~] = normalize_UB( H_wave,y_wave,x,N,l,u); %Initialized Normalization UB
[x_nml2,~] = QCQP_UB( H_wave,y_wave,N,l,u,x_nml1); % fmincon UB
[x_nml,UB] = QCQP_UB( H_wave,y_wave,N,l,u,x_nml2); % fmincon UB

prob_list = zeros(max_iternum + 100,4 * N + 1); 
prob_list(1,:) = [x',l',u',LB];
used = 1;
lbest = LB;
ubest = UB;
x_opt = x_nml;

lb_seq = lbest;
ub_seq = ubest;

if (ubest - lbest) / abs(ubest) < epsl
    final_lb = lbest;
    final_ub = ubest;
end

con = 1;
for iter = 2:max_iternum
    xc = prob_list(con,1:2 * N)';
    lc = prob_list(con,(2 * N + 1):3 * N )';
    uc = prob_list(con,(3 * N + 1):4 * N)';

    x_cplx = xc(1:N) + 1i * xc(N + 1:2 * N);
    [x_nml3,~] = normalize_UB( H_wave,y_wave,xc,N,lc,uc);
    x_nml3_cplx = x_nml3(1:N) + 1i * x_nml3(N + 1:2 * N);
    x_abs = abs(x_cplx - x_nml3_cplx);
    [~,cd] = max(x_abs);
    
%     x_abs = abs(x_cplx);
%     [~,cd] = min(x_abs);
    xchild_left_lb = lc;
    xchild_left_ub = uc;
    xchild_right_lb = lc;
    xchild_right_ub = uc;
    tr = (lc(cd) + uc(cd)) / 2;
    xchild_left_ub(cd) = tr;
    xchild_right_lb(cd) = tr;
    
    if con < used
        prob_list(con,:) = prob_list(used,:);
    end
    
    used = used - 1;
    [x,lb] = QCQP_LB1( H_wave,y_wave,N,xchild_left_lb,xchild_left_ub);

%     tic;
%     [xn_temp,ub_temp] = normalize_UB( H_wave,y_wave,x,N,xchild_left_lb,xchild_left_ub);
%     timer2(iter - 1) = toc;

%     [xn,ub] = QCQP_UB( H_wave,y_wave,N,xchild_left_lb,xchild_left_ub,xn_temp);
    
    [xn,ub] = normalize_UB( H_wave,y_wave,x,N,xchild_left_lb,xchild_left_ub);
    [x_opt, prob_list,ubest,used] = helpFun(ub, ubest, x_opt, xn, prob_list, used, x, xchild_left_lb, xchild_left_ub, lb);
    
    [x,lb] = QCQP_LB1( H_wave,y_wave,N,xchild_right_lb,xchild_right_ub);

%     [xn_temp,ub_temp] = normalize_UB( H_wave,y_wave,x,N,xchild_right_lb,xchild_right_ub);
%     [xn,ub] = QCQP_UB( H_wave,y_wave,N,xchild_right_lb,xchild_right_ub,xn_temp);

    [xn,ub] = normalize_UB( H_wave,y_wave,x,N,xchild_right_lb,xchild_right_ub);
    [x_opt, prob_list,ubest,used] = helpFun(ub, ubest, x_opt, xn, prob_list, used, x, xchild_right_lb, xchild_right_ub, lb);
    
    [lbest,con] = min(prob_list(1:used,4 * N + 1));

    lb_seq(iter) = lbest;
    ub_seq(iter) = ubest;
    
    if (ubest - lbest) / abs(ubest) < epsl || (ubest - lbest) < epsl1
        final_lb = lbest;
        final_ub = ubest;
        break;
    end
    disp(['Progress - ',num2str(iter + 1),' /',num2str(max_iternum)]); 
end
    
% timer_tot = sum(timer1) + sum(timer3);%+ sum(timer2)
x_cplx = x_opt(1:N) + 1i * x_opt(N + 1:2 * N); %Optimal Complex Signal Vector
y_rc = amp * H.' * x_cplx; % Noise - free Received Symbol

%Constraints Check
inf_norm = norm(x_cplx - x0,Inf);
elp = abs(x_cplx);

%%
plot(1:numel(lb_seq),lb_seq,'LineWidth',1.5);hold on;plot(1:numel(lb_seq),ub_seq,'LineWidth',1.5);
grid on;

function [x_opt, prob_list,ubest,used] = helpFun(ub, ubest, x_opt, xn, prob_list, used, x, xchild_lb, xchild_ub, lb)
if ub < ubest
    ubest = ub;
    x_opt = xn;
end
prob_list(used + 1,:) = [x',xchild_lb',xchild_ub',lb];
used = used + 1;
end