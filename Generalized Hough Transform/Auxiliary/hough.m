function [peaks, H] = hough(E, R, thresh)

% Perform Hough Transform
[H] = houghtransform(E,  R);

% Find peaks in the Hough array
peaks = houghpeaks(H, thresh);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% houghtransform Hough Transform To Calculate Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H] = houghtransform(E, R)

% E -> Edge map of image
% R -> R-Table describing target shape

% Number of rows and columns
[nrows,ncols] = size(E);

% Number of entries in the R-Table
nentries = length(R);

% Allocate hough array
H = zeros(nrows, ncols);

% For each pixel in the image
for r = 1:nrows
    for c = 1:ncols
        
        % If on an edge
        if E(r,c) == 0
            
            % For each entry in the R-Table
            for i = 1:nentries
                
                % Calculate r0 and c0, the coordinates of the detected
                % shape
                r0 = round(r + R(i, 1));
                c0 = round(c + R(i, 2));
                
                % If the shape is detected within the bounds of the image
                if (r0 > 0 && r0 < nrows && c0 > 0 && c0 < ncols)

                    % Add entry to hough array at the current location
                    H(r0,c0) = H(r0,c0) + 1;
                end
            end
        end
    end
end
end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% houghpeaks Find Peaks in Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function peaks = houghpeaks(H, thresh)

[nrow,ncol] = size(H);
peaks = [];

% Here is the code for the interior elements of the H array:
for i = 2:(nrow-1)
    for j = 2:(ncol-1)
        if H(i,j) >= thresh && H(i,j) >= H(i-1, j-1) && H(i,j) >= H(i, j-1) && H(i,j) >= H(i-1, j) && H(i,j) >= H(i+1, j+1) && H(i,j) >= H(i+1, j) ...
                            && H(i,j) >= H(i, j+1) && H(i,j) >= H(i-1, j+1) && H(i,j) >= H(i+1, j-1)
            peaks = [peaks; [i,j]];
        end
    end
end

% Here is the code for the border elements of the H array:
% Top border
i = 1;
for j = 2:(ncol-1)
    if H(i,j) >= thresh && H(i,j) >= H(i, j-1) && H(i,j) >= H(i+1, j+1) && H(i,j) >= H(i+1, j) && H(i,j) >= H(i, j+1) && H(i,j) >= H(i+1, j-1)
        peaks = [peaks; [i,j]];
    end
end

% Bottom border
i = nrow;
for j = 2:(ncol-1)
    if H(i,j) >= thresh && H(i,j) >= H(i-1, j-1) && H(i,j) >= H(i, j-1) && H(i,j) >= H(i-1, j) && H(i,j) >= H(i, j+1) && H(i,j) >= H(i-1, j+1)
        peaks = [peaks; [i,j]];
    end
end

% Left border
j = 1;
for i = 2:(nrow-1)
    if H(i,j) >= thresh && H(i,j) >= H(i-1, j) && H(i,j) >= H(i+1, j+1) && H(i,j) >= H(i+1, j) && H(i,j) >= H(i, j+1) && H(i,j) >= H(i-1, j+1)
        peaks = [peaks; [i,j]];
    end
end

% Right border
j = ncol;
for i = 2:(nrow-1)
    if H(i,j) >= thresh && H(i,j) >= H(i-1, j-1) && H(i,j) >= H(i, j-1) && H(i,j) >= H(i-1, j) && H(i,j) >= H(i+1, j) && H(i,j) >= H(i+1, j-1)
        peaks = [peaks; [i,j]];
    end
end

end % function