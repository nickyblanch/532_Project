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

im = rgb2gray(imread("TEST_IMAGE_RAMP_LOWRES.jpg"));

% im = rgb2gray(imread("TEST_IMAGE_WHITE_FAR.jpg"));
% im = rgb2gray(imread("MAP_TEST.jpg"));
% im = rgb2gray(imread("SILHOUETTE_2.jpg"));
% im = 255 * imread("circle.png");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Circle centered at 0,0 with radius 20
% x^2 + y^2 = r^2
R = [];
for x = 0:.1:2*pi
    R = [R; [20, x, x]];
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
E_dilated = dilate(E, 3);
figure; imshow(E_dilated); title("Dilated edge map of image.");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generalized Hough Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Hough transform
% [peaks, H] = hough(im, R, thresh);
pixels_per_bin = 9;
thresh = 40 * pixels_per_bin;
[peaks, H] = hough_scale_invariant(E, R, A, thresh, pixels_per_bin);
if peaks
    peaks = sortrows(peaks, 4, 'descend');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% output = segmentation(E_dilated);
% 
% % Label segment at corresponds to greatest entry in Hough array
% [nrow, ncol] = size(output);
% output = output*255;
% final = im;
% 
% % For all of the peaks
% for i = 1:1
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
% final = uint8(255*ones(nrow, ncol));
final = im;

% For all of the peaks
size_peaks = size(peaks);
for i = 1:min(1, size_peaks(1))

    % Translate accumulator array output
    translated_row = peaks(i, 1) * sqrt(pixels_per_bin);
    translated_col = peaks(i, 2) * sqrt(pixels_per_bin);

    % Use R-Table to draw detected shape
    for entry = 1:length(R)

        r_coord = round(translated_row + R(entry, 1)*peaks(i, 3)*sin(R(entry, 2)));
        c_coord = round(translated_col + R(entry, 1)*peaks(i, 3)*cos(R(entry, 2)));

        if r_coord > 0 && r_coord <= nrow && c_coord > 0 && c_coord <= ncol
            final(r_coord, c_coord) = 0;
        end
    end
end

final = final(1:nrow, 1:ncol);

figure; imshow(uint8(final)); title("Detected shapes shown in gray.");






%% UNUSED
% output = im;
% [nrow, ncol] = size(output);
% output = output*255;
% [num_peaks, ~] = size(peaks);
% 
% for i = 1:num_peaks
%     for r = 1:nrow
%         for c = 1:ncol
%             if ((peaks(i,1) - r)^2 + (peaks(i,2) - c)^2 <= (20*peaks(i,3))^2)
%                 output(r, c) = 150;
%             end
%         end
%     end
% end
% figure; imshow(uint8(output)); title("Segmented image with detected shape shown in gray.");

