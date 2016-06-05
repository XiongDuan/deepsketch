function voting_test(dbPath)
[net, IMAGE_MEAN] = set_net();
IMAGE_DIM = 227;
% first, record all the augmentation images set
subfolders = dir(dbPath);
voteclass = {};
for ii = 1:length(subfolders)
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..') && subfolders(ii).isdir
        voteclass = [voteclass, fullfile(dbPath, subname)];
    end
end
% in order to find all the coresponding sketches, we base the sketch path of the first class 
% and then change it.
baseclass = voteclass{1};
imdb = retr_database_dir(baseclass, '*.jpg');
predictRightNum = 0;
for i = 1:imdb.imnum
    imgPath = imdb.path{i}; % the base imgPath
    imgLabel = imdb.label(i);
    vote_data = zeros(IMAGE_DIM, IMAGE_DIM, 3, 18, 'single');
    fprintf('processing %s\n.', imgPath(length(baseclass)+1:end));
    for jj = 1:18
        votePath = [voteclass{jj}, imgPath(length(baseclass)+1:end)];   % the each vote image path
        im = imread(votePath);
        % Convert an image returned by Matlab's imread to im_data in caffe's data
        % format: W x H x C with BGR channels
        im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
        im_data = permute(im_data, [2, 1, 3]);  % flip width and height
        im_data = single(im_data);  % convert from uint8 to single
        im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
        im_data = im_data - IMAGE_MEAN;  % subtract mean_data (already in W x H x C, BGR)
        vote_data(:,:,:,jj) = im_data;
    end
    input_data = {vote_data};
    tic;
    scores = net.forward(input_data);
    toc;
    scores = scores{1};
    scores = mean(scores, 2);  % take average scores over 18 images
    [~, maxlabel] = max(scores);
    predictRightNum = predictRightNum + (imgLabel == maxlabel);
end
accuracy = predictRightNum/imdb.imnum;
fprintf('accuracy is %f(%d / %d)\n',accuracy, predictRightNum, imdb.imnum);
end



function [net, IMAGE_MEAN] = set_net()
    use_gpu = 1;
    % Add caffe/matlab to you Matlab search PATH to use matcaffe
    if exist('../+caffe', 'dir')
      addpath('..');
    else
      error('Please run this demo from caffe/matlab/demo');
    end

    % Set caffe mode
    if exist('use_gpu', 'var') && use_gpu
      caffe.set_mode_gpu();
      gpu_id = 0;  % we will use the first gpu in this demo
      caffe.set_device(gpu_id);
    else
      caffe.set_mode_cpu();
    end

    % Initialize the network using BVLC CaffeNet for image classification
    % Weights (parameter) file needs to be downloaded from Model Zoo.
    model_dir = '../models/';
    net_model = [model_dir 'deploy.prototxt'];
    net_weights = [model_dir 'sketch_net_iter_160000.caffemodel'];
    mean_file = [model_dir 'mean.mat']; 
    % binary_mean_file = [model_dir 'mean.binary'];
    if ~exist(mean_file, 'file')
        binary_mean_path = 'G:\caffedata\mean.binaryproto';
        image_mean = caffe.read_mean(binary_mean_path);
        save(mean_file, 'image_mean');
    end
    phase = 'test'; % run with phase test (so that dropout isn't applied)
    if ~exist(net_weights, 'file')
        error('Please download CaffeNet from Model Zoo before you run this demo');
    end

    % Initialize a network
    net = caffe.Net(net_model, net_weights, phase);
    % load the mean file
    d = load(mean_file);
    image_mean = d.image_mean;
    IMAGE_MEAN = image_mean(:,:,[3,2,1]);
end


