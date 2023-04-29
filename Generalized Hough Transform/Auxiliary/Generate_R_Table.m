%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR: Nicolas Blanchard
% DATE: 4/17/23
% Written for ECE 532 at the University of Arizona
% Professor Jeffrey Rodriguez, Spring 2023
% SUMMARY: This program implements a generalized Hough transform to detect
%          player models in screenshots sourced from Counter-Strike: 
%          Global Offensive.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear workspace
clear;
clc;

im = rgb2gray(imread("./Silhouettes/2.jpg"));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate edgemap of playermodel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; imshow(im); title("Original image.");
radius = 1;
threshold = 75;
[f1, f2, M, A, E] = edge(im, radius, threshold);
E = uint8(E) * 255;
figure; imshow(E); title("Edge map of image.");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Use edgemap to create R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R = [];
[nrow, ncol] = size(E);
center = [round(nrow / 2), round(ncol / 2)];

% For each pixel in the edgemap
for r = 1:nrow
    for c = 1:ncol
        
        % If we are on an edge
        if E(r, c) == 0

            % Calculate displacement vector to center and add to R-Table
            % (Magnitude and angle)
            m = sqrt((r - center(1))^2 + (c - center(2))^2);
            a = atan2( (r - center(1)), (c - center(2)) );
            R = [R; [m, a, A(r, c)]];

        end

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validate edgemap by re-drawing image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_im = uint8(ones(nrow, ncol) * 255);

% Use R-Table to draw detected shape
for entry = 1:length(R)

    r_coord = round(center(1) + R(entry, 1)*sin(R(entry, 2)));
    c_coord = round(center(2) + R(entry, 1)*cos(R(entry, 2)));

    if r_coord > 0 && r_coord <= nrow && c_coord > 0 && c_coord <= ncol
        test_im(r_coord, c_coord) = 155;
    end
end
figure; imshow(test_im); title("Re-created image.")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Export R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(".\R-Table\R_Table", 'R');
