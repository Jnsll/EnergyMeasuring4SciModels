easy = 1;
Method_name = 'SeAFusion';
row_name = 'A1';
row_data = 'A2';

path1 = fullfile('..','Image','Source-Image','TNO');
fileFolder = fullfile(path1,'ir');
dirOutput = dir(fullfile(fileFolder,'*.*'));
fileNames = {dirOutput(3:end).name}; % first two items are '.' and '..' folders
num = size(fileNames,2);
ir_dir = fullfile(path1,'ir');
vi_dir = fullfile(path1,'vi');
Fused_dir = fullfile('..','Image','Algorithm','SeAFusion_TNO');

zeroArray = zeros(1,num);
EN_set = zeroArray;
SF_set = zeroArray;
SD_set = zeroArray;
PSNR_set = zeroArray;
MSE_set = zeroArray;
MI_set = zeroArray;
VIF_set = zeroArray;
AG_set = zeroArray;
CC_set = zeroArray;
SCD_set = zeroArray;
Qabf_set = zeroArray;
SSIM_set = zeroArray;
MS_SSIM_set = zeroArray;
Nabf_set = zeroArray;
FMI_pixel_set = zeroArray;
FMI_dct_set = zeroArray;
FMI_w_set = zeroArray;

for j = 1:num
    fileName_source_ir = fullfile(ir_dir, fileNames{j});
    fileName_source_vi = fullfile(vi_dir, fileNames{j});
    fileName_Fusion = fullfile(Fused_dir, fileNames{j});

    ir_image = imread(fileName_source_ir);
    vi_image = imread(fileName_source_vi);
    fused_image   = imread(fileName_Fusion);

    ir_image = helpFun(ir_image);
    vi_image = helpFun(vi_image);
    fused_image = helpFun(fused_image);

    ir_size = size(ir_image);
    vi_size = size(vi_image);
    fusion_size = size(fused_image);

    % previous check for size of image dimensions is obsolete because
    % images are forced to be gray-scale-images by applying rgb2gray.

    [EN, SF,SD,PSNR,MSE, MI, VIF, AG, CC, SCD, Qabf, Nabf, SSIM, MS_SSIM, FMI_pixel, FMI_dct, FMI_w] = ...
        analysis_Reference(fused_image,ir_image,vi_image, easy);

    EN_set(j) = EN;
    SF_set(j) = SF;
    SD_set(j) = SD;
    PSNR_set(j) = PSNR;
    MSE_set(j) = MSE;
    MI_set(j) = MI;
    VIF_set(j) = VIF;
    AG_set(j) = AG;
    CC_set(j) = CC;
    SCD_set(j) = SCD;
    Qabf_set(j) = Qabf;
    Nabf_set(j) = Nabf;
    SSIM_set(j) = SSIM;
    MS_SSIM_set(j) = MS_SSIM;
    FMI_pixel_set(j) = FMI_pixel;
    FMI_dct_set(j) = FMI_dct;
    FMI_w_set(j) = FMI_w;

    fprintf('Fusion Method:%s, Image Name: %s\n', Method_name, fileNames{j})
end

save_dir = fullfile('..','Metric'); %存放Excel结果的文件夹

if exist(save_dir,'dir') == 0
    mkdir(save_dir);
end

file_name = fullfile(save_dir, ['Metric_', Method_name, '.xlsx']); %存放Excel文件的文件名

method_name = cellstr(Method_name);
method_table = table(method_name);

SD_table = helpFun2(SD_set, file_name, 'SD', row_data, method_table, row_name);
PSNR_table = helpFun2(PSNR_set, file_name, 'PSNR', row_data, method_table, row_name);
MSE_table = helpFun2(MSE_set, file_name, 'MSE', row_data, method_table, row_name);
MI_table = helpFun2(MI_set, file_name, 'MI', row_data, method_table, row_name);
VIF_table = helpFun2(VIF_set, file_name, 'VIF', row_data, method_table, row_name);
AG_table = helpFun2(AG_set, file_name, 'AG', row_data, method_table, row_name);
CC_table = helpFun2(CC_set, file_name, 'CC', row_data, method_table, row_name);
SCD_table = helpFun2(SCD_set, file_name, 'SCD', row_data, method_table, row_name);
EN_table = helpFun2(EN_set, file_name, 'EN', row_data, method_table, row_name);
Qabf_table = helpFun2(Qabf_set, file_name, 'Qabf', row_data, method_table, row_name);
SF_table = helpFun2(SF_set, file_name, 'SF', row_data, method_table, row_name);

function image = helpFun(image)
if size(image, 3) > 2
    image = rgb2gray(image);
end
end

function data_table = helpFun2(data_set, file_name, sheetName, row_data, method_table, row_name)
data_table = table(data_set');
writetable(data_table,file_name,'Sheet',sheetName,'Range',row_data);
writetable(method_table,file_name,'Sheet',sheetName,'Range',row_name);
end