function bmap = edgeMultiscale(im)

sigma_long = [1 3 7];
sigma_short = [0.5 1 2];
ntheta = 8;
mag = zeros(size(im, 1), size(im, 2));
expfactor = [1.2 1.0 0.9];
for s = 1:numel(sigma_long)
  mags = orientedFilterMagnitude(im, sigma_long(s), sigma_short(s), ntheta);
  mag = max(mag, mags.^expfactor(s));
end

if 1 % canny suppression
  edges = edge(rgb2gray(im), 'canny');
  bmap = mag.*edges;
else % non-max suppression
  bmap = nonmax(mag2,theta);
end
bmap(mag==0) = 0;
