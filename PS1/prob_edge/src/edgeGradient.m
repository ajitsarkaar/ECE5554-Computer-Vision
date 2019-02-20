function bmap = edgeGradient(im)
sigma = 2.5;
[mag, theta] = gradientMagnitude(im, sigma);
%mag2 = 1./(1+exp(3 + -20*mag));
mag2 = mag.^0.7;

if 1 % canny suppression
  edges = edge(rgb2gray(im), 'canny');
  bmap = mag2.*edges;
else % non-max suppression
  bmap = nonmax(mag2,theta);
end
bmap(mag==0) = 0;



