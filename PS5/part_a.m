clc; clear all;


labels = load('gs.mat');
train_gs = labels.train_gs;
test_gs = labels.test_gs;

% train_gs(6);

trainingImageCount = 1888;

tic;

for i = 1:trainingImageCount
    imNum = int2str(i);
    fileName = strcat('train/', imNum, '.jpg');
    im1 = im2double(imread(fileName));
    
    %   HISTOGRAM PLOTTING OF THE IMAGE...
    rim1 = reshape(im1(:, :, 1), [1 (size(im1, 1) * size(im1, 2))]);
    gim1 = reshape(im1(:, :, 2), [1 (size(im1, 1) * size(im1, 2))]);
    bim1 = reshape(im1(:, :, 3), [1 (size(im1, 1) * size(im1, 2))]);

    [rHist,rOut] = hist(rim1, 256);
    [gHist,gOut] = hist(gim1, 256);
    [bHist,bOut] = hist(bim1, 256);

    combinedHist = [rHist gHist bHist];
    
    trainingTensor(i, :) = combinedHist;
end

trainingTensorFormationTime = toc
save('trainingTensor.mat', 'trainingTensor');

testingImageCount = 800;
tic;

for i = 1:testingImageCount
    imNum = int2str(i);
    fileName = strcat('test/', imNum, '.jpg');
    im1 = im2double(imread(fileName));
    
    %   HISTOGRAM PLOTTING OF THE IMAGE...
    rim1 = reshape(im1(:, :, 1), [1 (size(im1, 1) * size(im1, 2))]);
    gim1 = reshape(im1(:, :, 2), [1 (size(im1, 1) * size(im1, 2))]);
    bim1 = reshape(im1(:, :, 3), [1 (size(im1, 1) * size(im1, 2))]);

    [rHist,rOut] = hist(rim1, 256);
    [gHist,gOut] = hist(gim1, 256);
    [bHist,bOut] = hist(bim1, 256);

    combinedHist = [rHist gHist bHist];
    
    testingTensor(i, :) = combinedHist;
end

testingTensorFormationTime = toc
save('testingTensor.mat', 'testingTensor');

% load('trainingTensor.mat');
% load('testingTensor.mat');

%%
Idx = knnsearch(trainingTensor,testingTensor,'K',75,'Distance','cityblock');


for iter=1:testingImageCount
   I = train_gs(Idx(iter));
   result(1, iter) = I;
end
    
confuseMat = zeros(8,8);
count = 0;

for i = 1:testingImageCount
    confuseMat(result(1, i), test_gs(1, i)) = confuseMat(result(1, i), test_gs(1, i)) + 1;
    if(result(1, i) == test_gs(1, i))
        count = count + 1;
    end
end

display(confuseMat);
accuracy = (count/testingImageCount)*100;


% Idx = rem(Idx, 8);
% Idx(Idx == 0) = 8;
% Idx = Idx';
% 
% accu = 0;
% for j = 1:size(Idx, 2)
%     result = train_gs(Idx(j));
%     if result == test_gs(j)
%         accu = accu + 1;
%     end
% %     result(j) = test_gs(Idx(j));
% end
% 
% accuracy = accu/8

% figure(1);

% [counts values] = hist(rim1);
% 
% figure(1);
% rHist = histogram(rim1);
% figure(2);
% [gHistCount, gHistValues] = hist(gim1);
% figure(3);
% [bHistCount, bHistValues] = hist(bim1);
