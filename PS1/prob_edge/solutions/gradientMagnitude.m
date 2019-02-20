function [mag, theta] = gradientMagnitude(im, sigma)
% 
% gaussianFilter = fspecial('Gaussian', sigma * 3, sigma);
% lowPassedImage = imfilter(im, gaussianFilter);
% 
% xKernel = [-0.5, 0, 0.5];
% yKernel = [-0.5; 0; 0.5];
% 
% xGradient = imfilter(lowPassedImge, xKernel)
% yGradient = imfilter(lowPassedImge, yKernel);
% 
% mag = sqrt(xGradient.^2 + yGradient.^2);
% [maxValues, maxIndices] = max(mag, [], 3);
% 
% imageSize = size(yGradient, 1) * size(yGradient, 2);
% theta = atan2(yGradient( (1:imageSize) + ( maxIndices(:)'-1 ) * imageSize ), gx( (1:imageSize) + ( maxIndices(:)'-1 ) * imageSize ) )+pi/2;
% theta = reshape(theta, [size(yGradient, 1) size(yGradient, 2)]);
% 
% mag = sqrt(sum(mag.^2, 3));

% Graduate Credit: Changing to the HSV Colorspace give a higher overall F
% score.
im = rgb2hsv(im);

gauss = fspecial('gaussian', max(round(sigma*3)*2+1,3), 1);
lap = fspecial('laplacian', 0.5);

im = imfilter(im, gauss);
[gx, gy] = gradient(im);



% compute gradient magnitude for each channel (r, g, b)
mag = sqrt(gx.^2 + gy.^2); 
% get orientation of gradient with largest magnitude
[mv, mi] = max(mag, [], 3);% max over third dimension
N = size(gy, 1)*size(gy, 2);
theta = atan2(gy( (1:N) + ( mi(:)'-1 ) * N ), gx( (1:N) + ( mi(:)'-1 ) * N ) )+pi/2;
theta = reshape(theta, [size(gy, 1) size(gy, 2)]);

% compute overall magnitude as L2-norm of r g b
mag = sqrt(sum(mag.^2, 3));


