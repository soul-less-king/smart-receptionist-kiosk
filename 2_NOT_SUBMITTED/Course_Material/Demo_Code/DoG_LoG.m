%% Extracting Interest Points and Their Descriptors: SIFT Features
% - Sobel Edge Detection (slide 7, 8)Laplacian of Gaussian (LoG) Filtering across
%   various scale values ($\sigma$) as shown in Example 1 (slides 31–41)
% - Difference of Gaussians (DoG) approximation to LoG (slides 18, 19, 20)
%  -Gaussian and DoG Pyramid Generation (slides 23–30)   

%% Demo 1: Scale-Space, LoG, DoG, and Pyramids (No SIFT)
% Clear environments
clear; clc; close all;

% 1. Read input image or create a synthetic test image if not provided
try
    img = imread('cameraman.tif'); % Built-in MATLAB image
catch
    % Create synthetic butterfly-like or shape image if standard image fails
    img = zeros(256, 256, 'uint8');
    [X, Y] = meshgrid(1:256, 1:256);
    img(((X-128).^2 + (Y-128).^2) <= 50^2) = 255;
end

if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end
img_double = im2double(img_gray);

%% 2. Sobel Edge Detection (Slides 7-8)
dx = [-1 0 1; -2 0 2; -1 0 1];
dy = dx';
Gx = conv2(img_double, dx, 'same');
Gy = conv2(img_double, dy, 'same');
grad_mag = sqrt(Gx.^2 + Gy.^2);

figure('Name', 'Part 1: Sobel Edge Detection');
subplot(2, 2, 1); imshow(img_double); title('Original Image');
subplot(2, 2, 2); imshow(Gx, []); title('Gradient Gx');
subplot(2, 2, 3); imshow(Gy, []); title('Gradient Gy');
subplot(2, 2, 4); imshow(grad_mag, []); title('Sobel Magnitude');

%% 3. Laplacian of Gaussian (LoG) at Various Scales (Slides 31-41)
% Demonstrates responses at increasing values of sigma (2.0 to 15.0)
sigmas = [2.0, 2.5018, 3.1296, 4.8972, 7.6631, 15.0];
figure('Name', 'Part 1: LoG at Various Scales (Slides 32-41)');

for i = 1:length(sigmas)
    s = sigmas(i);
    % LoG Filter h(m,n) size: The digital approximation to the LoG (2N +1)×(2N +1)
    % truncate h(m,n) at N = 3 times the radius of Guassian sqrt(2)*sigma or simply sigma
    hSize = 2 * ceil(3 * s) + 1; 
    % create the LoG filter using fspecial function in matlab
    hLoG = fspecial('log', hSize, s);
    log_response = abs(imfilter(img_double, hLoG, 'replicate'));
    % Note: The main purpose of using the 'replicate' boundary option in MATLAB's 
    % imfilter function is to handle border padding during spatial convolution or filtering.
    % When applying a filter kernel (such as a Gaussian, Laplacian, or Sobel filter) to an image,
    % the kernel extends beyond the edges of the image when processing border pixels. 
    % MATLAB must pad the outer edges of the image with artificial values to perform the neighborhood calculations.

    subplot(2, 3, i);
    imshow(log_response, []);
    title(sprintf('\\sigma = %.4f', s));
end

%% 4. DoG Approximation vs. LoG (Slides 18-21)
% LoG(f) ~ DoG(f) = G(s1) - G(s2)
sigma1 = 3.0;
k = 1.2;
sigma2 = k * sigma1;

g1 = imgaussfilt(img_double, sigma1);
g2 = imgaussfilt(img_double, sigma2);
DoG_map = g2 - g1;

% Normalized LoG for comparison
hLoG_norm = (sigma1^2) * fspecial('log', 2*ceil(3*sigma1)+1, sigma1);
LoG_map = imfilter(img_double, hLoG_norm, 'replicate');

figure('Name', 'Part 1: DoG Approximation to LoG (almost same)');
subplot(1, 2, 1); imshow(abs(LoG_map), []); title(sprintf('Normalized LoG (\\sigma = %.1f)', sigma1));
subplot(1, 2, 2); imshow(abs(DoG_map), []); title(sprintf('DoG Approximation (\\sigma_1=%.1f, \\sigma_2=%.1f)', sigma1, sigma2));

%% 5. Gaussian & DoG Pyramid (Slides 23-30)
num_octaves = 3;
scales_per_octave = 3;

gauss_pyramid = cell(num_octaves, scales_per_octave + 1);
dog_pyramid = cell(num_octaves, scales_per_octave);

base_img = img_double;
sigma_base = 1.6;

for o = 1:num_octaves
    current_img = base_img;

    % Dealing the scales within each octave
    for i = 1:scales_per_octave + 1
        k_factor = sigma_base * 1/(2^scales_per_octave); % s=3 (slide 28)
        s_eff =  k_factor*2^(i-1);
        gauss_pyramid{o, i} = imgaussfilt(current_img, s_eff);
    end
    
    % Compute Difference of Gaussians (DoG) for this octave
    for s = 1:scales_per_octave
        dog_pyramid{o, s} = gauss_pyramid{o, s+1} - gauss_pyramid{o, s};
    end
    
    % Downsample for the next octave (Slide 23, 24)
    base_img = imresize(gauss_pyramid{o, scales_per_octave+1}, 0.5, 'bilinear');
end

% Plot Pyramid Levels
figure('Name', 'Part 1: DoG Pyramid Across Octaves (Slide 30)');
for o = 1:num_octaves
    for s = 1:scales_per_octave
        subplot(num_octaves, scales_per_octave, (o-1)*scales_per_octave + s);
        imshow(dog_pyramid{o, s}, []); % Flat Regions (Zero) Displayed as Gray, some intensities are negative
        % Note: Positives appear White, Negatives appear Black, flat regions appear Gray
        title(sprintf('Octave %d, Scale %d', o, s));
    end
end

% Plot Absolute Pyramid Levels
figure('Name', 'Part 1: Absolute DoG Pyramid Across Octaves (Slide 30)');
for o = 1:num_octaves
    for s = 1:scales_per_octave
        subplot(num_octaves, scales_per_octave, (o-1)*scales_per_octave + s);
        imshow(abs(dog_pyramid{o, s}), []); % Flat Regions (Zero) Displayed as Black, range [0, 255]
        % Note: All strong responses appear White. All other regions are
        % black.
        % Weak responses appear as shades of gray, while high contrast changes
        % (strong edges or blobs) appear bright white.
        title(sprintf('Octave %d, Scale %d', o, s));
    end
end