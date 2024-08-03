%%
close all;

%%
data_g = load('face1.asc');     % 导入face1的点集
data_p = rotate(data_g, 60);    % 将face1的点集向上旋转20度，表示为face2
save_3d_data('face2.txt', data_p);

helpFun(data_g, data_p);

%%
cnt = 0;
last_error = 0;
R = 1;

% 当误差收敛时，停止循环
while cnt == 0 || abs(error - last_error) > 0.01
    if cnt > 0
        last_error = error;
    end
    last_R = R;
    cnt = cnt + 1;

    [ data_g, data_p, error, data_pp, R ] = icp_process( data_g, data_p );

    R = last_R * R;
    
    log_info(['迭代次数：', num2str(cnt), '，误差：', num2str(error)]);
    log_info('当前旋转矩阵为：');
    disp(R);
end

helpFun(data_g, data_p);

function helpFun(data_g, data_p)
plot_3d_2(data_g, data_p,-90);
end