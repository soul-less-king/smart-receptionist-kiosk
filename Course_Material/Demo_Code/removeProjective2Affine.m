% Projective Distortion Rectification to Affine Space
clear; clc; close all;

%% 1. Define Vertices in Homogeneous Coordinates [x; y; 1]
x1 = [5; 5; 1];
x2 = [10; 6; 1];
x3 = [7; 13; 1];
x4 = [9; 11; 1];

%% 2. Compute Bounding Lines via Cross Products (l = p1 x p2)
l1 = cross(x1, x2); % Bottom line
l2 = cross(x3, x4); % Top line
l3 = cross(x1, x3); % Left line
l4 = cross(x2, x4); % Right line

%% 3. Compute Vanishing Points & Vanishing Line
% Intersections of opposite lines
Q = cross(l1, l2); % Vanishing point for horizontal-like lines
P = cross(l3, l4); % Vanishing point for vertical-like lines

% Vanishing line passing through P and Q
l_vanish = cross(P, Q);

% Normalize vanishing line scale so l_vanish(3) = 1 (optional for numerical stability)
l_vanish_norm = l_vanish / l_vanish(3); 
l1_val = l_vanish_norm(1);
l2_val = l_vanish_norm(2);
l3_val = l_vanish_norm(3);

%% 4. Construct the Homography Matrix Hp
% Hp maps the vanishing line to the line at infinity [0, 0, 1]'
Hp = [1,      0,      0;
      0,      1,      0;
      l1_val, l2_val, l3_val];

%% 5. Verify Line Transformation: l' = (Hp^-T) * l_vanish -> [0, 0, 1]'
% Dual line transformation rule
l_infinity_check = inv(Hp)' * l_vanish_norm;
% Normalize to compare with [0; 0; 1]
l_infinity_check = l_infinity_check / l_infinity_check(3);

disp('Transformed Vanishing Line (should be [0; 0; 1]):');
disp(l_infinity_check);

%% 6. Apply Homography to Rectify the Quadrilateral Points
% Point transformation rule: x' = Hp * x
X_orig = [x1, x2, x4, x3, x1]; % Closed boundary

X_rectified_hom = Hp * X_orig;

% Divide by scale factor w (3rd coordinate) to get Euclidean (x,y)
X_rectified = X_rectified_hom(1:2, :) ./ X_rectified_hom(3, :);

%% 7. Visualization
figure('Color', 'w', 'Position', [100, 100, 1000, 450]);

% --- Plot 1: Original Distorted Quadrilateral ---
subplot(1, 2, 1);
plot(X_orig(1, :), X_orig(2, :), 'r-o', 'LineWidth', 2, 'MarkerFaceColor', 'r');
hold on; grid on; axis equal;
title('Original Shape (Projective Distortion)', 'FontSize', 11);
xlabel('X'); ylabel('Y');
text(x1(1), x1(2), ' (5,5)', 'VerticalAlignment', 'top');
text(x2(1), x2(2), ' (10,6)', 'VerticalAlignment', 'top');
text(x3(1), x3(2), ' (7,13)', 'VerticalAlignment', 'bottom');
text(x4(1), x4(2), ' (9,11)', 'VerticalAlignment', 'bottom');

% --- Plot 2: Rectified Shape (Affine Corrected) ---
subplot(1, 2, 2);
plot(X_rectified(1, :), X_rectified(2, :), 'b-s', 'LineWidth', 2, 'MarkerFaceColor', 'b');
hold on; grid on; axis equal;
title('Rectified Shape (Parallelism Restored)', 'FontSize', 11);
xlabel('X'); ylabel('Y');

% Annotate rectified coordinates
for k = 1:4
    text(X_rectified(1, k), X_rectified(2, k), ...
        sprintf(' (%.2f, %.2f)', X_rectified(1, k), X_rectified(2, k)), ...
        'FontSize', 8);
end