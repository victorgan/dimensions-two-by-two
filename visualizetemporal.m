function visualizetemporaltest

    z = linspace(0,4*pi,250);
    x = 2*cos(z) + 0.3*rand(1,250);
    y = 2*sin(z) + 0.3*rand(1,250);
    w = z.*2;
    data = [w' x' y' z'];
    
    % data = rand(10000,4);
    % data = de2bi(0:2^4-1);
    % data = de2bi(0:2^4-1) + 0.01*rand(2^4,4);
    % data = (rotx(30)*data')';

    % load carbig
    % data = [MPG, Acceleration, Displacement, Weight, Horsepower, Cylinders];
    % data = data( ~any(isnan(data),2),: );

    % load imports-85
    % data = removeNans( X(3:15) );
    visualizetemporal2(data);
end % function

function data = removeNans(data)
    data = data( ~any(isnan(data),2),: );
end % function

% data: n x d datapoints
function visualizetemporal2(dataRaw)
    writerObj = VideoWriter('visualized.avi');
    open(writerObj);

    % massaging the data
    [~, data, ~] = pca(dataRaw);
    data = zscore(data);
    % data = dataRaw;
    % data = bsxfun(@plus, data, mean(dataRaw));

    % Pre-calculate dimension display order
    numDims = size(data,2);
    displayDims = 2;
    revolvingDoorCode = revolvingDoorNums(displayDims, numDims)

    dimsPrev = revolvingDoorCode(end,:);

    % i = 2; % For looping indefinitely with the while loop
    numAxisPairs = size(revolvingDoorCode,1);
    % while true
    for i = 1:numAxisPairs % TODO deal with last rotation, loop it?
        
        dimsCurr = revolvingDoorCode(i,:);

        [dimOld, dimMid, dimNew] = getDims(dimsCurr, dimsPrev);
        [dimOld, dimMid]

        % show rotation at multiple points when transitioning between dimensions
        axisToBanish = find(dimsPrev == dimOld);
        for w = 0:0.01:1
            w = w.^2; 

            % ensure rotation banishes the axis for dimOld
            if axisToBanish == 1 % x axis, rotate along y axis.
                xAxis = (1-w)*data(:,dimOld) + (w)*data(:,dimNew);
                yAxis = data(:,dimMid);
                xDimLabel = [num2str(1-w) '* Dim' num2str(dimOld) '+' num2str(w) '* Dim' num2str(dimNew)];
                yDimLabel = ['Dim' num2str(dimMid)];
                xDim = dimNew;
                yDim = dimMid;
            elseif axisToBanish == 2 % y axis, rotate along x axis
                xAxis = data(:,dimMid);
                yAxis = (1-w)*data(:,dimOld) + (w)*data(:,dimNew);
                xDimLabel = ['Dim' num2str(dimMid)];
                yDimLabel = [num2str(1-w) '* Dim' num2str(dimOld) '+' num2str(w) '* Dim' num2str(dimNew)];
                xDim = dimMid;
                yDim = dimNew;
            end % if

            % plot
            scatter(xAxis, yAxis)
            xlabel(xDimLabel); 
            ylabel(yDimLabel); 
            axisLimits  = 3; % # of std deviations, if standardized
            axis([-1 1 -1 1] * axisLimits);

            % write to video
            frame = getframe;
            writeVideo(writerObj,frame);

            % pause(0.01);
        end % for w

        % Silently change Z axis
        dimsPrev = [xDim yDim];

        % For looping indefinitely with the while loop
        % i = i+1;
        % if i > numAxisPairs
        %     i = 1;
        % end % if

    end % for/while

    close(writerObj);
end % function

% dimsCurr: [a b] of numbers, current dimensions to display
% dimsPrev: [c d] of numbers, previously displayed dimensions
% dimNew: a or b, whichever does not appear  in dimsOld
% dimMid: a or b, whichever          appears in dimsOld
% dimOld: c or d, whichever does not appear  in dimsCurr
function [dimOld, dimMid, dimNew] = getDims(dimsCurr, dimsPrev)
    % overlapMatrix:
    %          dimsPrev [c d]
    % dimsCurr 
    % [a b]'
    overlapMatrix = bsxfun(@eq, dimsPrev, dimsCurr');
    dimOldIdx = ~any(overlapMatrix,1);
    dimNewIdx = ~any(overlapMatrix,2);

    dimMid1 = dimsPrev(~dimOldIdx);
    dimMid2 = dimsCurr(~dimNewIdx);
    assert(all(sort(dimMid1) == sort(dimMid2)), '');
    dimMid = dimMid1;

    dimOld = dimsPrev(dimOldIdx);
    dimNew = dimsCurr(dimNewIdx);
end % function
