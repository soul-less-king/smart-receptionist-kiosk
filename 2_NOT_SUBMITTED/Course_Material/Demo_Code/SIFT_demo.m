%% Demo 2: SIFT Feature Extraction, Orientation, and Matching
% Clear environment
clear all; clc; close all;

%% This script implements the full SIFT workflow from Part 2 of the slides
% (slides 42–71) using MATLAB s Computer Vision Toolbox (detectSIFTFeatures
% and extractFeatures):
% - DoG Scale-Space Keypoint Detection (Steps 1–3, slides 44–55)
% - Dominant Orientation Assignment (Step 4, slides 59–61)   
% - 128-D SIFT Descriptor Construction (Step 5, slides 64–70)   
% - Point Matching across rotated/scaled image pair (slide 58, 71)

%% 1. Load Reference Image & Create Transformed Image (Scale + Rotation)
try
    img1 = imread('cameraman.tif');
catch
    % Create fallback image
    img1 = zeros(256, 256, 'uint8');
    img1(50:200, 50:200) = 180;
    img1(80:120, 80:120) = 50;
end

if size(img1, 3) == 3
    img1 = rgb2gray(img1);
end

% Apply 30-degree rotation and 1.2x scaling to simulate real image pair
img2 = imrotate(img1, 30, 'bilinear', 'crop');
img2 = imresize(img2, 1.2);

%% 2. SIFT Keypoint Detection (Steps 1-3: DoG Extrema & Thresholding)
% detectSIFTFeatures finds scale-space extrema in DoG space
points1 = detectSIFTFeatures(img1);
points2 = detectSIFTFeatures(img2);

% Display SIFT Interest Points with Scale & Orientation (Slide 55, 62)
figure('Name', 'Part 2: SIFT Keypoint Detection & Principal Orientations');
subplot(1, 2, 1);
imshow(img1); hold on;
plot(points1.selectStrongest(50)); % Plot circles representing scale and lines for orientation
title('Image 1: Top 50 SIFT Keypoints (Scale/Orientation)');

subplot(1, 2, 2);
imshow(img2); hold on;
plot(points2.selectStrongest(50));
title('Image 2: Transformed Top 50 SIFT Keypoints');

%% 3. SIFT Descriptor Extraction (Step 5: 128-D Descriptors)
% Extract 128-dimensional orientation histogram descriptors
[features1, validPoints1] = extractFeatures(img1, points1, 'Method', 'SIFT');
[features2, validPoints2] = extractFeatures(img2, points2, 'Method', 'SIFT');

fprintf('Extracted %d SIFT descriptors (Dimension: %d) from Image 1\n', ...
    size(features1, 1), size(features1, 2));

%% 4. Match SIFT Descriptors Between Images (Slide 71)
% Find point-to-point correspondences using Descriptor Distances
match_threshold = 0.3; %Max value is 100 (very loose)
indexPairs = matchFeatures(features1, features2, 'MatchThreshold', match_threshold, 'MaxRatio', 0.8);

matchedPoints1 = validPoints1(indexPairs(:, 1));
matchedPoints2 = validPoints2(indexPairs(:, 2));

% Display Feature Correspondences (Slide 71)
figure('Name', 'Part 2: SIFT Feature Matching');
ax = axes;
showMatchedFeatures(img1, img2, matchedPoints1(), matchedPoints2(), 'montage', 'Parent', ax);
title(ax, sprintf('SIFT Feature Correspondences (%d Matches Found)', length(matchedPoints1)));
