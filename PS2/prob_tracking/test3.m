im = im2double(imread('images/hotel.seq0.png'));

c = detectHarrisFeatures(im);

c

imshow(im); hold on;
plot(c.selectStrongest(50));