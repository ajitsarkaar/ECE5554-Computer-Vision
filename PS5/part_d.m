% cd matconvnet-1.0-beta25
% run matlab/vl_compilenn ;
% 
% % Setup MatConvNet.
% run matlab/vl_setupnn ;
% % 
% cd ..;
% 
% Load a model and upgrade it to MatConvNet current version.
net = load('imagenet-vgg-verydeep-16.mat') ;
net = vl_simplenn_tidy(net) ;
% 
cd train

for iter = 1:1888
    % Obtain and preprocess an image.
    imageName = strcat(int2str(iter), '.jpg');
    im = imread(imageName) ;
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = im_ - net.meta.normalization.averageImage ;

    % Run the CNN.
    res = vl_simplenn(net, im_) ;
    f = res(38).x;
%     f = squeeze(gather(res(end).x)) ;
%     f = net.layers{1, 13}.weights{1, 2};
    f = reshape(f, [1000, 1]);
    cnnTrainingHist(:, iter) = f;
end

cd ..;
cd test;

for iter = 1:800
    % Obtain and preprocess an image.
    imageName = strcat(int2str(iter), '.jpg');
    im = imread(imageName) ;
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = im_ - net.meta.normalization.averageImage ;

    % Run the CNN.
    res = vl_simplenn(net, im_) ;
    f = res(38).x;
%     f = squeeze(gather(res(end).x)) ;
%     f = net.layers{1, 13}.weights{1, 2};
    f = reshape(f, [1000, 1]);
    cnnTestingHist(:, iter) = f;
end


%%
trainingImageNum = 1888;
testingImageNum = 800;


% Model 1 *****************************************************************
for i = 1:trainingImageNum
    if(train_gs(1, i) == 1)
        label1(1, i) = 1;
    else
        label1(1, i) = -1;
    end
end
tic;
model1 = fitcsvm(cnnTrainingHist',label1);
trainTime(1) = toc;
tic;
[result1, score1] = predict(model1, cnnTestingHist');
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
model2 = fitcsvm(cnnTrainingHist',label2);
trainTime(2) = toc;
tic;
[result2, score2] = predict(model2, cnnTestingHist');
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
model3 = fitcsvm(cnnTrainingHist',label3);
trainTime(3) = toc;
tic;
[result3, score3] = predict(model3, cnnTestingHist');
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
model4 = fitcsvm(cnnTrainingHist',label4);
trainTime(4) = toc;
tic;
[result4, score4] = predict(model4, cnnTestingHist');
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
model5 = fitcsvm(cnnTrainingHist',label5);
trainTime(5) = toc;
tic;
[result5, score5] = predict(model5, cnnTestingHist');
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
model6 = fitcsvm(cnnTrainingHist',label6);
trainTime(6) = toc;
tic;
[result6, score6] = predict(model6, cnnTestingHist');
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
model7 = fitcsvm(cnnTrainingHist',label7);
trainTime(7) = toc;
tic;
[result7, score7] = predict(model7, cnnTestingHist');
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
model8 = fitcsvm(cnnTrainingHist',label8);
trainTime(8) = toc;
tic;
[result8, score8] = predict(model8, cnnTestingHist');
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