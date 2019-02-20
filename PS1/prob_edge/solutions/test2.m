clear all;

im = imread('ronaldo.jpg');
figure(3);
subplot(1, 2, 1);
imshow(im);

subplot(1, 2, 2);
b1 = edgeGradient(im);
imshow(b1, []);

figure(4);
b2 = edgeOrientedFilters(im);
imshow(b2, []);

% 
% im2 = imread('ronalo.jpg');
% figure(4);
% subplot(1, 3, 1);
% imshow(im2);
% 
% subplot(1, 3, 2);
% c1 = edgeGradient(im2);
% imshow(c1, []);
% 
% subplot(1, 3, 3);
% c2 = edgeOrientedFilters(im2);
% imshow(c1, []);

