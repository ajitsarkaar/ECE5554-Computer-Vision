clear all;
load('gs.mat');
load('sift_desc.mat');
% load('trainingHistorgrams.mat');

%%
K = 200;
trainImageNum = 1888;
testImageNum = 800;

features = zeros(128, 1);
for imageCount = 1:trainImageNum
    tr = train_D{imageCount};
    features = [features tr];
end

features = features(:, 2:end);

%%
tic


numOfPoints = size(features, 2); 
S = round(sqrt(numOfPoints/K));
centres = round(linspace(S, (numOfPoints-S), K));


%%
means = uint8(zeros(128, size(centres, 2)));
for i = 1:size(centres, 2)
    means(:, i) = features(:, centres(i));
end

%%
d = ones(1, numOfPoints) * Inf;
l = ones(1, numOfPoints) * -1;

numIter = 10; % Number of iteration for running K Means

for iter = 1: numIter
    for i = 1:size(means, 2)
        lowerBound = centres(i) - (S-1); 
        higherBound = centres(i) + (S-1);

        if lowerBound < 1
            lowerBound = 1;
        end

        if higherBound > numOfPoints
            higherBound = numOfPoints;
        end

        for j = lowerBound:higherBound
            currKeypoint = features(:, j);
            %newD = sum(currKeypoint - means(:, i));
            newD = sqrt(sum((currKeypoint - means(:, i)).^2));
            if newD < d(j)
                d(j) = newD;
                l(j) = i;
            end
        end
    end
    for it = 1:size(means, 2)
        ro = find(l==it);
        if size(ro, 2) > 0
            for tempIter = 1:size(ro)
                temp(:, tempIter) = features(:, ro(tempIter));
            end
            meanLAB = mean(temp, 2);
            means(:, it) = meanLAB;
        end
    end

end

%%
save('trainingMeans.mat', 'means');
% hist(l, K);

%%
load('trainingMeans.mat');
trainingHist = zeros(K, trainImageNum);
means = double(means);
for imageCount = 1:1888
    imageDesb = train_D{imageCount};
    imageDesb = double(imageDesb);
    for deCount = 1:size(imageDesb, 2)
        minDist = Inf;
        for meanNum = 1:size(means, 2)
            currentDesb = imageDesb(:, deCount);
            currentMean = means(:, meanNum);
            currentDist = sqrt(sum((currentDesb - currentMean).^2));
            if currentDist < minDist
                minDist = currentDist;
                closestMeanNum = meanNum;
            end
        end
        trainingHist(closestMeanNum, imageCount) = trainingHist(closestMeanNum, imageCount) + 1;
    end
    trainingHist(:, imageCount) = trainingHist(:, imageCount) / size(imageDesb, 2);
    imageCount
end

trainingTime = toc
% 
% save('trainingHist.mat', 'trainingHist');
% save('trainingMeans.mat', 'means');



%%
% load('trainingMeans.mat');
% load('trainingHist.mat');



testingHist = zeros(K, testImageNum);
means = double(means);
for imageCount = 1:800
    imageDesb = test_D{imageCount};
    imageDesb = double(imageDesb);
    for deCount = 1:size(imageDesb, 2)
        minDist = Inf;
        for meanNum = 1:size(means, 2)
            currentDesb = imageDesb(:, deCount);
            currentMean = means(:, meanNum);
            currentDist = sqrt(sum((currentDesb - currentMean).^2));
            if currentDist < minDist
                minDist = currentDist;
                closestMeanNum = meanNum;
            end
        end
        testingHist(closestMeanNum, imageCount) = testingHist(closestMeanNum, imageCount) + 1;
    end
    testingHist(:, imageCount) = testingHist(:, imageCount) / size(imageDesb, 2);
    imageCount
end

kdTree = KDTreeSearcher(trainingHist);
save('testingHist.mat', 'testingHist');


Idx = knnsearch(trainingHist',testingHist','K',1,'Distance','cityblock');

%%
for iter=1:800
   I = train_gs(Idx(iter));
   result(1, iter) = I;
end
    
confuseMat = zeros(8,8);
count = 0;

for i = 1:800
    confuseMat(result(1, i), test_gs(1, i)) = confuseMat(result(1, i), test_gs(1, i)) + 1;
    if(result(1, i) == test_gs(1, i))
        count = count + 1;
    end
end

display(confuseMat);
accuracy = (count/800)*100;


% 
% %%
% load('testingHist.mat');
% 
% Idx = knnsearch(trainingHist',testingHist','K',1,'Distance','cityblock');
% Idx = Idx';
% 
% accu = 0;
% for j = 1:size(Idx, 2)
%     result = train_gs(Idx(j));
%     if result == test_gs(j)
%         accu = accu + 1;
%     end
% end
% 
% accuracy = accu/8

    
    
    
%%    
% distMat = pdist2(double(imageDesb(:, deCount)), double(means(:, meanNum)));
%             diagEl = diag(distMat);
%             dist(meanNum) = sum(diagEl);
%             currentDesb = imageDesb(:, deCount);
%             currentMean = means(:, meanNum);
%             distVec = currentDesb - currentMean;
%             dist(1, meanNum) = sum(distVec);
%             if dist < 1280
%                 trainingHist(meanNum, imageCount) = trainingHist(meanNum) + 1;
%             end    
    
    
    
    
    
    
    
    