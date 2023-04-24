function [out] = dilate(im, structuring_element_size, foreground_zero)

%%%%%%%%%%%%%%%%%%%%%%
% INPUT:  im, an image
% OUTPUT: out, an image
%%%%%%%%%%%%%%%%%%%%%%

% Image size
[nrow, ncol] = size(im);
R = (structuring_element_size - 1)/2;

% Pad image with background
out = padarray(im, [(structuring_element_size-1)/2, (structuring_element_size-1)/2], 1);
copy = out;

% For each pixel in the original image
for r = R+1:nrow + R
    for c = R+1:ncol + R

        % If it is a foreground pixel
        if(copy(r,c) == 0)

            % Make the surrounding pixels foreground, as defined by square
            % structuring element
            out(r-R:r+R, c-R:c+R) = 0;
        end
    end
end

% Un-pad image
out = out(R+1:nrow+R, R+1:ncol+R);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WORK IN PROGESS (IGNORE)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Make sure that foreground is '1' and background is '0'
% if foreground_zero
%     out = ~im;
% else
%     out = im;
% end
% 
% % Pad image with background around the edges
% out = padarray(out, [(structuring_element_size-1)/2, (structuring_element_size-1)/2], 0);
% copy = out;
% 
% % Structuring element
% structure = ones(structuring_element_size);
% 
% % For each value of the structuring element
% for structure_r = -1*(structuring_element_size - 1)/2:(structuring_element_size - 1)/2
%     for structure_c = -1*(structuring_element_size - 1)/2:(structuring_element_size - 1)/2
% 
%         % For each pixel in the original image
%         for r = (structuring_element_size - 1)/2+1:nrow + (structuring_element_size - 1)/2
%             for c = (structuring_element_size - 1)/2+1:ncol + (structuring_element_size - 1)/2
% 
%                 % Or the pixel with the shifted version as defined by
%                 % structure
%                 if(structure(structure_r + (structuring_element_size + 1)/2, structure_c  + (structuring_element_size + 1)/2))
%                     out(r, c) = copy(r, c) | copy(r + structure_r, c + structure_c);
%                 end
%             end
%         end
%     end
% end
% 
% % Return the image to its original state 
% if foreground_zero
%     out = ~out;
% end