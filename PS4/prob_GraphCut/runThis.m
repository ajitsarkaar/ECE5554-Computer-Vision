% Add path
clear all;
addpath(genpath('GCmex1.5'));
im = im2double( imread('cat.jpg') );

org_im = im;

H = size(im, 1); W = size(im, 2); K = 3;

% Load the mask
load cat_poly
inbox = poly2mask(poly(:,1), poly(:,2), size(im, 1), size(im,2));
parameters = 4;

figure;
imshow(inbox);


% 1) Fit Gaussian mixture model for foreground regions
% [frontX, frontY] = find(inbox == 1);
front = inbox > 0;
imR = im(:, :, 1);
imG = im(:, :, 2);
imB = im(:, :, 3);

frontR = imR(inbox);
frontG = imG(inbox);
frontB = imB(inbox);
frontX = [frontR frontG frontB];

% scatter3(frontX(:,1),frontX(:,2), frontX(:,3),10,'.'); % Scatter plot with points of size 10
% title('Simulated Data')

options = statset('Display','final');
frontGMM = fitgmdist(frontX,1,'Options',options)

frontM = frontGMM.mu;
frontS = frontGMM.Sigma;

frontPDF = pdf(frontGMM, reshape(im, [H*W K]));
frontPDF = reshape(frontPDF, [H W]);

colormap jet
figure(1);
imagesc(frontPDF);
title('Foreground');

% imshow(frontB);

% frontGMMPDF = pdf('norm', frontGMM);
% hold on
% h = ezcontour(frontGMMPDF,[-8 6],[-8 6], [-8 6]);
% title('Simulated Data and Contour lines of pdf');



% 2) Fit Gaussian mixture model for background regions
back = inbox < 1;

backR = imR(back);
backG = imG(back);
backB = imB(back);
backX = [backR backG backB];

options = statset('Display','final');
backGMM = fitgmdist(backX,1,'Options',options)

backM = backGMM.mu;
backS = backGMM.Sigma;

backPDF = pdf(backGMM, reshape(im, [H*W K]));
backPDF = reshape(backPDF, [H W]);

colormap jet
figure(2);
imagesc(backPDF);
title('Background');

% imshow(frontB);

% frontGMMPDF = @(x,y)pdf(frontGMM,[x y]);
% hold on
% h = ezcontour(gmPDF,[-8 6],[-8 6]);
% title('Simulated Data and Contour lines of pdf');

% disp();



% 3) Prepare the data cost
% - data [Height x Width x 2] 
% - data(:,:,1) the cost of assigning pixels to label 1
% - data(:,:,2) the cost of assigning pixels to label 2
data = zeros(H, W, 2);

for i = 1:H
    for j = 1:W
        meanVar = [im(i, j, 1) - frontM(1, 1) im(i, j, 2) - frontM(1, 2) im(i, j, 3) - frontM(1, 3)];
        data(i, j, 1) = meanVar * inv(frontS) * meanVar';
        
        meanVar2 = [im(i, j, 1) - backM(1, 1) im(i, j, 2) - backM(1, 2) im(i, j, 3) - backM(1, 3)];
        data(i, j, 2) = meanVar2 * inv(backS) * meanVar2';
    end
end

colormap jet
figure(3);
imagesc(data(:, :, 1));
colormap jet
figure(4);
imagesc(data(:, :, 2));

% 4) Prepare smoothness cost
% - smoothcost [2 x 2]
% - smoothcost(1, 2) = smoothcost(2,1) => the cost if neighboring pixels do not have the same label
smoothCost = [0 1; 1 0];

% 5) Prepare contrast sensitive cost
% - vC: [Height x Width]: vC = 2-exp(-gy/(2*sigma)); 
% - hC: [Height x Width]: hC = 2-exp(-gx/(2*sigma));
[imgRDX, imgRDY] = gradient(imR);
[imgGDX, imgGDY] = gradient(imG);
[imgBDX, imgBDY] = gradient(imB);

gx = sqrt(imgRDX.^2 + imgGDX.^2 + imgBDX.^2);
gy = sqrt(imgRDY.^2 + imgGDY.^2 + imgBDY.^2);

sigma = 0.001;
vC = 2-exp(-gy/(2*sigma)); 
hC = 2-exp(-gx/(2*sigma));

% 6) Solve the labeling using graph cut
% - Check the function GraphCut
[gch] = GraphCut('open', data, smoothCost, vC, hC);


% 7) Visualize the results
[gch labels] = GraphCut('expand', gch, 100);

redIm = im(:, :, 1);
redIm(labels==1) = 0;

greenIm = im(:,:,2);
greenIm(labels==1) = 0;

blueIm = im(:,:,3);
blueIm(labels==1) = 1;


segmentedIm = zeros(H, W, K);
segmentedIm(:, :, 1) = redIm;
segmentedIm(:, :, 2) = greenIm;
segmentedIm(:, :, 3) = blueIm;

figure(5);
imshow(segmentedIm);


































