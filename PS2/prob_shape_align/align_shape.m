function Tfm = align_shape(im1, im2)

% im1: input edge image 1
% im2: input edge image 2

% Output: transformation T [3] x [3]

% YOUR CODE　HERE
% figure;
% imshow(im1);
% 
% figure;
% imshow(im2);




[y1 x1] = find(im1 > 0);
[y2 x2] = find(im2 > 0);

%plot(y1, x1, '+g');

meanX1 = mean(x1);
meanY1 = mean(y1);

meanX2 = mean(x2);
meanY2 = mean(y2);

var1 = sqrt(sum((x1-meanX1).^2) + sum((y1-meanY1).^2))/numel(meanX1);
var2 = sqrt(sum((x2-meanX2).^2) + sum((y2-meanY2).^2))/numel(meanX2);

trans1 = [1 0 meanX2;
          0 1 meanY2;
          0 0 1      ];

varDiv = var2/var1;

trans2 = [varDiv 0 0;
          0 varDiv 0;
          0 0 1      ];
      
trans3 = [1 0 -meanX1;
          0 1 -meanY1;
          0 0 1      ];
      
Tfm = trans1 * trans2 * trans3;

A1 = [x1 y1 ones(numel(x1), 1)];
A1T = A1';

A2 = [x2 y2 ones(numel(x2), 1)];
A2T = A2';

for i = 1 : 5
    initialTrans = Tfm * A1T;
    smallestED = findSmallestEuclideanDistance(initialTrans, A2T);
    
    A = initialTrans;
    b1 = A2T(1, smallestED);
    
    [mx, flag] = lsqr(A', b1');
    
    m1 = mx(1);
    m2 = mx(2);
    t1 = mx(3);
    
    b2 = A2T(2, smallestED);
    
    [my, flag] = lsqr(A', b2');
    
    m3 = my(1);
    m4 = my(2);
    t2 = my(3);
    
    changeMat = [m1 m2 t1
                 m3 m4 t2
                 0  0  1 ];
    
    newTfm = Tfm * changeMat;
    Tfm = newTfm;

end

end

function indices = findSmallestEuclideanDistance(a, b)
ed = zeros(1, size(b, 2));
count = 1;

for i = 1 : size(a, 2)
    for j = 1 : size(b, 2)
        first = a(:, i);
        second = b(:, j);
        ed(j) = sqrt((first - second)' * (first - second));
    end
    
    indices(i) = find(ed == min(ed));
end

end