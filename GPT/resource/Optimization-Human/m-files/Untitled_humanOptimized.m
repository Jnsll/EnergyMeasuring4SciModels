fushe = readmatrix('cumcm.xls','sheet','sheet','Range','E4:K8763');
dc = readmatrix('cumcm.xls','sheet','sheet1','Range','B1:K24');
nbq = readmatrix('cumcm.xls','sheet','sheet2','Range','A1:M18');%逆变器的信息
d = readmatrix('cumcm.xls','sheet','sheet3','Range','A27:D37304');%排列信息

sp_zs = fushe(:,1) - fushe(:,2);
n_zs = helpFun(fushe,5);
d_zs = helpFun(fushe,4);
x_zs = helpFun(fushe,6);

N = 23;%各面的面积

a =  pi / 2;%倾斜角
b = -pi / 2;%方位角
S = zeros(1,N + 1);
for m = 1:N + 1

    sa = sin(a);
    ca = cos(a);
    sb = sin(b);
    cb = cos(b);

    sum1 = n_zs * sa * cb + sp_zs * ca + fushe(:,2) * (pi - a) / pi;
    fact = sa * sb;
    if sb < 0
        fushe_ry = -d_zs * fact + sum1;
    else
        fushe_ry = x_zs * fact + sum1;
    end

    for k = 1:8760
        if fushe_ry(k) < dc(m,9)
            fushe_ry(k) = 0;
        end
        
        if fushe_ry(k) < 200
            fushe_ry(k) = fushe_ry(k) * dc(m,8);
        end
        fushe_ry(k) = fushe_ry(k) * dc(m,10);
    end
    S(m) = sum(fushe_ry * dc(m,1)) / 1000000;
end

S = S';
c = S;

maxIdx = 37278;
Q = zeros(maxIdx,9);
r = false(maxIdx,9);
for i = 1:maxIdx
    fact0 = d(i,3) * d(i,4);
    fact1 = fact0 * c(d(i,2));
    fact2 = nbq(d(i,1),10);

    q = fact1 * fact2 * 0.5 * 31.5 - nbq(d(i,1),13) - fact0 * dc(d(i,2),6);

    fact3 = fact0 * dc(d(i,2),7);

    q_ = q / fact3;
    Q(i,:) = [d(i,:),q,fact1 * fact2 * 0.5,q_,fact3,c(d(i,2))];

    if fact3 > N
        r(i) = true;
    end
end
Q(r,:) = [];

function output = helpFun(fushe,idx)
output = fushe(:,idx) - 0.5 * fushe(:,2);
end