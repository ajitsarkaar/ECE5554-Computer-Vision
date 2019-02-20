% Evaluate SLIC implementation

% 
% ECE 5554/4554 Computer Vision, Fall 2017
% Virginia Tech

addpath(genpath('BSR'));
addpath(genpath('superpixel_benchmark'));

% Run the complet benchmark
main_benchmark('evalSlicSetting.txt');

% Report the case with K = 256
cd result;
cd slic;
cd slic_256;
% load('result\slic\slic_256\benchmarkResult.mat');
load('benchmarkResult.mat');
cd ..;
cd ..;
cd ..;

avgRecall   =  mean(imRecall(:));
avgUnderseg =  mean(imUnderseg(:));
fprintf('Average boundary recall = %f for K = 256 \n' , avgRecall);
fprintf('Average underseg error  = %f for K = 256 \n' , avgUnderseg);

% fprintf('Average boundary recall = %f for K = 64 \n' , avgRecall);
% fprintf('Average underseg error  = %f for K = 64 \n' , avgUnderseg);

% fprintf('Average boundary recall = %f for K = 1024 \n' , avgRecall);
% fprintf('Average underseg error  = %f for K = 1024 \n' , avgUnderseg);
