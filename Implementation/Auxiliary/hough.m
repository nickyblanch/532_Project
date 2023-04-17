function [peaks, H] = hough(E, R, thresh)

% Perform Hough Transform
[H] = myhough(E,  R);

% Find peaks in the Hough array
peaks = myhoughpeaks(H, thresh);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MYHOUGH Hough Transform To Calculate Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H] = myhough(E, R)

% Number of rows and columns
[nrows,ncols] = size(E);
N = max(nrows, ncols);

% Number of entries in the R-Table
[rrows, rcols] = size(R);
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
                
                % Calculate r0 and c0
                r0 = round(r + R(i, 1));
                c0 = round(c + R(i, 2));
                
                % If we are within bounds
                if (r0 > 0 && r0 < nrows && c0 > 0 && c0 < ncols)

                    % Add entry to hough array
                    H(r0,c0) = H(r0,c0) + 1;
                end
            end
        end
    end
end
end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MYHOUGHPEAKS Find Peaks in Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function peaks = myhoughpeaks(H, thresh)
[nrow,ncol] = size(H);
peaks = [];
% Here is the code for the interior elements of the H array:
for i = 2:(nrow-1)
    for j = 2:(ncol-1)
        if H(i,j) >= thresh && H(i,j) >= H(i-1, j-1) && H(i,j) >= H(i, j-1) && H(i,j) >= H(i-1, j) && H(i,j) >= H(i+1, j+1) && H(i,j) >= H(i+1, j) && H(i,j) >= H(i, j+1) && H(i,j) >= H(i-1, j+1) && H(i,j) >= H(i+1, j-1)
            peaks = [peaks; [i,j]];
        end
    end
end

% Here is the code for the border elements of the H array:
% Top border
i = 1;
for j = 1:(ncol-1)
    if H(i,j) >= thresh && H(i,j) >= H(i, j-1) && H(i,j) >= H(i+1, j+1) && H(i,j) >= H(i+1, j) && H(i,j) >= H(i, j+1) && H(i,j) >= H(i+1, j-1)
        peaks = [peaks; [i,j]];
    end
end

% Bottom border
i = nrow;
for j = 1:(ncol-1)
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