
clear; clc;

% Creating circle test image
output = zeros(200, 200);
for i = 1:200
    for j = 1:200
        % if (abs(20^2 - ((i-69)^2 + (j-67)^2)) <= 60)
        %     output(i, j) = 1;
        % end
        % if (abs(10^2 - ((i-131)^2+(j-131)^2)) <= 20)
        %     output(i, j) = 1;
        % end

        if abs((i-69)^2 + (j-67)^2) <= 20^2
            output(i, j) = 1;
        elseif abs((i-131)^2 + (j-131)^2) <= 10^2
            output(i, j) = 1;
        elseif j == i + 80
            output(i, j) = 1;
        end
    end
end
output(150:175, 20:45) = 1;
output = 255*uint8(~output);
imshow(output);
imwrite(output, ".\Test Images\Example Images (Unused)\circle.png");