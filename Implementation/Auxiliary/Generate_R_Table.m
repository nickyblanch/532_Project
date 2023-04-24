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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate edgemap of playermodel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

im = rgb2gray(imread("./Silhouettes/2.jpg"));
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

            % Calculate dispalcement vector to center and add to R-Table
            R = [R; [r - center(1), c - center(2)]];

        end

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validate edgemap by re-drawing image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_im = uint8(ones(nrow, ncol) * 255);

for entry = 1:length(R)
    test_im(center(1) + R(entry, 1), center(2) + R(entry, 2)) = 0;
end
figure; imshow(test_im); title("Re-created image.")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Export R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save("R_Table", 'R');