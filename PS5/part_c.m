clc;
clear all;
load('sift_desc.mat');
load('gs.mat');

K = 600;
trainingImageNum = 1888;
testingImageNum = 800;
samples = [];
for i = 1:trainingImageNum
    img = im2single(imread(strcat('train/', num2str(i), '.jpg')));
    f = train_D{1, i};
    randIndices = randperm(size(f, 2), 20);
    desb = f(:, randIndices);
    samples = [samples, desb];
end
samples = double(samples);
T = formClusters(samples',600);

for i = 1:trainingImageNum
    imageHist = zeros(K);
    f = train_D{1, i};
    ind = knnsearch(T',f','K',1);
    for j = 1:size(ind)
        imageHist(ind(j)) = imageHist(ind(j)) + 1;
    end
    l = imageHist(:,1);
    l = l / sqrt(l' * l);
    trainingHist(:,i) = l;
end

samples = [];
for i = 1:testingImageNum
    img = im2single(imread(strcat('test/', num2str(i), '.jpg')));
    f = test_D{1, i};
    randIndices = randperm(size(f, 2), 20);
    desb = f(:, randIndices);
    samples = [samples, desb];
end


for i = 1:testingImageNum
    imageHist = zeros(K);
    f = test_D{1, i};
    ind = knnsearch(T',f','K',1);
    for j = 1:size(ind)
        imageHist(ind(j)) = imageHist(ind(j)) + 1;
    end
    l = imageHist(:,1);
    l = l / sqrt(l' * l);
    testingHist(:,i) = l;
end



% Model 1 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 1)
        label1(1, i) = 1;
    else
        label1(1, i) = -1;
    end
end
tic;
model1 = fitcsvm(trainingHist',label1);
trainTime(1) = toc;
tic;
[result1, score1] = predict(model1, testingHist');
testTime(1) = toc;

% Model 2 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 2)
        label2(1, i) = 2;
    else
        label2(1, i) = -1;
    end
end
tic;
model2 = fitcsvm(trainingHist',label2);
trainTime(2) = toc;
tic;
[result2, score2] = predict(model2, testingHist');
testTime(2) = toc;

% Model 3 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 3)
        label3(1, i) = 3;
    else
        label3(1, i) = -1;
    end
end
tic;
model3 = fitcsvm(trainingHist',label3);
trainTime(3) = toc;
tic;
[result3, score3] = predict(model3, testingHist');
testTime(3) = toc;

% Model 4 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 4)
        label4(1, i) = 4;
    else
        label4(1, i) = -1;
    end
end
tic;
model4 = fitcsvm(trainingHist',label4);
trainTime(4) = toc;
tic;
[result4, score4] = predict(model4, testingHist');
testTime(4) = toc;

% Model 5 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 5)
        label5(1, i) = 5;
    else
        label5(1, i) = -1;
    end
end
tic;
model5 = fitcsvm(trainingHist',label5);
trainTime(5) = toc;
tic;
[result5, score5] = predict(model5, testingHist');
testTime(5) = toc;

% Model 6 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 6)
        label6(1, i) = 6;
    else
        label6(1, i) = -1;
    end
end
tic;
model6 = fitcsvm(trainingHist',label6);
trainTime(6) = toc;
tic;
[result6, score6] = predict(model6, testingHist');
testTime(6) = toc;

% Model 7 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 7)
        label7(1, i) = 7;
    else
        label7(1, i) = -1;
    end
end
tic;
model7 = fitcsvm(trainingHist',label7);
trainTime(7) = toc;
tic;
[result7, score7] = predict(model7, testingHist');
testTime(7) = toc;

% Model 8 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 8)
        label8(1, i) = 8;
    else
        label8(1, i) = -1;
    end
end
tic;
model8 = fitcsvm(trainingHist',label8);
trainTime(8) = toc;
tic;
[result8, score8] = predict(model8, testingHist');
testTime(8) = toc;


score = [score1(:, 2) score2(:, 2) score3(:, 2) score4(:, 2)...
    score5(:, 2) score6(:, 2) score7(:, 2) score8(:, 2)];
result = 9 * ones(1,800);

for iter=1:testingImageNum
   [ms, I] = max(score(iter, :));
   result(1, iter) = I;
end
    
confuseMat = zeros(8,8);
count = 0;
%%
for i = 1:testingImageNum
    confuseMat(result(1, i), test_gs(1, i)) = confuseMat(result(1, i), test_gs(1, i)) + 1;
    if(result(1, i) == test_gs(1, i))
        count = count + 1;
    end
end

display(confuseMat);
display(mean(trainTime));
display(mean(testTime));
accuracy = (count/testingImageNum)*100;



%%
function C = formClusters(X, K)
[N, d] = size(X);
randInd = randperm(N, K);

C = X(randInd(:), :);
oldIndices = zeros(N, 1);
index = zeros(N, 1);
dist = ones(N, 1) * Inf;

while true
    for j = 1:K
        for n = 1:N
            currDist = sum((X(n, :) - C(j, :)).^2);
            if currDist < dist(n)
                dist(n) = currDist;
                index(n) = j;
            end
        end
    end
    
    for j = 1:K
        C(j, :) = mean(X(index == j, :));
    end
    
    if(index == oldIndices)
        break;
    end
    
    oldIndices = index;
end

C = C';

end