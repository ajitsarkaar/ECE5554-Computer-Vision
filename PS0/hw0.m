clc;
clear all;


hokieBirdImage = imread('hokiebird.jpg');

%Q1
line250 = hokieBirdImage(250:250, :);
line250RValue = hokieBirdImage(250:250,:,1);
line250GValue = hokieBirdImage(250:250,:,2);
line250BValue = hokieBirdImage(250:250,:,3);

figure
subplot(3, 1, 1);
plot(line250RValue, 'r');
title('RED Values of 250th Row');

subplot(3, 1, 2);
plot(line250GValue, 'g');
title('GREEN Values of 250th Row');

subplot(3, 1, 3);
plot(line250BValue, 'b');
title('BLUE Values of 250th Row');

%Q2
blankImage = zeros(size(hokieBirdImage, 1), size(hokieBirdImage, 2), 'uint8');

redBird = hokieBirdImage(:, :, 1);
redBirdWithColor = cat(3, redBird, blankImage, blankImage);
figure, imshow(redBirdWithColor);

greenBird = hokieBirdImage(:, :, 2);
greenBirdWithColor = cat(3, blankImage, greenBird, blankImage);
figure, imshow(greenBirdWithColor);

blueBird = hokieBirdImage(:, :, 3);
blueBirdWithColor = cat(3, blankImage, blankImage, blueBird);
figure, imshow(blueBirdWithColor);

rgbCombinedImage = [redBirdWithColor; greenBirdWithColor; blueBirdWithColor];
figure, imshow(rgbCombinedImage);

%Q3
newSwappedImage(:, :, 1) = hokieBirdImage(:, :, 2);
newSwappedImage(:, :, 2) = hokieBirdImage(:, :, 1);
newSwappedImage(:, :, 3) = hokieBirdImage(:, :, 3);

figure, imshow(newSwappedImage);

%Q4
newGrayImage = rgb2gray(hokieBirdImage);

figure, imshow(newGrayImage);

%Q5
meanImage = double(redBird) + double(greenBird) + double(blueBird);
meanImage2 = uint8(meanImage/3);

figure, imshow(meanImage2);

%Q6
negativeImage = 255 - newGrayImage;
%negativeImage = imcomplement(newGrayImage);

figure, imshow(negativeImage);
 
%Q7
croppedImage = hokieBirdImage(1:372, 1:372, :);
rotate90 = imrotate(croppedImage, 90);
rotate180 = imrotate(croppedImage, 180);
rotate270 = imrotate(croppedImage, 270);
rotatingImages = [croppedImage, rotate90, rotate180, rotate270];

figure, imshow(rotatingImages);

%Q8
imageDimensions = size(hokieBirdImage);
rows = imageDimensions(1);
columns = imageDimensions(2);
colours = imageDimensions(3);

rImage = hokieBirdImage(:, :, 1);
gImage = hokieBirdImage(:, :, 2);
bImage = hokieBirdImage(:, :, 3);

newImageR = zeros(rows, columns);
newImageG = zeros(rows, columns);
newImageB = zeros(rows, columns);

for i = 1 : rows
    for j = 1 : columns
        if rImage(i, j) > 127
            newImageR(i, j) = 255;
        end
        if gImage(i, j) > 127
            newImageG(i, j) = 255;
        end
        if bImage(i, j) > 127
            newImageB(i, j) = 255;
        end
    end
end

newCombinedImage = cat(3, newImageR, newImageG, newImageB);

imshow(newCombinedImage);

%Q9
meanR = mean2(newImageR);
meanG = mean2(newImageG);
meanB = mean2(newImageB);

meanR
meanG
meanB

%Q10
blankImage = zeros(rows, columns);
newGrayImage = rgb2gray(hokieBirdImage);
for a = 1 : rows - 4
    for b = 1: columns - 4
        smallWindow = newGrayImage(a:a+4, b:b+4, :);
        %[x, y] = find(smallWindow==max(smallWindow(:)));
        if smallWindow(3, 3) == max(smallWindow(:))
            blankImage(3+a, 3+b) = 255;
        end
        %blankImage(x+a, y+b) = 255;
    end
end

imshow(blankImage);

%End