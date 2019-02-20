function bmap = edgeOrientedFilters(im)

sigma_long = 3;
sigma_short = 1;
ntheta = 8;
[mag, theta] = orientedFilterMagnitude(im, sigma_long, sigma_short, ntheta);
mag2 = mag; %1./(1+exp(3.5 + -16*mag));

if 1 % canny suppression
  edges = edge(rgb2gray(im), 'canny');
  bmap = mag2.*edges;
else % non-max suppression
  bmap = nonmax(mag2,theta);
end
bmap(mag==0) = 0;
