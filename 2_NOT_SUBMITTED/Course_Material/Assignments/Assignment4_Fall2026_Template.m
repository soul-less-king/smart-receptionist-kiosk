%% Assignment 4 - Fall 2026
% Image Stitching and Panoramic View Creation
% Name:
% Student ID:
% Date:
%
% Instructions:
% 1. Complete every TODO item.
% 2. Keep image1.jpg through image5.jpg and MobilePanorama.jpg in the
%    current MATLAB folder.
% 3. Add answers to all conceptual questions as comments in Task 9.
% 4. Do not use blending, feathering, multiband blending, or an automatic
%    panorama application.

clear; close all; clc;
rng(0);

%% Task 1 - Capture the Input Images
% TODO:
% Capture at least five overlapping images in left-to-right order.
% Maintain approximately 30% to 40% overlap between consecutive images.
% Save the files as image1.jpg through image5.jpg.
% Capture the same scene using the phone panorama mode and save it as
% MobilePanorama.jpg.

%% Task 2 - Load and Preprocess the Images
imageFiles = {'image1.jpg','image2.jpg','image3.jpg', ...
              'image4.jpg','image5.jpg'};
numImages = numel(imageFiles);
assert(numImages >= 5,'At least five images are required.');

targetSize = [300 400]; % You can try original or other sizes [600 800]
colorImages = cell(numImages,1);
grayImages  = cell(numImages,1);

% TODO: Load, validate, resize, and store the color and grayscale images.

% TODO: Display the resized input images in capture order.

%% Task 3 - Detect and Match Consecutive SIFT Features
% TODO: Detect and extract SIFT features from the first image.

% Initialize the transformation and image-size arrays.
tforms(numImages) = projtform2d;
tforms(1) = projtform2d(eye(3));
imageSize = zeros(numImages,2);

% TODO: Store the first grayscale image size.

% TODO: Create a loop from Image 2 through Image 5 that:
% 1. Detects and extracts SIFT features from the current image.
% 2. Matches the current descriptors with the previous descriptors.
% 3. Uses MatchThreshold=40, MaxRatio=0.75, and Unique=true.
% 4. Displays the putative matches.
% 5. Verifies that at least four matches were found.

%% Task 4 - Estimate and Accumulate Projective Transformations
% Complete this task inside the loop created in Task 3.
%
% TODO: For each consecutive image pair:
% 1. Estimate a projective transformation with estgeotform2d.
% 2. Use MaxDistance=4, Confidence=99.9, and MaxNumTrials=5000.
% 3. Report the number of inliers and the inlier ratio.
% 4. Display the geometrically consistent inlier matches.
% 5. Accumulate the current transformation into the common coordinates.
% 6. Update the previous descriptors and valid points.

%% Task 5 - Select a Center Image
% TODO:
% 1. Find the transformed x- and y-limits of every image.
% 2. Select an image near the horizontal center of the sequence.
% 3. Change all transformations so the center image is the reference.
% 4. Recalculate the transformed limits.

%% Task 6 - Warp and Directly Combine the Color Images
% TODO:
% 1. Determine an output coordinate system large enough for all images.
% 2. Create outputRef using imref2d.
% 3. Initialize combinedImage and combinedMask.
% 4. Warp every color image and its binary validity mask.
% 5. Copy valid pixels channel by channel. Do not blend overlapping pixels.
% 6. Display and save ManualPanorama.jpg.

%% Task 7 - Crop Large Empty Outer Borders
% TODO:
% Use combinedMask to find the first and last valid rows and columns.
% Crop the large empty rectangular border, display the result, and save it
% as ManualPanorama_Cropped.jpg.

%% Task 8 - Compare With the Mobile-Phone Panorama
% TODO:
% Load MobilePanorama.jpg and display it with the cropped manual panorama.
% Discuss alignment, duplicated structures, distortion, visible seams,
% brightness/color differences, cropping, field of view, and overall quality.

%% Task 9 - Conceptual Questions
% Add each answer below as MATLAB comments.
%
% Q1. Why should consecutive images have approximately 30% to 40% overlap?
% Answer:
%
% Q2. Why should the camera rotate around approximately the same position
% instead of translating between captures?
% Answer:
%
% Q3. Why are SIFT features useful for matching overlapping images?
% Answer:
%
% Q4. What is the purpose of the feature-matching ratio criterion?
% Answer:
%
% Q5. What is the purpose of RANSAC/MSAC during projective transformation
% estimation?
% Answer:
%
% Q6. Why must pairwise transformations be accumulated when more than two
% images are registered?
% Answer:
%
% Q7. Why is an image near the middle selected as the reference image?
% Answer:
%
% Q8. What may happen if two consecutive images have insufficient overlap?
% Answer:
%
% Q9. Why can directly combined registered images contain visible seams?
% Answer:
%
% Q10. What do duplicated edges or objects indicate about registration?
% Answer:
%
% Q11. Does a visible seam necessarily mean registration failed? Explain.
% Answer:
%
% Q12. Why might the mobile-phone panorama appear more polished?
% Answer:

