function db_info = prepare_data(img_db, img_size, save_dir, resize_function, para)
augmentation_range = [-4:4];
if ~isdir(save_dir)
    mkdir(save_dir);
end

parfor aug = augmentation_range
    augdir = fullfile(save_dir, num2str(aug));
    augdir_flip = fullfile(save_dir, [num2str(aug),'_flip']);
    if ~isdir(augdir)
        mkdir(augdir);
    end
    if ~isdir(augdir_flip)
        mkdir(augdir_flip);
    end
%    parpool;
   for i = 1:img_db.imnum  
        fprintf('processing (aug: %d) %d of %d\n', aug, i, img_db.imnum);
        img_label = img_db.label(i);
        img_path = img_db.path{i};
        [~,filename] = fileparts(img_path);
        classname = img_db.cname{img_label};
        classname(strfind(classname, ' ')) = '_';
        classdir = fullfile(augdir, classname);
        classdir_flip = fullfile(augdir_flip, classname);
        if exist(fullfile(classdir_flip, [filename, '.jpg']),'file')
            continue
        end
        if ~isdir(classdir)
            mkdir(classdir)
        end
        if ~isdir(classdir_flip)
            mkdir(classdir_flip)
        end
        img = imread(img_path);
        img_rz = resize_function(img, img_size, aug, para);
        img_rzfl = fliplr(img_rz);
        if size(img_rz,3)==1
            img_rz = cat(3,img_rz,img_rz,img_rz);
            img_rzfl = cat(3,img_rzfl,img_rzfl,img_rzfl);
        end
        imwrite(img_rz, fullfile(classdir, [filename, '.jpg']), 'jpg');
        imwrite(img_rzfl, fullfile(classdir_flip, [filename, '.jpg']), 'jpg');
   end 
%    delete(gcp);
end
preparePath(img_db, augmentation_range, save_dir);
end


function preparePath(img_db, augmentation_range, save_dir)
db_info.path = {};
db_info.label = [];
db_info.nclass = img_db.nclass;
db_info.cname = img_db.cname;
fid = fopen(fullfile(save_dir,'list.txt'), 'w');
for aug = augmentation_range
    augdir = fullfile(save_dir, num2str(aug));
    augdir_flip = fullfile(save_dir, [num2str(aug),'_flip']);
   for i = 1:img_db.imnum     
        img_label = img_db.label(i);
        img_path = img_db.path{i};
        [~,filename] = fileparts(img_path);
        classname = img_db.cname{img_label};
        classname(strfind(classname, ' ')) = '_';
        classdir = fullfile(augdir, classname);
        classdir_flip = fullfile(augdir_flip, classname);
        db_info.path = [db_info.path, fullfile(classdir, [filename, '.jpg']), fullfile(classdir_flip, [filename, '.jpg'])];
        db_info.label = [db_info.label, img_label, img_label];
        fprintf('path (aug: %d) %d of %d\n', aug, i, img_db.imnum);
        fprintf(fid, '%s %d\n', fullfile(classdir, [filename, '.jpg']), img_label-1 );
        fprintf(fid, '%s %d\n', fullfile(classdir_flip, [filename, '.jpg']), img_label-1 );
   end   
end
db_info.imnum = length(db_info.path);
fclose(fid);
save(fullfile(save_dir,'db_info'),'db_info');
end


