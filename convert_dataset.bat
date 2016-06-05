SET GLOG_logtostderr=1
rmdir G:\caffedata\train-leveldb /s/q
"..\..\bin\convert_imageset.exe" .\ train_list.txt "G:\caffedata\train-leveldb" 1 --backend=leveldb

rmdir G:\caffedata\val-leveldb /s/q
"..\..\bin\convert_imageset.exe" .\ .\val_list.txt "G:\caffedata\val-leveldb" 1 --backend=leveldb

del G:\caffedata\mean.binaryproto 
"..\..\bin\compute_image_mean.exe" G:\caffedata\train-leveldb G:\caffedata\mean.binaryproto --backend=leveldb

pause