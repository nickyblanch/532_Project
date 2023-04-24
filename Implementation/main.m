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
%% RECORD OF SUCCESSES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TEST_IMAGE_LONG.jpg | threshold = 30 | pixels_per_bin = 9 | thresh = 40 *
% pixels_per_bin

% TEST_IMAGE_RAMP.jpg | threshold = 30 | pixels_per_bin = 9 | thresh = 40 *
% pixels_per_bin



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; addpath('Auxiliary');

% im = 255 * imread("circle.png");
im = rgb2gray(imread("TEST_IMAGE_RAMP.jpg"));
% im = rgb2gray(imread("MAP_TEST.jpg"));
% im = rgb2gray(imread("SILHOUETTE_2.jpg"));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Circle centered at 0,0 with radius 20
% x^2 + y^2 = r^2
R = [];
for x = -20:1:20
    y1 = sqrt(20^2 - x^2);
    R = [R; [x, y1]; [x, -1*y1]];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Player Model R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load("R_Table.mat");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Edge mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; imshow(im); title("Original image.");
radius = 1;
threshold = 30;
[f1, f2, M, A, E] = edge(im, radius, threshold);
E = uint8(E) * 255;
figure; imshow(E); title("Edge map of image.");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dilate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dilating the edge map helps with segmentation.
% E = dilate(E, 3, true);
% figure; imshow(E); title("Dilated edge map of image.");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generalized Hough Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Hough transform
% [peaks, H] = hough(im, R, thresh);
pixels_per_bin = 9;
thresh = 40 * pixels_per_bin;
[peaks, H] = hough_scale_invariant(E, R, thresh, pixels_per_bin);
if peaks
    peaks = sortrows(peaks, 4, 'descend');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% output = segmentation(E);
% 
% % Label segment at corresponds to greatest entry in Hough array
% [nrow, ncol] = size(output);
% output = output*255;
% final = im;
% 
% % For all of the peaks
% for i = 1:length(peaks)
%     target = output(peaks(i, 1), peaks(i, 2));
%     for r = 1:nrow
%         for c = 1:ncol
%             if output(r, c) == target
%                 final(r, c) = 150;
%                 output(r, c) = 150;
%             end
%         end
%     end
% end
% figure; imshow(uint8(output)); title("Segmented image with detected shapes shown in gray.");
% figure; imshow(uint8(final)); title("Original image with detected shapes shown in gray.");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Labeling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nrow, ncol] = size(im);
final = im;

% For all of the peaks
% for i = 1:(size(peaks))(1);
size_peaks = size(peaks);
for i = 1:min(1, size_peaks(1))

    % Translate accumulator array output
    translated_row = peaks(i, 1) * sqrt(pixels_per_bin);
    translated_col = peaks(i, 2) * sqrt(pixels_per_bin);
    
    % Use R-Table to draw detected shape
    for entry = 1:length(R)

        r_coord = round(translated_row + R(entry, 1)*peaks(i, 3));
        c_coord = round(translated_col + R(entry, 2)*peaks(i, 3));

        if r_coord > 0 && r_coord <= nrow && c_coord > 0 && c_coord <= ncol
            final(r_coord, c_coord) = 155;
        end
    end
end

final = final(1:nrow, 1:ncol);

figure; imshow(uint8(final)); title("Original image with detected shapes shown in gray.");

