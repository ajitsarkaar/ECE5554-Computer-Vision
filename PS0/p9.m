clc;
clear all;

hokieBirdImage = imread('hokiebird.jpg');
rImage = hokieBirdImage(:, :, 1);
gImage = hokieBirdImage(:, :, 2);
bImage = hokieBirdImage(:, :, 3);

rImageVals = rImage > 127;
rFinalVals = rImage(rImageVals);
rAvg = sum(rFinalVals)/numel(rFinalVals)

gImageVals = gImage > 127;
gFinalVals = gImage(gImageVals);
gAvg = sum(gFinalVals)/numel(gFinalVals)

bImageVals = bImage > 127;
bFinalVals = bImage(bImageVals);
bAvg = sum(bFinalVals)/numel(bFinalVals)

