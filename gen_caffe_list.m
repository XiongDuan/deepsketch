function gen_caffe_list(dbDirs, listpath)
    fid = fopen(listpath, 'w');
    for i = 1:length(dbDirs)
        if exist(fullfile(dbDirs{i},'list.txt'), 'file')
            dblist = importdata(fullfile(dbDirs{i},'list.txt'),'%s');
            for j = 1:length(dblist)
                fprintf('%s\n',dblist{j});
                fprintf(fid, '%s\n', dblist{j});
            end
        else
            dbPath = fullfile(dbDirs{i},'db_info.mat');
            imdb = load(dbPath);
            imdb = imdb.db_info;
            for j = 1:imdb.imnum
                fprintf('%s\n',imdb.path{j});
                fprintf(fid, '%s %d\n', imdb.path{j}, imdb.label(j)-1 );
            end
        end
    end
    fclose(fid);
end