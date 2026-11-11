%% Assignment 2: Introduction to Image Processing and Computer Vision in MATLAB
%
% Name: _______
% Date: _______
% Semester: Fall 2026
% Computer Vision CMAI 480

%
% This is the template for Assignment 2. Divide your script into cells
% using %% as shown below -- keep the section headers ("%% Question N")
% the same so it is easy to grade. You may add extra cells within a
% question if you like.
%
% You can execute a "cell" (from one %% to the next) by placing your
% cursor in it and pressing Ctrl-Enter.
%

%% Question 1
% Image Acquisition
% Capture an image of an object of your choice (or your face, if
% permitted) using your webcam and save it as input.png.
%
%   cam = webcam;
%   preview(cam);
%   pause;                  % position your object, then hit Enter
%   img = snapshot(cam);
%   closePreview(cam);
%   clear cam
%   imshow(img);
%   imwrite(img,'input.png');



%% Question 2
% Opening and Displaying an Image
% 2.1 Load input.png.
% 2.2 Display it with both imshow() and image(); note the difference.
% 2.3 Determine width, height, number of channels, and data type.
% 2.4 Print all four properties to the Command Window.



%% Question 3
% Interesting Point Selection and Image Patch Extraction
% 3.1 Use ginput() to click a high-contrast point (corner/edge/boundary).
% 3.2 Store the coordinates in i and j; print them and the RGB values of
%     that pixel to the Command Window.
% 3.3 Extract a ~10x10x3 color patch centered on that pixel and display it.
% 3.4 Print the RGB values of the patch and include the printed output as
%     a comment in your submitted file, e.g.:
%       % Ismall(:,:,1) =
%       % 221 222 215 ...



%% Question 4
% RGB Channel Analysis
% 4.1 Extract an image containing only the red channel information.
% 4.2 Extract an image containing only the green channel information.
% 4.3 Extract an image containing only the blue channel information.
% 4.4 Also display I(:,:,1), I(:,:,2), I(:,:,3) directly with imshow()
%     and observe how brightness varies per channel.



%% Question 5
% Grayscale Image Conversion
% 5.1 Manually average the three channels (cast to double first, no
%     loops) to create a grayscale image.
% 5.2 Convert the same image to grayscale using rgb2gray().
% 5.3 Display both results side-by-side and explain any differences.



%% Question 6
% Image Filtering and Gaussian Smoothing
% 6.1 Create a 3x3 averaging filter and apply it (imfilter) to the
%     grayscale image from Question 5.
% 6.2 Apply a Gaussian filter to the same grayscale image.
% 6.3 Display original / averaged / Gaussian-smoothed images together
%     (subplot).
% 6.4 In a comment, describe how each filter affects noise, sharp edges,
%     and fine detail, and say which preserves edges better and why.
% 6.5 In a comment, answer: why should a smoothing filter's coefficients
%     generally sum to 1? What happens if they sum to 0.5 instead of 1?
%     What happens if they sum to 2 instead of 1?



%% Question 7
% Edge Detection Using Derivative Filters
% 7.1 Apply the horizontal derivative filter Dx = [-1 0 1] to the
%     smoothed grayscale image from Question 6.
% 7.2 Apply the vertical derivative filter Dy = Dx' to the same image.
% 7.3 Display the original image and both derivative images together
%     (subplot).
% 7.4 Apply MATLAB's Sobel edge detector: BWsobel = edge(I,'sobel');
% 7.5 Apply MATLAB's Prewitt edge detector: BWprewitt = edge(I,'prewitt');
% 7.6 Apply MATLAB's Canny edge detector: BWcanny = edge(I,'canny');
% 7.7 Display all edge results together (subplot).
% In a comment, answer: why should the coefficients of a derivative
% (edge) filter sum to 0? (Hint: what should happen where intensity is
% constant?)



%% Question 8
% Gradient Magnitude and Orientation Analysis
% 8.1 Using dIdi and dIdj from Question 7, compute the gradient
%     magnitude image M.
% 8.2 Compute the gradient orientation image Theta using atan2().
% 8.3 Display the grayscale image, magnitude image, and orientation
%     image together (subplot).
% 8.4 Compare with MATLAB's built-in gradient functions:
%       [Gx,Gy] = imgradientxy(Igray);
%       [MagBuiltIn,ThetaBuiltIn] = imgradient(Gx,Gy);
% 8.5 Plot a histogram of all orientation values (36 bins, in degrees).
% 8.6 At the point selected in Question 3, report dIdi, dIdj, magnitude,
%     and orientation (in radians and degrees).



%% Question 9
% Image Histograms and Contrast Enhancement
% 9.1 Display the histogram of the grayscale image from Question 5.
% 9.2 In a comment, say whether the image looks dark/bright/high- or
%     low-contrast, and why.
% 9.3 Apply histeq() and display the equalized image.
% 9.4 Display and compare the equalized image's histogram to the original.
% 9.5 Display the original and equalized images side-by-side and discuss
%     the visual differences.



%% Question 10
% Foreground Segmentation, Object Analysis, and Geometric Transformations
% 10.1 Capture a second image of just the background (no object) and
%      save it as background.png.
% 10.2 Compute the absolute difference between input.png and
%      background.png to highlight the object.
% 10.3 Convert the difference image to grayscale and threshold it to
%      create an initial binary mask.
% 10.4 Clean the mask with imfill(...,'holes') and bwareaopen(...).
% 10.5 Use the cleaned mask to extract the segmented object.
% 10.6 Compute object properties (Area, Centroid, BoundingBox) with
%      regionprops().
% 10.7 Draw the bounding box and centroid on the original image.
% 10.8 Using the segmented object image, rotate it 60 degrees clockwise
%      two ways: (1) imrotate(segmented,-60), and (2) a general affine
%      transform (affinetform2d + imwarp). Display both results.