

for idx = 1:1000
    loadRes = load('loadData_data1.mat');
    input_test = loadRes.input_test;
    input_train = loadRes.input_train;
    output_test = loadRes.output_test;
    output_train = loadRes.output_train;
    loadRes = load('loadData_data2.mat');
    dxg = loadRes.dxg;
    gjhy = loadRes.gjhy;
    hgsc = loadRes.hgsc;
end
