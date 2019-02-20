function image = getBestOrientation(im1, im2)
% Graduate Credit
% Flips on Image 1

initialSimi = ssim(im1, im2);

% Horizontal
imHori = im1(:, [end:-1:1], :);
imHori = imresize(imHori, size(im2));
simi = ssim(imHori, im2);
if simi > initialSimi
    im1 = imHori;
    initialSimi = simi;
end

% Vertical
imVert = im1([end:-1:1], :, :);
imVert = imresize(imVert, size(im2));
simi = ssim(imVert, im2);
if simi > initialSimi
    im1 = imVert;
    initialSimi = simi;
end

% Horizontal and Vertical
imHV = im1([end:-1:1], [end:-1:1], :);
imHV = imresize(imHV, size(im2));
simi = ssim(imHV, im2);
if simi > initialSimi
    im1 = imHV;
    initialSimi = simi;
end

% Rotation 90
im90 = imrotate(im1, 90);
im90 = imresize(im90, size(im2));
simi = ssim(im90, im2);
if simi > initialSimi
    im1 = im90;
    initialSimi = simi;
end

% Rotation 180
im180 = imrotate(im1, 180);
im180 = imresize(im180, size(im2));
simi = ssim(im180, im2);
if simi > initialSimi
    im1 = im180;
    initialSimi = simi;
end

% Rotation 270
im270 = imrotate(im1, 270);
im270 = imresize(im270, size(im2));
simi = ssim(im270, im2);
if simi > initialSimi
    im1 = im270;
    initialSimi = simi;
end

image = imresize(im1, size(im2));
