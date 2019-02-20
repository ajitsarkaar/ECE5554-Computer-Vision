% Debugging tip: You can split your MATLAB code into cells using "%%"
% comments. The cell containing the cursor has a light yellow background,
% and you can press Ctrl+Enter to run just the code in that cell. This is
% useful when projects get more complex and slow to rerun from scratch

close all; % closes all figures
clear all;

%% Setup
% read images and convert to floating point format
image1 = im2single(imread('data/dog.bmp'));
image2 = im2single(imread('data/cat.bmp'));

grayImage1 = rgb2gray(image1);
grayImage2 = rgb2gray(image2);

figure(1);

subplot(2, 2, 1);
imshow(grayImage1);
title('Image 1');

subplot(2, 2, 2);
imshow(grayImage2);
title('Image 2');

subplot(2, 2, 3);
imagesc(log(abs(fftshift(fft2(grayImage1)))));
title('FFT of Image 1');

subplot(2, 2, 4);
imagesc(log(abs(fftshift(fft2(grayImage2)))));
title('FFT of Image 2');

% Several additional test cases are provided for you, but feel free to make
% your own (you'll need to align the images in a photo editor such as
% Photoshop). The hybrid images will differ depending on which image you
% assign as image1 (which will provide the low frequencies) and which image
% you asign as image2 (which will provide the high frequencies)

%% Filtering and Hybrid Image construction
cutoff_frequency = 7;
lowPassTune = 7;
highPassTune = 7;
%This is the standard deviation, in pixels, of the 
% Gaussian blur that will remove the high frequencies from one image and 
% remove the low frequencies from another image (by subtracting a blurred
% version from the original version). You will want to tune this for every
% image pair to get the best results.
lowPassFilter = fspecial('Gaussian', cutoff_frequency*lowPassTune+1, cutoff_frequency);
highPassFilter = fspecial('Gaussian', cutoff_frequency*highPassTune+1, cutoff_frequency);


%%
figure(2);

subplot(2, 3, 1);
imshow(grayImage1);
title('Image 1');

subplot(2, 3, 2);
surf(lowPassFilter);
title('LPF');

image1Filtered = imfilter(grayImage1, lowPassFilter);
subplot(2, 3, 3);
imshow(image1Filtered);
title('Image 1 with LPF');

subplot(2, 3, 4);
imagesc(log(abs(fftshift(fft2(grayImage1)))));
title('FFT of Image 1');

subplot(2, 3, 5);
imagesc(log(abs(fftshift(fft2(lowPassFilter)))));
title('FFT of LPF');

subplot(2, 3, 6);
imagesc(log(abs(fftshift(fft2(image1Filtered)))));
title('FFT of Image 1 Filtered');

%%
figure(3);

subplot(2, 3, 1);
imshow(grayImage2);
title('Image 1');

subplot(2, 3, 2);
surf(1 - highPassFilter);
title('HPF');

image2Filtered = grayImage2 - imfilter(grayImage2, highPassFilter);
subplot(2, 3, 3);
imshow(image2Filtered + 0.5);
title('Image 2 with HPF');

subplot(2, 3, 4);
imagesc(log(abs(fftshift(fft2(grayImage2)))));
title('FFT of Image 2');

subplot(2, 3, 5);
imagesc(log(abs(fftshift(fft2(highPassFilter)))));
title('FFT of HPF');

subplot(2, 3, 6);
imagesc(log(abs(fftshift(fft2(image2Filtered)))));
title('FFT of Image 2 Filtered');


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE BELOW. Use imfilter() to create 'low_frequencies' and
% 'high_frequencies' and then combine them to create 'hybrid_image'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the high frequencies from image1 by blurring it. The amount of
% blur that works best will vary with different image pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lowFrequencies = image1Filtered;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the low frequencies from image2. The easiest way to do this is to
% subtract a blurred version of image2 from the original version of image2.
% This will give you an image centered at zero with negative values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

highFrequencies = image2Filtered; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine the high frequencies and low frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(4);

subplot(2, 3, 1);
imshow(lowFrequencies);
title('Image 1 with Low Pass Filter');

subplot(2, 3, 2);
imshow(highFrequencies + 0.5);
title('Image 2 with High Pass Filter');

hybridImage = lowFrequencies + highFrequencies;

subplot(2, 3, 3);
imshow(hybridImage);
title('Hybrid Image');

subplot(2, 3, 4);
imagesc(log(abs(fftshift(fft2(lowFrequencies)))));
title('FFT of Image 1 with LPF');

subplot(2, 3, 5);
imagesc(log(abs(fftshift(fft2(highFrequencies)))));
title('FFT of Image 2 with HPF');

subplot(2, 3, 6);
imagesc(log(abs(fftshift(fft2(hybridImage)))));
title('FFT of Hybrid Image');



%% Visualize and save outputs
vis = vis_hybrid_image(hybridImage);

figure(5); imshow(vis);
title('Final Hybrid');

testNumber = '11';

imwrite(lowFrequencies, strcat(testNumber, '_low_frequencies.jpg'), 'quality', 95);
imwrite(highFrequencies + 0.5, strcat(testNumber, '_high_frequencies.jpg'), 'quality', 95);
imwrite(hybridImage, strcat(testNumber, '_hybrid_image.jpg'), 'quality', 95);
imwrite(vis, strcat(testNumber, '_hybrid_image_scales.jpg'), 'quality', 95);

saveas(figure(1), strcat(testNumber, '_1_Images.jpg'));
saveas(figure(2), strcat(testNumber, '_2_LPF.jpg'));
saveas(figure(3), strcat(testNumber, '_3_HPF.jpg'));
saveas(figure(4), strcat(testNumber, '_4_Hybrid.jpg'));
saveas(figure(5), strcat(testNumber, '_5_HybridPyramid.jpg'));
