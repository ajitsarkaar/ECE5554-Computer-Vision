clear all;


img = imread('lena.png');
img = im2single(rgb2gray(img));
%imshow(img);

figure;
gaussX = [-0.5, 0, 0.5];
dx = imfilter(img, gaussX);
imshow(dx);

figure;
gaussY = [-0.5, 0, 0.5]';
dy = imfilter(img, gaussY);
imshow(dy);

mags = sqrt( (dx.^2) + (dy.^2) );

figure;
imshow(mags);

