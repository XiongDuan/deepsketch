function gen_caffe_list(dbDirs, listpath)
    fid = fopen(listpath, 'w');
    for i = 1:length(dbDirs)
        dbPath = fullfile(dbDirs{i},'db_info.mat');
        imdb = load(dbPath);
        imdb = imdb.db_info;
        for j = 1:imdb.imnum
%             imdb.path{j}(strfind(imdb.path{j}, ' ')) = '_';
            I=imread(imdb.path{j});
            fprintf('%s\n',imdb.path{j});
            fprintf(fid, '%s %d\n', imdb.path{j}, imdb.label(j)-1 );
        end
    end
    fclose(fid);
end
