% Add path
clear all;
addpath(genpath('GCmex1.5'));
% addpath(genpath('GCmex1.5'));

% %   1st Image Try
% im = im2double( imread('dog.jpg') );
% % imshow(im);
% 
% % min width: 334
% x1min = 334;
% % max width: 606
% x1max = 606;
% % min height: 135
% y1min = 135;
% % min height: 700
% y1max = 700;


% %   2nd Image Try
% im = im2double( imread('flower.jpg') );
% % imshow(im);
% 
% % min width: 334
% x1min = 91;
% % max width: 606
% x1max = 119;
% % min height: 135
% y1min = 15;
% % min height: 700
% y1max = 189;


% %   3rd Image Try
% im = im2double( imread('girl.jpeg') );
% % imshow(im);
% 
% % min width: 334
% x1min = 1;
% % max width: 606
% x1max = 170;
% % min height: 135
% y1min = 1;
% % min height: 700
% y1max = 168;

%   4th Image Try
im = im2double( imread('obama.jpg') );
% imshow(im);

% min width: 334
x1min = 311;
% max width: 606
x1max = 998;
% min height: 135
y1min = 316;
% min height: 700
y1max = 1304;

% x1 = [334 334 606 606];
% y1 = [135 700 135 700];
% 
% % polyin = polyshape(x1, y1);
% % [xlim, ylim] = boundingbox(polyin);
% 
% xAxis = linspace(x1min, x1max, (x1max - x1min + 1));
% yAxis = linspace(y1min, y1max, (y1max - y1min + 1));
% 
% [xco, yco] = meshgrid(xAxis, yAxis);
% 
% xre = reshape(xco, [1 (size(xco, 1) * size(xco, 2))]);
% yre = reshape(yco, [1 (size(yco, 1) * size(yco, 2))]);
% 
% poly = [xre' yre'];
% 

% im = im2double( imread('cat.jpg') );
org_im = im;

H = size(im, 1); W = size(im, 2); K = 3;
% 
% Load the mask
load cat_poly
inbox = poly2mask(poly(:,1), poly(:,2), size(im, 1), size(im,2));
% imshow(inbox);

maskNew = false(H, W);

maskNew(y1min:y1max, x1min:x1max) = 1;

front = maskNew > 0;

% % 1) Fit Gaussian mixture model for foreground regions
% % [frontX, frontY] = find(inbox == 1);
% front = inbox > 0;
imR = im(:, :, 1);
imG = im(:, :, 2);
imB = im(:, :, 3);

frontR = imR(maskNew);
frontG = imG(maskNew);
frontB = imB(maskNew);
frontX = [frontR frontG frontB];

% scatter3(frontX(:,1),frontX(:,2), frontX(:,3),10,'.'); % Scatter plot with points of size 10
% title('Simulated Data')

options = statset('Display','final');
frontGMM = fitgmdist(frontX,1,'Options',options)

frontM = frontGMM.mu;
frontS = frontGMM.Sigma;
% imshow(frontB);

% frontGMMPDF = pdf('norm', frontGMM);
% hold on
% h = ezcontour(frontGMMPDF,[-8 6],[-8 6], [-8 6]);
% title('Simulated Data and Contour lines of pdf');
% 
% 
% 
% 2) Fit Gaussian mixture model for background regions
back = maskNew < 1;

backR = imR(back);
backG = imG(back);
backB = imB(back);
backX = [backR backG backB];

options = statset('Display','final');
backGMM = fitgmdist(backX,1,'Options',options)

backM = backGMM.mu;
backS = backGMM.Sigma;
% % imshow(frontB);
% 
% % frontGMMPDF = @(x,y)pdf(frontGMM,[x y]);
% % hold on
% % h = ezcontour(gmPDF,[-8 6],[-8 6]);
% % title('Simulated Data and Contour lines of pdf');
% 
% % disp();
% 
% 
% 
% % 3) Prepare the data cost
% % - data [Height x Width x 2] 
% % - data(:,:,1) the cost of assigning pixels to label 1
% % - data(:,:,2) the cost of assigning pixels to label 2
data = zeros(H, W, 2);

for i = 1:H
    for j = 1:W
        meanVar = [im(i, j, 1) - frontM(1, 1) im(i, j, 2) - frontM(1, 2) im(i, j, 3) - frontM(1, 3)];
        data(i, j, 1) = meanVar * inv(frontS) * meanVar';
        
        meanVar2 = [im(i, j, 1) - backM(1, 1) im(i, j, 2) - backM(1, 2) im(i, j, 3) - backM(1, 3)];
        data(i, j, 2) = meanVar2 * inv(backS) * meanVar2';
    end
end
% 
% % figure;
% % imagesc(data(:, :, 1));
% % figure;
% % imagesc(data(:, :, 2));
% 
% 4) Prepare smoothness cost
% - smoothcost [2 x 2]
% - smoothcost(1, 2) = smoothcost(2,1) => the cost if neighboring pixels do not have the same label
smoothCost = [0 10; 10 0];
% 
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

figure;
imshow(segmentedIm);


































