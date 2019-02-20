clear all;
clc;

% Input Image
im = im2double(imread('images/hotel.seq0.png'));
%colormap(gray);
%imshow(im);

% Smooth Image
gaussian = fspecial('gaussian', 3, 1);
filteredImage = imfilter(im, gaussian, 'replicate');
% imshow(filteredImage);

% Image Gradients
[fx, fy] = gradient(filteredImage);

% figure;
% imshow(fx, []);
% figure;
% imshow(fy, []);

% Second Moment Matrix Values
IxSquare = fx .* fx;
IySquare = fy .* fy;
IxIy = fx .* fy;

% figure;
% imshow(IxSquare, []);
% figure;
% imshow(IySquare, []);
% figure;
% imshow(IxIy, []);

% Smoothed Ix, Iy
IxSquare = imfilter(IxSquare, gaussian, 'replicate');
IySquare = imfilter(IySquare, gaussian, 'replicate');
IxIy = imfilter(IxIy, gaussian, 'replicate');

% figure;
% imshow(IxSquare, []);
% figure;
% imshow(IySquare, []);
% figure;
% imshow(IxIy, []);


% Harris Corner Score
momentDeterminant = (IxSquare .* IySquare) - (IxIy.^2);
momentTrace = (IxSquare + IySquare).^2;
alpha = 0.04;
rScore = momentDeterminant - (alpha .* momentTrace);
%imshow(rScore, []);

% Normalize rScore
maxRScore = max(max(rScore));
rScore = rScore ./ maxRScore;

% Non Maximum Suppresion
sze = 13;
nonMaxRScore = ordfilt2(rScore, sze^2, ones(sze));
% figure;
% imagesc(nonMaxRScore);

% Thresholding
thresholdedImage = (rScore == nonMaxRScore) & (rScore > max(max(rScore)) * 0.01);
[r, c] = find(thresholdedImage);

figure;
% imshow(thresholdedImage, []);

imshow(im); hold on;
plot(c, r, 'g+', 'linewidth', 3);
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');






















