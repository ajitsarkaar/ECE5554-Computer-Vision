clear all;
clc;

%% Input Image
im = imread('images/hotel.seq0.png');
%colormap(gray);
%imshow(im);

%% Derivatives Formation
im = im2double(imread('images/hotel.seq0.png'));
gaussian = fspecial('gaussian', 5, 1);
fx = imfilter(gaussian, [-1, 1]);
fy = imfilter(gaussian, [1; -1]);
gx = imfilter(im, fx);
gy = imfilter(im, fy);
colormap(gray);
%figure(1);
%imshow(gx, []);
%figure(2);
%imshow(gy, []);

[row, col] = size(gx);

gaussianWeights = fspecial('gaussian', 3, 1);
r = zeros(size(gx));

for i = 2:row-1
    for j= 2:col-1
        imageWindowX = gx(i-1:i+1, j-1:j+1);
        imageWindowY = gy(i-1:i+1, j-1:j+1);
        Ix2 = sum(sum(gaussianWeights .* (imageWindowX.^2)));
        Iy2 = sum(sum(gaussianWeights .* (imageWindowY.^2)));
        r(i, j) = (Ix2*Iy2) - (0.05*(Ix2 + Iy2)^2);
    end
end
figure;
%colormap(hsv);
imshow(r, []);
title('R');

%% Obtain Gradients
sobelOperatorY = [1, 2, 1;
                  0, 0, 0;
                 -1, -2, -1];

sobelOperatorX = [1, 0, -1;
                  2, 0, -2;
                  1, 0, -1];
filtImX = imfilter(im, sobelOperatorX);
figure(2);
imshow(filtImX);

filtImY = imfilter(im, sobelOperatorY);
figure(3);
imshow(filtImY);