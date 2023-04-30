%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR: Nicolas Blanchard
% DATE: 4/17/23
% Written for ECE 532 at the University of Arizona
% Professor Jeffrey Rodriguez, Spring 2023
% SUMMARY: This program implements a generalized Hough transform to detect
%          player models in screenshots sourced from Counter-Strike: 
%          Global Offensive.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sv_cheats 1; mp_roundtime_defuse 60;mp_roundtime_hostage 60;mp_roundtime 60;mp_restartgame 1; hud_showtargetid 0; r_drawviewmodel 0; bot_freeze 1; bot_stop 1; bot_kick; bot_add ct; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

% Set to TRUE for the program to segment the image. Set to FALSE for the
% program to simply label the center of the detected player model with a circle.
segment_flag = true;

addpath('Auxiliary'); addpath('Silhouettes'); addpath('R-Table');
addpath('..\Test Images\Cache'); addpath('..\Test Images\Dust II');addpath('..\Test Images\White');
addpath('..\Test Images\Example Images (Unused)/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test R-Table (for circle detection)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Circle centered at 0,0 with radius 20
% x^2 + y^2 = r^2
R = [];
for x = 0:.1:2*pi
    R = [R; [20, x, x]];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Player Model R-Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: If this line runs, it will overwrite the R-Table loaded in the
% previous section.

load("R_Table.mat");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For every image we want to label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_images = dir(fullfile('..\Test Images\White', '*.jpg'));
test_images = {test_images.name};

for file_index = 1:10 %length(test_images)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    original_image = imread(char(test_images(1, file_index)));
    im = rgb2gray(original_image);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Edge mapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % DEBUG: UNCOMMENT TO SHOW ORIGINAL IMAGE
    % figure; imshow(im); title("Original image.");

    radius = 1;
    threshold = 40;
    [f1, f2, M, A, E] = edge(im, radius, threshold);
    E = uint8(E) * 255;

    % DEBUG: UNCOMMENT TO SHOW EDGE MAP
    % figure; imshow(E); title("Edge map of image.");
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Dilate
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Dilating the edge map helps with segmentation.
    E_dilated = dilate(E, 3);

    % DEBUG: UNCOMMENT TO SHOW DILATED EGE MAP
    % figure; imshow(E_dilated); title("Dilated edge map of image.");
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generalized Hough Transform
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Hough transform
    pixels_per_bin = 9;
    thresh =  40 * pixels_per_bin;
    [peaks, H] = hough_scale_invariant(E, R, A, thresh, pixels_per_bin);
    if peaks
        peaks = sortrows(peaks, 4, 'descend');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Segmentation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if segment_flag
        output = segmentation(E_dilated);
    
        % Label segment at corresponds to greatest entry in Hough array
        [nrow, ncol] = size(output);
        output = output*255;
        final = im;
    
        % For all of the peaks
        for i = 1:1
            target = output(peaks(i, 1)*sqrt(pixels_per_bin), peaks(i, 2)*sqrt(pixels_per_bin));
            for r = 1:nrow
                for c = 1:ncol
                    if output(r, c) == target
                        final(r, c) = 150;
                        output(r, c) = 150;
                    end
                end
            end
        end

        % DEBUG: UNCOMMENT TO SHOW SEGMENTED IMAGE WITH DETECTED SHAPES
        % SHOWN IN GRAY
        %figure; imshow(uint8(output)); title("Segmented image with detected shapes shown in gray.");
        
        figure; imshow(uint8(final)); title("Original image with detected shapes shown in gray.");
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Labeling
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ~segment_flag
        [nrow, ncol] = size(im);
        % final = uint8(255*ones(nrow, ncol));
        final = original_image;
        
        % For all of the peaks
        size_peaks = size(peaks);
        for i = 1:min(1, size_peaks(1))
        
            % Translate accumulator array output
            translated_row = peaks(i, 1) * sqrt(pixels_per_bin);
            translated_col = peaks(i, 2) * sqrt(pixels_per_bin);
        
            % % Use R-Table to draw detected shape
            % for entry = 1:length(R)
            % 
            %     r_coord = round(translated_row + R(entry, 1)*peaks(i, 3)*sin(R(entry, 2)));
            %     c_coord = round(translated_col + R(entry, 1)*peaks(i, 3)*cos(R(entry, 2)));
            % 
            %     if r_coord > 0 && r_coord <= nrow && c_coord > 0 && c_coord <= ncol
            %         final(r_coord, c_coord) = 0;
            %     end
            % end
    
            % Draw 5px diamter circle at center of detected shape
            for r = 1:nrow
                for c = 1:ncol
                    if ((r-translated_row)^2 + (c-translated_col)^2 <= 5^2)
                        final(r,c, :) = 155;
                    end
                end
            end
            disp(file_index + " - Peak Detected at (" + translated_row + ", " + translated_col + ")" + " with " + peaks(i, 4) + " counts.");
        end
        
        final = final(1:nrow, 1:ncol, :);
        
        figure; imshow(final); title(file_index + " - Detected shapes shown in gray.");
    end

end