function [mag, theta] = orientedFilterMagnitude(im, sigma_long, sigma_short, ntheta)
% [mag, theta] = orientedFilterMagnitude(im, sigma_long, sigma_short, ntheta)

figure(1), hold off;
thetas = -pi/2:pi/ntheta:(ntheta-1)*pi/ntheta;
mag = zeros(size(im, 1), size(im, 2), ntheta);
for t = 1:ntheta
  fil = orientedEdgeFilter(sigma_long, sigma_short, thetas(t));
  subplot(2, ntheta/2, t), imagesc(fil), axis image, colormap gray, axis off;
  resp = imfilter(im, fil);
  mag(:, :, t) = sqrt(sum(resp.^2, 3));
end
[mag, mi] = max(mag, [], 3);
theta = thetas(mi);


function fil = orientedEdgeFilter(sigma_long, sigma_short, theta)
% fil = orientedEdgeFilter(sigma_long, sigma_short, theta)

sigmax = sigma_long;
sigmay = sigma_short;

[filx, fily] = meshgrid(-round(sigmax*3):round(sigmax*3), -round(sigmay*3):round(sigmay*3));
fil = exp(-(filx.^2./sigmax.^2 + fily.^2./sigmay.^2)/2);
fil = fil ./ sum(fil(:));
fil = imfilter(fil, [1 ; 0 ; -1]);
fil = imrotate(fil, theta/pi*180, 'bilinear', 'crop');
