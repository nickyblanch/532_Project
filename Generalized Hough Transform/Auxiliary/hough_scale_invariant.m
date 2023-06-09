function [peaks, H] = hough(E, R, A, thresh, pixels_per_bin)

% Perform Hough Transform
[H, coeffs] = houghtransform(E, R, A, pixels_per_bin);

% Find peaks in the Hough array
peaks = houghpeaks(H, thresh, coeffs);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% houghtransform Hough Transform To Calculate Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H, coeffs] = houghtransform(E, R, A, pixels_per_bin)

% Number of rows and columns
[nrows,ncols] = size(E);
N = max(nrows, ncols);


% Number of entries in the R-Table
[rrows, rcols] = size(R);
nentries = length(R);

% Number of scale values
coeffs = 0.1:0.05:2;
nscales = length(coeffs);

% Transform pixels_per_bin so that it can be applied to width and height
pixels_per_bin = sqrt(pixels_per_bin);

% Allocate hough (accumulator) array
H = zeros(round(nrows / pixels_per_bin), round(ncols / pixels_per_bin), nscales);

% For each pixel in the image
for r = 1:nrows
    for c = 1:ncols
        
        % If on an edge
        if E(r,c) == 0
            
            % For each entry in the R-Table
            for i = 1:nentries

                % If the edge orientation matches entry in R-Table
                if ( abs(A(r,c) - R(i, 3)) < .4 )

                    % For each scale value
                    for a = 1:nscales
                    
                        % Calculate r0 and c0 using the polar coordinates
                        % provided by the R-vector
                        r0 = round(r - coeffs(a)*R(i, 1)*sin(R(i, 2)));
                        c0 = round(c - coeffs(a)*R(i, 1)*cos(R(i, 2)));
                        
                        % If we are within bounds
                        if (r0 > 0 && r0 < nrows && c0 > 0 && c0 < ncols)
                            
                            % Calculate coordinates in accumulator array
                            % based on image coordinates
                            hough_coordinate_r = round(r0 / pixels_per_bin);
                            if hough_coordinate_r < 1
                                hough_coordinate_r = 1;
                            end
                            hough_coordinate_c = round(c0 / pixels_per_bin);
                            if hough_coordinate_c < 1
                                hough_coordinate_c = 1;
                            end
                            
                            % Increment the accumulator array
                            H(hough_coordinate_r, hough_coordinate_c, a) =  H(hough_coordinate_r, hough_coordinate_c, a) + 1;
    
                        end
                    end
                end
            end
        end
    end
end
end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% houghpeaks Find Peaks in Hough Array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function peaks = houghpeaks(H, thresh, coeffs)
[nrow,ncol,nscale] = size(H);
peaks = [];

% For each scale factor
for a = 1:nscale

    % Here is the code for the interior elements of the H array:
    for i = 2:(nrow-1)
        for j = 2:(ncol-1)
            if H(i,j,a) >= thresh && H(i,j,a) >= H(i-1, j-1,a) && H(i,j,a) >= H(i, j-1,a) && H(i,j,a) >= H(i-1, j,a) && H(i,j,a) >= H(i+1, j+1,a) && H(i,j,a) >= H(i+1, j,a) ...
                                  && H(i,j,a) >= H(i, j+1,a) && H(i,j,a) >= H(i-1, j+1,a) && H(i,j,a) >= H(i+1, j-1,a)
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