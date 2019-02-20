function d = distanceBetweenLines( l, hor, width )
%calculates distances between horizon lines
dist = zeros (1, 4);
x = 1;
p1 = [x; (-l(1)*x - l(3))/ l(2); 1];
x = width;
p2 = [x; (-l(1)*x - l(3))/ l(2); 1];

dist(1) = abs(dot(hor, p1));
dist(2) = abs(dot(hor, p2));

x = 1;
p1 = [x; (-hor(1)*x - hor(3))/ hor(2); 1];
x = width;
p2 = [x; (-hor(1)*x - hor(3))/ hor(2); 1];

dist(3) = abs(dot(l, p1));
dist(4) = abs(dot(l, p2));

d = max (dist(:));
end

