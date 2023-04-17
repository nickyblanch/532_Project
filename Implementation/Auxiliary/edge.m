function [f1, f2, M, A, E] = edge(im, radius, threshold)

% Size of original image
[m_orig, n_orig] = size(im);

% Pad image
im = padarray(im, [radius, radius], 'symmetric');

% Size of padded image
[nrow, ncol] = size(im);

% Pre-allocate arrays
f1 = double(zeros(nrow, ncol));
f2 = double(zeros(nrow, ncol));
M = double(zeros(m_orig, n_orig));
A = double(zeros(m_orig, n_orig));
E = false(m_orig, n_orig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gradient calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For every pixel in the image:
for r = radius+1:nrow-radius
    for c = radius+1:ncol-radius
        
        % Find the derivative in the n1 direction
        f1(r, c) = double(median( [im(r-1, c+1), im(r, c+1), im(r+1, c+1)] )) - double(median( [im(r-1, c-1), im(r, c-1), im(r+1, c-1)] ));
        
        % Find the derivative in the n2 direction
        f2(r, c) = double(median( [im(r-1, c-1), im(r-1, c), im(r-1, c+1)] )) - double(median( [im(r+1, c-1), im(r+1, c), im(r+1, c+1)] ));
        
    end
end

% Un-pad results
f1 = f1(radius+1:nrow-radius, radius+1:ncol-radius);
f2 = f2(radius+1:nrow-radius, radius+1:ncol-radius);

% Calculate the gradient magnitude
M = sqrt(f2.^2 + f1.^2);
        
% Calculate the gradient direction
A = atan2(f2, f1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NMS (Interpolation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nrow = m_orig;
ncol = n_orig;

for r = 1:nrow
    for c = 1:ncol
        
        % Gradient magnitude and angle at these coordinates
        M0 = M(r,c);
        A0 = A(r,c);
        
        if A0 < 0 % 𝜃 and −𝜃 are the same line
            A0 = A0 + pi;
        end
        if A0 < pi/4 % 0 ≤ 𝜃 < 45°
            if r-1 >= 1 && c+1 <= ncol && tan(A0)*M(r-1,c+1)+(1-tan(A0))*M(r,c+1) > M0
                E(r,c) = true;
            end
            if r+1 <= nrow && c-1 >= 1 && tan(A0)*M(r+1,c-1)+(1-tan(A0))*M(r,c-1) > M0
                E(r,c) = true;
            end
        elseif A0 >= pi/4 && A0 < pi/2 % 45° ≤ 𝜃 < 90°
            if r-1 >= 1 && c+1 <= ncol && cot(A0)*M(r-1,c+1)+(1-cot(A0))*M(r-1,c) > M0
                E(r,c) = true;
            end
            if r+1 <= nrow && c-1 >= 1 && cot(A0)*M(r+1,c-1)+(1-cot(A0))*M(r+1,c) > M0
                E(r,c) = true;
            end
        elseif A0 >= pi/2 && A0 < 3*pi/4 % 90° ≤ 𝜃 < 135°
            if r-1 >= 1 && c-1 >= 1 && -cot(A0)*M(r-1,c-1)+(1+cot(A0))*M(r-1,c) > M0
                E(r,c) = true;
            end
            if r+1 <= nrow && c+1 <= ncol && -cot(A0)*M(r+1,c+1)+(1+cot(A0))*M(r+1,c) > M0
                E(r,c) = true;
            end
        elseif A0 >= 3*pi/4 % 135° ≤ 𝜃 ≤ 180°
            if r-1 >= 1 && c-1 >= 1 && -tan(A0)*M(r-1,c-1)+(1+tan(A0))*M(r,c-1) > M0
                E(r,c) = true;
            end
            if r+1 <= nrow && c+1 <= ncol && -tan(A0)*M(r+1,c+1)+(1+tan(A0))*M(r,c+1) > M0
                E(r,c) = true;
            end
        end
    end % for c
 end % for r
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thresholding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for r = 1:nrow
    for c = 1:ncol
        if M(r, c) < threshold
            E(r, c) = true;
        end
    end % for c
end % for r

% E = ~E;

end