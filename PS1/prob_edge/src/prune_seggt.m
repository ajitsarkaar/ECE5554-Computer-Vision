% prune_seggt.m

maindir = '../../'; % this may need to change depending on your src location
ids = load(fullfile(maindir, 'iids_test.txt'));
imdir = fullfile(maindir, 'test');
gtdir = fullfile(maindir, 'BSDS300\human\color\');

files = dir(fullfile(gtdir, '*'));
subjid = {files.name};
for k = 1:numel(subjid)
  if subjid{k}(1)=='.', continue; end
  files = dir(fullfile(gtdir, subjid{k}, '*'));
  fn = {files.name};
  for f = 1:numel(fn)
    if fn{f}(1)=='.', continue; end
    id = str2num(strtok(fn{f}, '.'));
    if any(id==ids)
      if ~exist(fullfile(maindir, 'gt', subjid{k}), 'file')
        mkdir(fullfile(maindir, 'gt', subjid{k}));
      end
      copyfile(fullfile(gtdir, subjid{k}, fn{f}), fullfile(maindir, 'gt', subjid{k}, fn{f}));
    end
  end
end

