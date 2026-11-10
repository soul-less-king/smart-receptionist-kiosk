%% TestHomographyStudents.m

% Reads an image, marks points of interest and their projected
% (rectified) positions, computes a projective transform (homography)
% between them, and warps the image accordingly.

clear; clc; close all;

%% Cell 1: Read and display the image
img = imread('b3.PNG');

figure('Name', 'Original Image');
imshow(img);
title('Original');

%% Cell 2: Define points of interest and their projection, plot them
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X: points_of_interest
if true

    XY = [151, 103;
        227, 120;
        154, 191;
        231, 202];
else

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use ginput to select 4 points of interest on the original image.
    % Click the 4 points in the figure window, in order.

    numPoints = 4;

    figure('Name', 'Select Points of Interest');
    imshow(img);
    title(sprintf('Click %d points of interest (in order)', numPoints));

    [x, y] = ginput(numPoints);

    % Organize selected points into the XY matrix (columns: x, y)
    XY = [x, y];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% projection
XY_p = [151, 103;
        251, 103;
        151, 220;
        251, 220];

markerColor = 'red';
markerRadius = 10;

figure('Name', 'Points of Interest');

% Left subplot: original image with points of interest
subplot(1,2,1);
imshow(img);
hold on;
for i = 1:size(XY,1)
    rectangle('Position', [XY(i,1)-markerRadius, XY(i,2)-markerRadius, ...
                            2*markerRadius, 2*markerRadius], ...
               'Curvature', [1 1], 'FaceColor', markerColor, 'EdgeColor', 'none');
end
hold off;
axis on
title('Points of Interest');

% Right subplot: blank canvas (ones) with projected points
subplot(1,2,2);
blankCanvas = ones(size(img,1), size(img,2));
imshow(blankCanvas);
hold on;
for i = 1:size(XY_p,1)
    rectangle('Position', [XY_p(i,1)-markerRadius, XY_p(i,2)-markerRadius, ...
                            2*markerRadius, 2*markerRadius], ...
               'Curvature', [1 1], 'FaceColor', markerColor, 'EdgeColor', 'none');
end
grid on
hold off;
axis on
title('Projection');

%% Cell 3: Estimate projective transform and warp the image
points_of_interest = XY;
projection = XY_p;

% Fit a projective (homography) transform mapping points_of_interest -> projection
tform = fitgeotrans(points_of_interest, projection, 'projective');

% Warp the image using the transform, keeping the output canvas the same
% size as the input image (equivalent to skimage's default warp behavior)
outputView = imref2d(size(img));
tf_img_warp = imwarp(img, tform, 'OutputView', outputView);

figure('Name', 'Homography Result');
subplot(1,2,1);
imshow(img);
title('Original', 'FontSize', 15);
axis off;

subplot(1,2,2);
imshow(tf_img_warp);
title('Transformed', 'FontSize', 15);
axis off;
