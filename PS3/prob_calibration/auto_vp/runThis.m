%% Evaluation script for vanishing point detection and camera calibration
%
% Jia-Bin Huang

%%
clear
addpath('lsd-1.5');
addpath('JLinkage');

% A subset of YorkUrban dataset
datasetPath = 'YorkUrbanDB';

% Loading groundtruth camera parameters: [focal, pixelSize, pp]
load(fullfile(datasetPath, 'cameraParameters.mat'));

% Image list
imgDir = dir(fullfile(datasetPath, '*.jpg'));
numImg = length(imgDir);

% Process imagess
for i = 1: numImg
    imgName = imgDir(i).name;
    
    % Load image
    imgColor = imread(fullfile(datasetPath, imgName));
    img = rgb2gray(imgColor);
    img = im2double(img);
    
    % Line segment detection
    lines = lsd(img*255);
    save([imgName(1:end-4),'.mat'], 'lines');
    
    % Vanishing point detection from line segments
%     [VP, lineLabel] = vpDetectionFromLines(lines);
%           
%     % === Visualization ===
%     visLineSegForVP(imgColor, lines, lineLabel, VP, imgName(1:end-4));
    
end