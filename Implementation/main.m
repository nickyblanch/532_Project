%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR: Nicolas Blanchard
% DATE: 4/17/23
% Written for ECE 532 at the University of Arizona
% Professor Jeffrey Rodriguez, Spring 2023
% SUMMARY: This program implements a generalized Hough transform to detect
%          player models in screenshots sourced from Counter-Strike: 
%          Global Offensive.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; addpath('Auxiliary');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Circle centered at 0,0 with radius 20
% x^2 + y^2 = r^2
R = [];
for x = -20:1:20
    y1 = sqrt(20^2 - x^2);
    R = [R; [x, y1]; [x, -1*y1]];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edge mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

im = 255 * imread("circle.png");
radius = 1;
threshold = 50;
[f1, f2, M, A, E] = edge(im, radius, threshold);
E = uint8(E) * 255;
figure; imshow(E); title("Edge map of image.");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dilate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dilating the edge map helps with segmentation.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generalized Hough Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Hough transform
thresh = 82;
[peaks, H] = hough(im, R, thresh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output = segmentation(E);

% Label segment at corresponds to greatest entry in Hough array
[nrow, ncol] = size(output);
output = output*255;
target = output(peaks(1, 1), peaks(1, 2));
for r = 1:nrow
    for c = 1:ncol
        if output(r, c) == target
            output(r, c) = 150;
        end
    end
end
figure; imshow(uint8(output)); title("Segmented image with detected shape shown in gray.");
