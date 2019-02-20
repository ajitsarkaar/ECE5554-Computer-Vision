% Add path
addpath(genpath('GCmex1.5'));
im = im2double( imread('cat.jpg') );

%org_im = im;

H = size(im, 1); W = size(im, 2); K = 3;

% Load the mask
load cat_poly
inbox = poly2mask(poly(:,1), poly(:,2), size(im, 1), size(im,2));

% 1) Fit Gaussian mixture model for foreground regions

l = logical(inbox);
redForeground = im(:,:,1);
redForeground = redForeground(l);

greenForeground = im(:,:,2);
greenForeground = greenForeground(l);

blueForeground = im(:,:,3);
blueForeground = blueForeground(l);

hei1 = size(redForeground,1);
newimForeground = zeros(hei1,3);
newimForeground(:,1) = redForeground(:);
newimForeground(:,2) = greenForeground(:);
newimForeground(:,3) = blueForeground(:);

%imshow(newimForeground)

GMMForeground = gmdistribution.fit(newimForeground,5);
pdfForeground = pdf(GMMForeground,reshape(im,[H*W,K]));
pdfForeground = reshape(pdfForeground,[H,W]);
logPDFforeground = -log(pdfForeground);

% colormap(prism);
% imagesc(pdfForeground)

figure(1);
subplot(1,2,1)
imagesc(pdfForeground);
title('Foreground')

figure(2);
subplot(2,1,1)
imagesc(logPDFforeground);

% 2) Fit Gaussian mixture model for background regions

redBackground = im(:,:,1);
redBackground = redBackground(~l);

greenBackground = im(:,:,2);
greenBackground = greenBackground(~l);

blueBackground = im(:,:,3);
blueBackground = blueBackground(~l);

hei2 = size(redBackground,1);
newimBackground = zeros(hei2,3);
newimBackground(:,1) = redBackground(:);
newimBackground(:,2) = greenBackground(:);
newimBackground(:,3) = blueBackground(:);

GMMBackground = gmdistribution.fit(newimBackground,3);
pdfBackground = pdf(GMMBackground,reshape(im,[H*W,K]));
pdfBackground = reshape(pdfBackground,[H,W]);
logPDFbackground = -log(pdfBackground);

colormap(jet);
figure(1);
subplot(1,2,2)
imagesc(pdfBackground);
title('Background')

colormap(jet);
figure(2);
subplot(2,1,2);
imagesc(logPDFbackground);

% 3) Prepare the data cost
% - data [Height x Width x 2] 
data = zeros(H,W,2);
% - data(:,:,1) the cost of assigning pixels to label 1
data(:,:,1) = logPDFforeground;
% - data(:,:,2) the cost of assigning pixels to label 2
data(:,:,2) = logPDFbackground;

% 4) Prepare smoothness cost
% - smoothcost [2 x 2]
% smoothcost = zeros(2,2);
% - smoothcost(1, 2) = smoothcost(2,1) => the cost if neighboring pixels do not have the same label
smoothcost = [0 1;1 0];

% 5) Prepare contrast sensitive cost
% - vC: [Height x Width]: vC = 2-exp(-gy/(2*sigma)); 
% - hC: [Height x Width]: hC = 2-exp(-gx/(2*sigma));
sigma = 0.001;
red = im(:,:,1);
green = im(:,:,2);
blue = im(:,:,3);

[rxgrad,rygrad] = gradient(red);
[gxgrad,gygrad] = gradient(green);
[bxgrad,bygrad] = gradient(blue);

gx = sqrt(rxgrad.^2 + gxgrad.^2 + bxgrad.^2);
gy = sqrt(rygrad.^2 + gygrad.^2 + bygrad.^2);

vC = 2 - exp(-gy/(2*sigma));
hC = 2 - exp(-gx/(2*sigma));

% 6) Solve the labeling using graph cut
% - Check the function GraphCut
[gch] = GraphCut('open', data, smoothcost, vC, hC);

% For Visualization
[gch labels] = GraphCut('expand', gch);
% 7) Visualize the results
red(labels==1) = 0;
green(labels==1) = 0;
blue(labels==1) = 1;

graphcutIm = zeros(H, W, 3);
graphcutIm(:,:,1) = red;
graphcutIm(:,:,2) = green;
graphcutIm(:,:,3) = blue;

figure(3);
imshow(graphcutIm);
