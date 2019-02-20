function F = HW3_SfM
close all;

folder = 'images/';
im = readImages(folder, 0:50);

load './tracks.mat';


figure(2), imagesc(im{1}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r')
figure(3), imagesc(im{end}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r')
%pause;

valid = ~any(isnan(track_x), 2) & ~any(isnan(track_y), 2); 

[R, S] = affineSFM(track_x(valid, :), track_y(valid, :));

plotSfM(R, S);



function [R, S] = affineSFM(x, y)
% Function: Affine structure from motion algorithm

% Normalize x, y to zero mean
normX = zeros(size(x, 1), size(x, 2));
normY = zeros(size(y, 1), size(y, 2));

for i = 1:size(x, 2)
    normX(:, i) = x(:, i) - mean(x(:, i));
    normY(:, i) = y(:, i) - mean(y(:, i));
end

xn = normX;
yn = normY;

% Create measurement matrix
D = [xn' ; yn'];

% Decompose and enforce rank 3
[U, W, V] = svd(D);
U3 = U(:, 1:3);
W3 = W(1:3, 1:3);
V3 = V(:, 1:3);

A = U3 * sqrtm(W3);
S = sqrtm(W3) * V3';

aTop = A(1:i, :);
aBottom = A(i+1:end, :);
aSolved = zeros(3 * i, 9);
b = zeros(i, 1);

for j = 1:i
    aSolved(j, :) = reshape(aTop(j, :)' * aTop(j, :), [1 9]);
    aSolved(j+i, :) = reshape(aBottom(j, :)' * aBottom(j, :), [1 9]);
    aSolved(j + (2*i), :) = reshape(aTop(j, :)' * aBottom(j, :), [1 9]);
    b(j) = 1;
    b(j + i) = 1;
    b(j + (2 * i)) = 0;
end

L = reshape(aSolved \ b, [3 3]);
C = chol(L, 'upper')
A = A * C;
S = inv(C) * S;
R = A;
% Apply orthographic constraints


function im = readImages(folder, nums)
im = cell(numel(nums),1);
t = 0;
for k = nums,
    t = t+1;
    im{t} = imread(fullfile(folder, ['hotel.seq' num2str(k) '.png']));
    im{t} = im2single(im{t});
end
