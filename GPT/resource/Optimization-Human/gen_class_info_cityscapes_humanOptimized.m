
function res = gen_class_info_cityscapes_humanOptimized()

class_info = [];

class_info.class_names = {'road', 'sidewalk', 'building', 'wall', 'fence', 'pole', 'trafficlight',...
     'trafficsign', 'vegetation', 'terrain', 'sky', 'person', 'rider', 'car', ...
     'truck', 'bus', 'train', 'motorcycle', 'bicycle', 'void'};

 
class_label_values = uint8([0:18,255]);
       

class_info.class_label_values = class_label_values;
class_info.background_label_value = uint8(0);
class_info.void_label_values = uint8(255);

cmap = uint8(load('cityscape_cmap.mat').cityscape_cmap);
class_info.mask_cmap = im2double(cmap);

class_info = process_class_info(class_info);

res = class_info;
end


