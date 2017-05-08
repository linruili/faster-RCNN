function prePath =  getPrePath (path)

prePath = '/';
each = strsplit(path, '/');
[row, col]=size(each);
for i=2:col-1,
    prePath = fullfile(prePath,each{i});
end