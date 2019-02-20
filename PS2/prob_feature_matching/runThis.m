function featureMatching
% Matching SIFT Features

im1 = imread('stop1.jpg');
im2 = imread('stop2.jpg');

load('SIFT_features.mat'); % Load pre-computed SIFT features
% Descriptor1, Descriptor2: SIFT features from image 1 and image 2
% Frame1, Frame2: position, scale, rotation of keypoints

% YOUR CODE HERE
desb1 = im2double(Descriptor1);
desb2 = im2double(Descriptor2);

% Graduate Credit
% tic
% kdVar = createns(desb2', 'NSMethod', 'kdtree');
% neigh = knnsearch(kdVar, desb1', 'K', 2);
% toc
% 
% neigh = neigh';
% firstInd = 1:size(desb1, 2);
% matches = [firstInd; neigh(1, :)];

% THRESHOLDING NEAREST NEIGHBOUR DISTANCES
% thresh = 0.7;
% ed = zeros(1, size(desb2, 2));
% %matches = zeros(2, size(desb1, 2));
% count = 1;
% desb1(:, 1);
% desb2(:, 1);
% for i = 1 : size(desb1, 2)
%     for j = 1 : size(desb2, 2)
%         diff(j) = sum(abs(desb2(:, j) - desb1(:, i)));
%     end
%     
%     diff = diff/max(diff);
%     if min(diff) < 0.15
%         nn(1, count) = i;
%         nn(2, count) = max(find(diff == min(diff)));
%         count = count + 1;
%     end
% end
% 
% matches = nn;


% THRESHOLDING DISTANCE RATIO
thresh = 0.7;
ed = zeros(1, size(desb2, 2));
%matches = zeros(2, size(desb1, 2));
count = 1;
desb1(:, 1);
desb2(:, 1);
tic
for i = 1 : size(desb1, 2)
    for j = 1 : size(desb2, 2)
        first = desb1(:, i);
        second = desb2(:, j);
        ed(j) = sqrt((first - second)' * (first - second));
    end
    
    edSorted = sort(ed, 'ascend');
    nn1 = edSorted(1);
    nn2 = edSorted(2);
    nnRatio = nn1/nn2;
    if nnRatio < thresh
        matches(1:1, count:count) = i;
        matches(2:2, count:count) = find(nn1 == ed);
        count = count + 1;
    end
end
toc




% matches: a 2 x N array of indices that indicates which keypoints from image
% 1 match which points in image 2

% Display the matched keypoints
figure(1), hold off, clf
plotmatches(im2double(im1),im2double(im2),Frame1,Frame2,matches);