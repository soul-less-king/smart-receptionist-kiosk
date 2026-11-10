% 2D Geometric Transformations Hierarchy Visualization
clear; clc; close all;

% 1. Define original unit square in homogeneous coordinates [x; y; 1]
% Vertices ordered to form a closed loop
square_pts = [0 1 1 0 0;
              0 0 1 1 0;
              1 1 1 1 1];

% 2. Define Transformation Matrices (3x3 homogeneous form)

% --- Original ---
H_orig = eye(3);

% --- 1. Translation (2 DoF) ---
tx = 1.5; ty = 0.5;
H_trans = [1 0 tx;
           0 1 ty;
           0 0  1];

% --- 2. Rigid / Euclidean (3 DoF: Rotation + Translation) ---
theta = pi / 6; % 30 degrees
R = [cos(theta) -sin(theta); 
     sin(theta)  cos(theta)];
H_rigid = [R, [tx; ty];
           0 0 1];

% --- 3. Similarity (4 DoF: Uniform Scale + Rotation + Translation) ---
s = 1.3; % scale factor
H_sim = [s*R, [tx; ty];
         0   0   1];

% --- 4. Affine (6 DoF: Non-uniform Scale, Shear, Rotation, Translation) ---
A = [1.2, 0.5;   % Linear transformation matrix (shear + non-uniform scale)
     0.2, 0.8];
H_affine = [A, [tx; ty];
            0 0 1];

% --- 5. Projective / Homography (8 DoF: Keystoning / Perspective distortion) ---
H_proj = [1.2, 0.3, 0.5;
          0.1, 0.9, 0.2;
          0.3, 0.2, 1.0]; % Non-zero bottom row creates perspective effect

% Pack transformations and labels into cell arrays
transforms = {H_orig, H_trans, H_rigid, H_sim, H_affine, H_proj};
titles = {'Original Square', ...
          '1. Translation (Preserves Orientation)', ...
          '2. Rigid / Euclidean (Preserves Lengths)', ...
          '3. Similarity (Preserves Angles)', ...
          '4. Affine (Preserves Parallelism)', ...
          '5. Projective (Preserves Straight Lines)'};

% 3. Visualization
figure('Color', 'w', 'Position', [100, 100, 1100, 700]);

for i = 1:length(transforms)
    subplot(2, 3, i);
    hold on; grid on; axis equal;
    
    % Apply transformation matrix
    transformed_pts = transforms{i} * square_pts;
    
    % Normalize by homogeneous coordinate w (3rd row) for projective mapping
    X = transformed_pts(1, :) ./ transformed_pts(3, :);
    Y = transformed_pts(2, :) ./ transformed_pts(3, :);
    
    % Plot original reference (dashed blue) and transformed shape (filled red)
    plot(square_pts(1,:), square_pts(2,:), 'b--', 'LineWidth', 1.2, 'DisplayName', 'Original');
    fill(X, Y, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'r', 'LineWidth', 2, 'DisplayName', 'Transformed');
    
    title(titles{i}, 'FontSize', 10, 'FontWeight', 'bold');
    xlabel('X'); ylabel('Y');
    xlim([-1, 3.5]); ylim([-1, 3]);
    
    if i == 1
        legend('Location', 'northwest');
    end
end