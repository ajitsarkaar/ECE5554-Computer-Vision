function F = HW3_FundamentalMatrix
close all;

im1 = im2double(imread('chapel00.png'));
im2 = im2double(imread('chapel01.png'));
load 'matches.mat';

[F, inliers, normalF, normals] = ransacF(c1(matches(:, 1)), r1(matches(:, 1)), c2(matches(:, 2)), r2(matches(:, 2)), im1, im2);

% display F
normF1 = F / sqrt(sum(sum(F .^ 2)))
normF2 = normalF / sqrt(sum(sum(normalF .^ 2)))
outliers1 = setdiff(1:size(matches, 1), inliers);
outliers2 = setdiff(1:size(matches, 1), normals);
outliersSize1 = size(outliers1, 2)
outliersSize2 = size(outliers2, 2)

% plot outliers
inlierPoints = matches(inliers, :);
outlierPoints = matches(outliers1, :);

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
selectedPoints1 = inliers(randomInd);

randomInd = randsample(size(inliers, 2), 7);
selectedPoints2 = normals(randomInd);

figure(2);
imshow(im1);
title('1ST IMAGE');
hold on;

figure(3);
imshow(im2);
title('2ND IMAGE');
hold on;

figure(4);
imshow(im1);
title('1ST IMAGE');
hold on;

figure(5);
imshow(im2);
title('2ND IMAGE');
hold on;

for i = 1:7
    matchingPoint = matches(selectedPoints1(i), :);
    
    x1 = c1(matchingPoint(1));
    y1 = r1(matchingPoint(1));
    x2 = c2(matchingPoint(2));
    y2 = r2(matchingPoint(2));
    
    lineInImage1 = normF1 * [x2 y2 1]';
    lineInImage2 = normF1 * [x1 y1 1]';
    
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

for i = 1:7
    matchingPoint = matches(selectedPoints2(i), :);
    
    x1 = c1(matchingPoint(1));
    y1 = r1(matchingPoint(1));
    x2 = c2(matchingPoint(2));
    y2 = r2(matchingPoint(2));
    
    lineInImage1 = normF2 * [x2 y2 1]';
    lineInImage2 = normF2 * [x1 y1 1]';
    
    xPlane = 1:0.1:550;
    
    yPlane1 = -(lineInImage1(1) * xPlane + lineInImage1(3)) / lineInImage1(2);
    yPlane2 = -(lineInImage2(1) * xPlane + lineInImage2(3)) / lineInImage2(2);
    
    figure(4);
    hold on;
    plot(x1, y1, '+r', 'MarkerSize', 10);
    plot(xPlane, yPlane1, 'g');
    
    figure(5);
    hold on;
    plot(x2, y2, '+r', 'MarkerSize', 10);
    plot(xPlane, yPlane2, 'g');
end

error1 = [matches(inliers,:) ones(1,size(inliers,2))']*normF1*[matches(inliers,:) ones(1,size(inliers,2))']';
error2 = [matches(normals,:) ones(1,size(normals,2))']*normF2*[matches(normals,:) ones(1,size(normals,2))']';
error1 = trace(error1.^2)/size(inliers,2)
error2 = trace(error2.^2)/size(normals,2)

function [bestF, best, normalF, normals] = ransacF(x1, y1, x2, y2, im1, im2)

% Find normalization matrix
T1 = normalize(x1, y1);
T2 = normalize(x2, y2);

% Transform point set 1 and 2
% set1Trans = [x1(1:8, :) y1(1:8, :) ones(8, 1)];
% set2Trans = [x2(1:8, :) y2(1:8, :) ones(8, 1)];

set1Trans = [x1 y1 ones(size(x1))];
set2Trans = [x2 y2 ones(size(x1))];

set1TransT = (T1 * set1Trans')';
set2TransT = (T2 * set2Trans')';
% computeF(set1Trans, set2Trans);

highestInliers1 = 2;
highestInliers2 = 2;

% RANSAC based 8-point algorithm
for i = 1:1000
    randomIndexes = randsample(size(x1, 1), 8);
    
    F1 = computeF(set1TransT(randomIndexes, :), set2TransT(randomIndexes, :));
    F2 = computeF(set1Trans(randomIndexes, :), set2Trans(randomIndexes, :));
    inliers1 = getInliers(set1TransT, set2TransT, F1, 10);
    inliers2 = getInliers(set1TransT, set2TransT, F2, 10);
    inlierCount1(i) = size(inliers1, 2);
    inlierCount2(i) = size(inliers2, 2);
    
    if inlierCount1(i) > highestInliers1
        bestF1 = F1;
        bestInliers1 = inliers1;
        highestInliers1 = inlierCount1(i);
    end
    
    if inlierCount2(i) > highestInliers2
        bestF2 = F2;
        bestInliers2 = inliers2;
        highestInliers2 = inlierCount2(i);
    end
end

bestF = T2' * bestF1 * T1;
best = bestInliers1;

normalF = bestF1;
normals = bestInliers2;


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

