%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CCL (Haralick)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [L] = segmentation(im)

%%%%%%%%%%%%%%%%%%%%%%
% INPUT:  im, a binarized image where foreground is nonzero and background
% is zero


% OUTPUT: L
%%%%%%%%%%%%%%%%%%%%%%

% Image size
[nrow, ncol] = size(im);

% Initialize
L = zeros(nrow, ncol);

% First, we must assign a unique label to each foreground pixel
nextlabel = 1;

for r = 1:nrow
    for c = 1:ncol
        if im(r,c) > 0
            L(r,c) = nextlabel;
            nextlabel = nextlabel + 1;
        else
            L(r,c) = 0;
        end
    end
end

% Pad L
L = padarray(L, [1, 1], 0);

% Then, we must iteratively update the labels

change = true;
while change
    change = false;
    
    % Top-down scan
    for r = 1:nrow
        for c = 1:ncol
            
            if L(r,c) > 0 % If a labeled foreground pixel
                neighbors = [ L(r,c) L(r+1,c) L(r-1,c) L(r,c+1) L(r,c-1) L(r+1,c+1) L(r-1,c+1) L(r-1,c+1) L(r-1,c-1) ];
                
                % Find minimum nonzero label among r(c) and its neighbors
                M = min(neighbors(neighbors > 0));
                
                % Set our current foreground pixel to the min
                if M ~= L(r,c)
                    L(r,c) = M;
                    change = true;
                end
            end
        end
    end
    
    % Bottom-up scan
    for r = nrow:1
        for c = ncol:1
            
            if L(r,c) > 0 % If a labeled foreground pixel
                neighbors = [ L(r,c) L(r+1,c) L(r-1,c) L(r,c+1) L(r,c-1) L(r+1,c+1) L(r-1,c+1) L(r-1,c+1) L(r-1,c-1) ];
                
                % Find minimum nonzero label among r(c) and its neighbors
                M = min(neighbors(neighbors > 0));
                
                % Set our current foreground pixel to the min
                if M ~= L(r,c)
                    L(r,c) = M;
                    change = true;
                end
            end
        end
    end
          
end % End while

% Un-pad array
L = L(2:nrow+1, 2:ncol+1);

end