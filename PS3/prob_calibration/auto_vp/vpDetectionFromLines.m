function [VP, lineLabel] = vpDetectionFromLines(lines)

%% Simple vanishing point detection using RANSAC
% === Input === 
% lines: [NumLines x 5]
%   - each row is a detected line segment (x1, y1, x2, y2, length)
% 
% === Output ===
% VP: [2 x 3]
%   - each column corresponds to a vanishing point in the order of X, Y, Z
% lineLabel: [NumLine x 3] logical type
%   - each column is a logical vector indicating which line segments
%     correspond to the vanishing point.

%%

% JLinkage clustering
% http://www.diegm.uniud.it/fusiello/demo/jlk/
lineLabel = clusterLineSeg(PrefMat);


end

function lineLabel = clusterLineSeg(PrefMat)

numVP = 3;

T = JLinkageCluster(PrefMat);
numCluster = length(unique(T));
clusterCount = hist(T, 1:numCluster);
[~, I] = sort(clusterCount, 'descend');

lineLabel = false(size(PrefMat,1), numVP);
for i = 1: numVP
    lineLabel(:,i) = T == I(i);
end

end

function [T, Z, Y] = JLinkageCluster(PrefMat)

Y = pDistJaccard(PrefMat');
Z = linkageIntersect(Y, PrefMat);
T = cluster(Z,'cutoff',1-(1/(size(PrefMat,1)))+eps,'criterion','distance');

end
