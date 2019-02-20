function F = HW3_FundamentalMatrix
close all;

im1 = im2double(imread('chapel00.png'));
im2 = im2double(imread('chapel01.png'));
load 'matches.mat';

[F, inliers] = ransacF(c1(matches(:, 1)), r1(matches(:, 1)), c2(matches(:, 2)), r2(matches(:, 2)), im1, im2);

% display F
normF = F / sqrt(sum(sum(F .^ 2)))
outliers = setdiff(1:size(matches, 1), inliers);
outliersSize = size(outliers, 2)

% plot outliers
inlierPoints = matches(inliers, :);
outlierPoints = matches(outliers, :);

% figure(1);
% plotmatches(im1, im2, [c1 r1]', [c2 r2]', matches');
% title('MATCHES');
% 
% figure(2)
% plotmatches(im1, im2, [c1 r1]', [c2 r2]', matches(inliers, :)');
% title('INLIERS');
% 
% figure(3)
% plotmatches(im1, im2, [c1 r1]', [c2 r2]', matches(outliers, :)');
% title('OUTLIERS');

figure(1);
imshow(im1);
hold on;
plot(c1(outlierPoints(:, 1)), r1(outlierPoints(:, 1)), '.g', 'MarkerSize', 8);
plot(c1(inlierPoints(:, 1)), r1(inlierPoints(:, 1)), '.r', 'MarkerSize', 8);
hold off;
title('OUTLIERS');

% display epipolar lines
randomInd = randsample(size(inliers, 2), 7);
selectedPoints = inliers(randomInd);

figure(2);
imshow(im1);
title('1ST IMAGE');
hold on;

figure(3);
imshow(im2);
title('2ND IMAGE');
hold on;

for i = 1:7
    matchingPoint = matches(selectedPoints(i), :);
    
    x1 = c1(matchingPoint(1));
    y1 = r1(matchingPoint(1));
    x2 = c2(matchingPoint(2));
    y2 = r2(matchingPoint(2));
    
    lineInImage1 = normF * [x2 y2 1]';
    lineInImage2 = normF * [x1 y1 1]';
    
    xPlane = 1:0.1:550;
    
    yPlane1 = -(lineInImage1(1) * xPlane + lineInImage1(3)) / lineInImage1(2);
    yPlane2 = -(lineInImage2(1) * xPlane + lineInImage2(3)) / lineInImage2(2);
    
    figure(2);
    hold on;
    plot(x1, y1, '+r', 'MarkerSize', 10);
    plot(xPlane, yPlane1, 'g');
    
    figure(3);
    hold on;
    plot(x2, y2, '+r', 'MarkerSize', 10);
    plot(xPlane, yPlane2, 'g');
end



function [bestF, best] = ransacF(x1, y1, x2, y2, im1, im2)

% Find normalization matrix
T1 = normalize(x1, y1);
T2 = normalize(x2, y2);

% Transform point set 1 and 2
% set1Trans = [x1(1:8, :) y1(1:8, :) ones(8, 1)];
% set2Trans = [x2(1:8, :) y2(1:8, :) ones(8, 1)];

set1Trans = [x1 y1 ones(size(x1))];
set2Trans = [x2 y2 ones(size(x1))];

% computeF(set1Trans, set2Trans);

highestInliers = 2;

% RANSAC based 8-point algorithm
for i = 1:1000
    randomIndexes = randsample(size(x1, 1), 8);
    
    F = computeF(set1Trans(randomIndexes, :), set2Trans(randomIndexes, :));
    inliers = getInliers(set1Trans, set2Trans, F, 10);
    inlierCount(i) = size(inliers, 2);
    
    if inlierCount(i) > highestInliers
        bestF = F;
        bestInliers = inliers;
        highestInliers = inlierCount(i);
    end

end

best = bestInliers;


function inliers = getInliers(pt1, pt2, F, thresh)
% Function: implement the criteria checking inliers. 
for i = 1:size(pt1)
    line1 = F * pt1(i, :)';
    line2 = F * pt2(i, :)';
    distX1(i) = abs(pt1(i, :) * line2) / sqrt(line2(1) ^ 2 + line2(2) ^ 2);
    distX2(i) = abs(pt2(i, :) * line1) / sqrt(line1(1) ^ 2 + line1(2) ^ 2);
end

inliers = find(distX1 < thresh & distX2 < thresh);
% disp();

function T = normalize(x, y)
% Function: find the transformation to make it zero mean and the variance as sqrt(2)
stdMatrix = [1/std(x) 0 0;
             0 1/std(y) 0;
             0     0    1];
meanMatrix = [1 0 -mean(x);
              0 1 -mean(y);
              0 0       1];
T = stdMatrix * meanMatrix;

  
% function F = computeF(x1, y1, x2, y2)
function F = computeF(x1, x2)
% Function: compute fundamental matrix from corresponding points
A = [x1(:,1).*x2(:,1) x1(:,1).*x2(:,2) x1(:,1) x1(:,2).*x2(:,1) x1(:,2).*x2(:,2) x1(:,2) x2(:,1) x2(:,2) ones(8, 1)];
[U, S, V] = svd(A);
m = V(:, end);
M = reshape(m, [], 3)';
[U, S, V] = svd(M);
S(3,3) = 0; 
F = U*S*V';

