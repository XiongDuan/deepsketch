%%
% This project need download Piotr's Matlab Toolbox ( https://pdollar.github.io/toolbox/), 
% edgebox-toolbox( https://github.com/pdollar/edges ) 
% and caffe( https://github.com/BVLC/caffe ) to support
% For the windows caffe, you can setup your environment by using(
% https://github.com/happynear/caffe-windows )
% 
%%
% Note that we did our project in the path of 'caffe-windows-master\matlab\demo'
% you need put the './edges-master/' and './piotr_toolbox' in it. 
%%
%%
addpath(genpath('./edges-master/'));
addpath(genpath('./piotr_toolbox'));
savepath;

sketch_dir = 'H:\code_sketch_caffe\cnn\data\png';
image_dir = 'H:\code_sketch_caffe\cnn\data\jpg';
sketch_processed_dir = '../sketch';
image_processed_dir = '../image';
image_edge_processed_dir = '../imageEdge';
edgemodel = load('./edgemodel.mat','model');
train_size = 227;

%% split the dataset for three parts; two parts for trainning and the remaining one for test
if ~exist('sketch_div_db.mat','file')
    sketch_div_db = divide_data(sketch_dir, '*.png');
    save('sketch_div_db.mat','sketch_div_db');
else
    load('sketch_div_db.mat','sketch_div_db');
end
if ~exist('image_div_db.mat','file')
    image_div_db = divide_data(image_dir, '*.jpg');
    save('image_div_db.mat','image_div_db');
else
    load('image_div_db.mat','image_div_db');
end
%% sketch augmentation, rotate, flip and edge preserving resize
for i=1:3
    subdir = fullfile(sketch_processed_dir,['part',num2str(i)]);
    prepare_data(sketch_div_db{i}, train_size, subdir, @edge_preserving_resize, false);
end
%% natural image edge maps (extract edge maps from the natural images) augmentation, crop and flip
for i=3
    subdir = fullfile(image_edge_processed_dir,['part',num2str(i)]);
    prepare_data(image_div_db{i}, train_size, subdir, @nature_image_resize, edgemodel.model);
end
%% natural images augmentation, crop and flip 
for i=1:3
    subdir = fullfile(image_processed_dir,['part',num2str(i)]);
    prepare_data(image_div_db{i}, train_size, subdir, @nature_image_resize, false);
    
end
%% prepare the caffe train_list and val_list
gen_caffe_list({'../sketch/part1','../sketch/part2', ...
    '../image/part1', '../image/part2', ...
    '../imageEdge/part1','../imageEdge/part2'}, 'train_list.txt');
gen_caffe_list({'../sketch/part3'}, 'val_list.txt');
%%
!convert_dataset.bat
!finetune.bat
%%
voting_test('../sketch/part3/');


