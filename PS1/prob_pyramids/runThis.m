function runThis
clear all;
N = 5;
% Load an image
image = im2double(rgb2gray(imread('elephant.jpg')));
figure;
imshow(image);
title('Input Image');
[G, L] = pyramidsGL(image, N)

% % Display the Gaussian and Laplacian pyramid
figure;
displayPyramids(G, L);


% % % 
figure;
displayFFT(G, L, 0, 1);

figure;
R = reconstruction(G, L, image);

end

function R = reconstruction(G, L, im)

N = max(size(G));
gaussianFilter = fspecial('Gaussian');
figure;
for i = N : -1 : 1
    if i == N
        R{i} = G{i};
        subplot(1, N, i);
        imshow(R{i});
        title(strcat('Reconstruction ', num2str(i)));
    else
        s = size(L{i});
        R{i+1} = imresize(R{i+1}, s, 'nearest');
        R{i+1} = imfilter(R{i+1}, gaussianFilter, 'replicate');
%         if i == 2
%             R{i} = mat2gray(2 .* L{i} + R{i+1});
%         else
%             R{i} = mat2gray(L{i} + R{i+1});
%         end
        
        R{i} = mat2gray(L{i} + R{i+1});
        subplot(1, N, i);
        imshow(R{i});
        title(strcat('Reconstruction ', num2str(i)));
    end
end

rec = R{1};
ori = im;
recErr = sum((ori(:) - rec(:)).^2)

end

function [G, L] = pyramidsGL(im, N)

% [G, L] = pyramidsGL(im, N)
% Creates Gaussian (G) and Laplacian (L) pyramids of level N from image im.
% G and L are cell where G{i}, L{i} stores the i-th level of Gaussian and Laplacian pyramid, respectively.
lpfImage = im;
gaussianFilter = fspecial('Gaussian');
%surf(gaussianFilter);

for i = 1 : N
    originalImage = lpfImage;
    if i == 1
        G{i} = originalImage;
    else
        lpfImage = imfilter(originalImage, gaussianFilter, 'replicate');
        lpfImage = imresize(lpfImage, 0.5, 'nearest');
        G{i} = mat2gray(lpfImage);
    end
end

for i = 1 : N
    if i == N
        L{i} = G{i};
    else
        originalSize = size(G{i});
        upScaled = imresize(G{i+1}, [originalSize(1) originalSize(2)], 'nearest');
        reconstructedImage = G{i} - upScaled;
        L{i} = mat2gray(reconstructedImage);
    end
end

end

function displayPyramids(G, L)
% Displays intensity and fft images of pyramids
sizeOfPyramid = max(size(G))
ha = (tight_subplot(2,sizeOfPyramid))'

%colormap('default');

for i = 1 : (sizeOfPyramid * 2)
    if i > sizeOfPyramid
        axes(ha(i));
        imshow(L{i-sizeOfPyramid});
    else
        axes(ha(i));
        imshow(G{i});
    end
end

end

function displayFFT(G, L, minv, maxv)
% Displays FFT images
sizeOfPyramid = max(size(G))
ha = (tight_subplot(2,sizeOfPyramid))'
%colormap(hsv);
%colormap(jet);

for i = 1 : (sizeOfPyramid * 2)
    if i > sizeOfPyramid
        axes(ha(i));
        imagesc(log(abs(fftshift(fft2(L{i-sizeOfPyramid})))))
    else
        axes(ha(i));
        imagesc(log(abs(fftshift(fft2(G{i})))));
    end
end

end