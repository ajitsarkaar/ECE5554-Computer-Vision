function     visLineSegForVP(imgColor, lines, lineLabel, VP, imgName)

% Line segment
numVP = 3;
h1 = figure(1); imshow(imgColor); hold on
for iVP = 1: numVP
    linesVP = lines(lineLabel(:,iVP),:);
    for k = 1:size(linesVP,1)
        xy = [linesVP(k,1:2); linesVP(k,3:4)];
        if(iVP == 1)
            plot(xy(:,1), xy(:,2), 'LineWidth', 3, 'Color', 'red');
        elseif(iVP == 2)
            plot(xy(:,1), xy(:,2), 'LineWidth', 3, 'Color', 'green');
        elseif(iVP == 3)
            plot(xy(:,1), xy(:,2), 'LineWidth', 3, 'Color', 'blue');
        end
    end
end

hold off;
imgResName = [imgName,'_lines.png'];
print(h1, '-dpng', fullfile('result', imgResName));


% connect VP and line segment center
h2 = figure(2); imshow(imgColor); hold on
linesCenter = (lines(:, 1:2) + lines(:,3:4))/2;
for iVP = 1: numVP
    linesVP = linesCenter(lineLabel(:,iVP),:);
    for k = 1:size(linesVP,1)
        xy = [linesVP(k,1:2); VP(:,iVP)'];
        if(iVP == 1)
            plot(xy(:,1), xy(:,2), 'LineWidth', 1, 'Color', 'red');
        elseif(iVP == 2)
            plot(xy(:,1), xy(:,2), 'LineWidth', 1, 'Color', 'green');
        elseif(iVP == 3)
            plot(xy(:,1), xy(:,2), 'LineWidth', 1, 'Color', 'blue');
        end
    end
end

% Draw ground plane
plot([VP(1,1), VP(1,2)], [VP(2,1), VP(2,2)], 'magenta', 'LineWidth', 8);

hold off;
imgResName = [imgName,'_VP.png'];
print(h2, '-dpng', fullfile('result', imgResName));

end