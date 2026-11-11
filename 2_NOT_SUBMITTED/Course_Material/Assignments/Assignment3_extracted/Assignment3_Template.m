%% Assignment 3 - Fall 2026
% SIFT Feature Detection, Matching, and Image Registration Using RANSAC
% Name:
% Student ID:
% Date:
% Answers to conceptual questions must be added as comments inside this script.
clear; close all; clc;

% Note rng(0): Sets the seed of the random number generator to 0.
% This forces pseudo-random functions like rand, randn, or randomized algorithms
% to generate the identical sequence of numbers on every execution.
rng(0); % Reproducible robust estimation

%% Task 1 - Load and Validate Images
% TODO: Load image1.jpg and image2.jpg, validate them, display side-by-side,
% and report size and data type.

%% Task 2 - Convert to Grayscale
% TODO: Convert both input images to grayscale using im2gray.

%% Task 3 - Detect and Visualize SIFT Features
% TODO: Detect SIFT points, report counts, and show strongest features.

%% Task 4 - Extract Descriptors and Match Features
% TODO: Extract descriptors and use matchFeatures.
% Suggested starting parameters: MaxRatio=0.75, Unique=true.

%% Task 5 - Filter and Evaluate Putative Matches
% TODO: Display putative matches and explain the selected ratio threshold.

%% Task 6 - Estimate Projective Transform Using RANSAC/MSAC
% TODO: Use estgeotform2d(...,'projective',...) and display inlier matches.
% TODO: Print the 3-by-3 transformation matrix and inlier ratio.

%% Task 7 - Register Images
% TODO: Determine panorama limits, create imref2d, and warp both images.

%% Task 8 - Combine and Display Results
% TODO: Warp masks, copy non-overlap pixels,
% display the panorama, and save it as Combined.jpg.

%% Task 9 - Analyze Results
% TODO: Report feature/match/inlier counts and discuss registration quality.


%% Task 10 - Testing the Registration Pipeline on a Challenging Image Pair
% Q1:
% Q2:
% Q3:
% Q4:
% Q5:
% Q6

%% Task 11 - Answer Conceptual Questions
% Q1:
% Q2:
% Q3:
% Q4:
% Q5:

