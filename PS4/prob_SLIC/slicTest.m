% function [cIndMap, time, imgVis] = slic(img, K, compactness)
clear all;

img = imread('test.jpg');
% imshow(img);

% [rows cols, colors] = size(img);
K = 256;
%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - img: input color image
%   - K:   number of clusters
%   - compactness: the weights for compactness
% Output: 
%   - cIndMap: a map of type uint16 storing the cluster memberships
%     cIndMap(i, j) = k => Pixel (i,j) belongs to k-th cluster
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

% Put your SLIC implementation here

tic;
% Input data
imgB   = im2double(img);
cform  = makecform('srgb2lab');
imgLab = applycform(imgB, cform);

% Initialize cluster centers (equally distribute on the image). Each cluster is represented by 5D feature (L, a, b, x, y)
[width height colors] = size(img);
S = round(sqrt((height*width)/K));
twoS = S * 2;
% xNumPoints = (cols - 2 * S)/(2 * S);
% yNumPoints = (rows - 2 * S)/(2 * S);
xCenters = round(linspace(S, (width-S), (((width-S) - S)/S)));
yCenters = round(linspace(S, (height-S), (((height-S) - S)/S)));

[wid, hei] = meshgrid(xCenters, yCenters);

wid = reshape(wid, 1, []);
hei = reshape(hei, 1, []);
centerValues = imgLab(wid, hei, :);
% centerValues = interp2(imgLab, r, c);

k = 1;
for i = 1: size(wid, 2)
    means(k, 1) = centerValues(i, i, 1);
    means(k, 2) = centerValues(i, i, 2);
    means(k, 3) = centerValues(i, i, 3);
    means(k, 4) = wid(k);
    means(k, 5) = hei(k);
    k = k + 1;
end

d = ones(width, height) * Inf;
l = ones(width, height) * -1;


numIter = 10; % Number of iteration for running SLIC
for iter = 1: numIter
    for i = 1:size(means, 1)
        lowerW = round(means(i, 4) - (S-1));
        higherW = round(means(i, 4) + (S-1));
        lowerH = round(means(i, 5) - (S-1));
        higherH = round(means(i, 5) + (S-1));
        
        if lowerW < 1
            lowerW = 1;
        end
        if higherW > width
            higherW = width;
        end
        if lowerH < 1
            lowerH = 1;
        end
        if higherH > height
            higherH = height;
        end
        
        for j = lowerW:higherW
            for k = lowerH:higherH
                currPixel = [imgLab(j, k, 1) imgLab(j, k, 2) imgLab(j, k, 3) j k];
                newD = calcDistance(25, S, currPixel, means(i, :));
                if newD < d(j, k)
                    d(j, k) = newD;
                    l(j, k) = i;
                end
            end
        end
        
         
    end
    for it = 1:size(means, 1)
        [ro, co] = find(l==it);
        roSum = 0;
        coSum = 0;
        for tempIter = 1:size(ro, 1)
            temp(tempIter, :) = [imgLab(ro(tempIter), co(tempIter), 1), imgLab(ro(tempIter), co(tempIter), 2), imgLab(ro(tempIter), co(tempIter), 3), ro(tempIter), co(tempIter)];
        end
        meanLAB = mean(temp, 1);
        means(it, :) = meanLAB;
    end
    
    if iter == 1
        figure;
        imshow(d, []);
        title('Initial Distance Map');
    end
    
    if iter == 10
        figure;
        imshow(d, []);
        title('Distance Map At Convergence');
    end
end
 
time = toc

% Visualize mean color image
[gx, gy] = gradient(l);
bMap = (gx.^2 + gy.^2) > 0;
imgVis = img;
imgVis(cat(3, bMap, bMap, bMap)) = 1;
figure;
imshow(imgVis);
l = uint16(l);


function dist = calcDistance(m, S, a, b)
%     m = 5;
    dc = sqrt(((a(1)-b(1))^2) + ((a(2)-b(2))^2) + ((a(3)-b(3))^2));
    ds = sqrt(((a(4)-b(4))^2) + ((a(5)-b(5))^2));
    dist = sqrt(dc^2 + ((ds/S)^2 * m^2));
end
