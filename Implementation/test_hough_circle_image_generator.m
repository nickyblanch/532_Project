% Creating circle test image
output = zeros(200, 200);
for i = 1:200
    for j = 1:200
        if (abs(20^2 - ((i-69)^2 + (j-67)^2)) <= 60)
            output(i, j) = 1;
        end
    end
end
imshow(255*uint8(~output));
imwrite(uint8(~output), "circle.png");