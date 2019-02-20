function featureTracking
% Main function for feature tracking
folder = './images';
im = readImages(folder, 0:50);

% tau = 0.06;                                 % Threshold for harris corner detection
% [pt_x, pt_y] = getKeypoints(im{1}, tau);    % Prob 1.1: keypoint detection

[pt_x,pt_y] = meshgrid(1:10:size(im{1},1)-1,1:10:size(im{1},2)-1);
size1 = size(1:10:size(im{1},1)-1,2)

movedOutFlag = zeros(1, numel(pt_x));
ws = 15;                                     % Tracking ws x ws patches
[movedOutFlag, track_x, track_y] = ...                    % Keypoint tracking
    trackPoints(movedOutFlag, pt_x, pt_y, im, ws);

outliers = find(movedOutFlag == 1);
movedOutPointsX = pt_x(outliers);
movedOutPointsY = pt_y(outliers);

% Visualizing the feature tracks on the first and the last frame
figure(2), imagesc(im{1}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'g', 'linewidth', 3);
figure(3), imagesc(im{end}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'g', 'linewidth', 3);

% Question 1.2.1
% Visualizing the feature tracks on the first and the last frame
% figure(2), imagesc(im{1}), hold off, axis image, colormap gray
% hold on, plot(track_x(:, 1)', track_y(:, 1)', 'g+', 'linewidth', 7);
% hold on, plot(track_x(:, 50)', track_y(:, 50)', 'r+', 'linewidth', 7);

% Question 1.2.2
% Visualizing the feature tracks on the first and the last frame
% figure(2), imagesc(im{1}), hold off, axis image, colormap gray
% hold on, plot(track_x', track_y', 'g', 'linewidth', 3);

% Question 1.2.3
% Visualizing the feature tracks on the first and the last frame
% figure(2), imagesc(im{1}), hold off, axis image, colormap gray
% hold on, plot(movedOutPointsX', movedOutPointsY', 'g+', 'linewidth', 3);




function [movedOutFlag, track_x, track_y] = trackPoints(movedOutFlag, pt_x, pt_y, im, ws)
% Tracking initial points (pt_x, pt_y) across the image sequence
% track_x: [Number of keypoints] x [2]
% track_y: [Number of keypoints] x [2]

% Initialization
N = numel(pt_x);
nim = numel(im);
track_x = zeros(N, nim);
track_y = zeros(N, nim);
track_x(:, 1) = pt_x(:);
track_y(:, 1) = pt_y(:);

for t = 1:nim-1
    [movedOutFlag, track_x(:, t+1), track_y(:, t+1)] = ...
            getNextPoints(movedOutFlag, track_x(:, t), track_y(:, t), im{t}, im{t+1}, ws);
end



function [movedOutFlag, x2, y2] = getNextPoints(movedOutFlag, x, y, im1, im2, ws)
% Iterative Lucas-Kanade feature tracking
% x,  y : initialized keypoint position in im2
% x2, y2: tracked keypoint positions in im2
% ws: patch window size

%%
% YOUR CODE HERE
% MY CODE, MY CODE...........
x2 = x;
y2 = y;
[imageRows, imageColumns] = size(im1);
[Ix, Iy] = gradient(im1);

Ix2 = Ix .* Ix;
Iy2 = Iy .* Iy;

% figure;
% imshow(Ix, []);
% figure;
% imshow(Iy, []);
halfSide = floor(ws/2);
[sizeR, sizeC] = size(x);
[rowInd, colInd] = meshgrid(-halfSide:halfSide, -halfSide:halfSide);

for i = 1 : sizeR
    if movedOutFlag(i) == 0
        if (x(i) > imageRows-halfSide - 1) | (y(i) > imageColumns-halfSide - 1)
            x2(i) = x(i);
            y2(i) = y(i);
            movedOutFlag(i) = 1;
            continue;
        end

        if (x(i) < halfSide) | (y(i) < halfSide) 
            x2(i) = x(i);
            y2(i) = y(i);
            movedOutFlag(i) = 1;
            continue;
        end

        xCoor = rowInd + x(i);
        yCoor = colInd + y(i);
        IxPatch = interp2(Ix,xCoor,yCoor, 'bilinear');
        IyPatch = interp2(Iy,xCoor,yCoor, 'bilinear');
        %IxIyPatch = interp2(IxIy,xCoor,yCoor,'bilinear');
        imagePatch = interp2(im1,xCoor,yCoor, 'bilinear');

        for j = 1 : 5
            xCoor2 = rowInd + x2(i);
            yCoor2 = colInd + y2(i);

            Is = interp2(im2, xCoor2, yCoor2, 'bilinear');
            It = Is - imagePatch;

            if isnan(It)
                continue;
            end

            A = [sum(sum(IxPatch .* IxPatch)) sum(sum(IxPatch .* IyPatch)); sum(sum(IxPatch .* IyPatch)) sum(sum(IyPatch .* IyPatch))];
            b = -[sum(sum(IxPatch .* It)); sum(sum(IyPatch .* It))];

            uv = A \ b;

    %         if rank(A) >= 2
    %             uv = A \ b;
    %         else
    %             uv = [x(i); y(i)];
    %         end

            x2(i) = x2(i) + uv(1);
            y2(i) = y2(i) + uv(2);
            
            if (x2(i) > imageRows-halfSide - 1) | (y2(i) > imageColumns-halfSide - 1)
            x2(i) = x(i);
            y2(i) = y(i);
            movedOutFlag(i) = 1;
            continue;
        end

        if (x2(i) < halfSide) | (y2(i) < halfSide) 
            x2(i) = x(i);
            y2(i) = y(i);
            movedOutFlag(i) = 1;
            continue;
        end
            
        end
    end
end


function im = readImages(folder, nums)
im = cell(numel(nums),1);
t = 0;
for k = nums,
    t = t+1;
    im{t} = imread(fullfile(folder, ['hotel.seq' num2str(k) '.png']));
    im{t} = im2single(im{t});
end
