function div_data = divide_data(img_dir, fmt)
database = retr_database_dir(img_dir, fmt);

idx_rand = randperm(length(database.path));
part_num=round(length(database.path)/3);
idx{1} = idx_rand(1:part_num)';
idx{2} = idx_rand(part_num+1:2*part_num)';
idx{3} = idx_rand(2*part_num+1:end)';
div_data = cell(3,1);
for i = 1:3
    div_data{i}.path = database.path(idx{i});
    div_data{i}.label = database.label(idx{i});
    div_data{i}.imnum = length(idx{i});
    div_data{i}.nclass = database.nclass;
    div_data{i}.cname = database.cname;
end
end