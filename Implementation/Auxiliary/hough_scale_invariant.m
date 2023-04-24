function [peaks, H] = hough(E, R, thresh, pixels_per_bin)

% Perform Hough Transform
[H, coeffs] = myhough(E, R, pixels_per_bin);

% Find peaks in the Hough array
peaks = myhoughpeaks(H, thresh, coeffs);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MYHOUGH Hough Transform To Calculate Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H, coeffs] = myhough(E, R, pixels_per_bin)

% Number of rows and columns
[nrows,ncols] = size(E);
N = max(nrows, ncols);


% Number of entries in the R-Table
[rrows, rcols] = size(R);
nentries = length(R);

% Number of scale values
coeffs = 0.5:0.05:4;
nscales = length(coeffs);

% Allocate hough (accumulartor) array
% H = zeros(nrows, ncols, nscales);

% Transform pixels_per_bin so that it can be applied to width and height
pixels_per_bin = sqrt(pixels_per_bin);
H = zeros(round(nrows / pixels_per_bin), round(ncols / pixels_per_bin), nscales);

% For each pixel in the image
for r = 1:nrows
    for c = 1:ncols
        
        % If on an edge
        if E(r,c) == 0
            
            % For each entry in the R-Table
            for i = 1:nentries

                % For each scale value
                for a = 1:nscales
                
                    % Calculate r0 and c0
                    r0 = round(r - coeffs(a)*R(i, 1));
                    c0 = round(c - coeffs(a)*R(i, 2));
                    
                    % If we are within bounds
                    if (r0 > 0 && r0 < nrows && c0 > 0 && c0 < ncols)
    
                        % Add entry to hough array
                        % H(r0,c0, a) = H(r0,c0, a) + 1;

                        hough_coordinate_r = round(r0 / pixels_per_bin);
                        if hough_coordinate_r < 1
                            hough_coordinate_r = 1;
                        end
                        hough_coordinate_c = round(c0 / pixels_per_bin);
                        if hough_coordinate_c < 1
                            hough_coordinate_c = 1;
                        end

                        H(hough_coordinate_r, hough_coordinate_c, a) =  H(hough_coordinate_r, hough_coordinate_c, a) + 1;

                    end
                end
            end
        end
    end
end
end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MYHOUGHPEAKS Find Peaks in Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function peaks = myhoughpeaks(H, thresh, coeffs)
[nrow,ncol,nscale] = size(H);
peaks = [];

% For each scale factor
for a = 1:nscale

    % Here is the code for the interior elements of the H array:
    for i = 2:(nrow-1)
        for j = 2:(ncol-1)
            if H(i,j,a) >= thresh && H(i,j,a) >= H(i-1, j-1,a) && H(i,j,a) >= H(i, j-1,a) && H(i,j,a) >= H(i-1, j,a) && H(i,j,a) >= H(i+1, j+1,a) && H(i,j,a) >= H(i+1, j,a) && H(i,j,a) >= H(i, j+1,a) && H(i,j,a) >= H(i-1, j+1,a) && H(i,j,a) >= H(i+1, j-1,a)
                peaks = [peaks; [i,j,coeffs(a),H(i,j,a)]];
            end
        end
    end
    
    % Here is the code for the border elements of the H array:
    % Top border
    i = 1;
    for j = 2:(ncol-1)
        if H(i,j,a) >= thresh && H(i,j,a) >= H(i, j-1,a) && H(i,j,a) >= H(i+1, j+1,a) && H(i,j,a) >= H(i+1, j,a) && H(i,j,a) >= H(i, j+1,a) && H(i,j,a) >= H(i+1, j-1,a)
            peaks = [peaks; [i,j,coeffs(a),H(i,j,a)]];
        end
    end
    
    % Bottom border
    i = nrow;
    for j = 2:(ncol-1)
        if H(i,j,a) >= thresh && H(i,j,a) >= H(i-1, j-1,a) && H(i,j,a) >= H(i, j-1,a) && H(i,j,a) >= H(i-1, j,a) && H(i,j,a) >= H(i, j+1,a) && H(i,j,a) >= H(i-1, j+1,a)
            peaks = [peaks; [i,j,coeffs(a),H(i,j,a)]];
        end
    end
    
    % Left border
    j = 1;
    for i = 2:(nrow-1)
        if H(i,j,a) >= thresh && H(i,j,a) >= H(i-1, j,a) && H(i,j,a) >= H(i+1, j+1,a) && H(i,j,a) >= H(i+1, j,a) && H(i,j,a) >= H(i, j+1,a) && H(i,j,a) >= H(i-1, j+1,a)
            peaks = [peaks; [i,j,coeffs(a),H(i,j,a)]];
        end
    end
    
    % Right border
    j = ncol;
    for i = 2:(nrow-1)
        if H(i,j,a) >= thresh && H(i,j,a) >= H(i-1, j-1,a) && H(i,j,a) >= H(i, j-1,a) && H(i,j,a) >= H(i-1, j,a) && H(i,j,a) >= H(i+1, j,a) && H(i,j,a) >= H(i+1, j-1,a)
            peaks = [peaks; [i,j,coeffs(a),H(i,j,a)]];
        end
    end
end

end % function