% 3D Geometric Transformations Hierarchy Visualization for a Cube
clear; clc; close all;

%% 1. Define 3D Unit Cube
% 8 vertices of a unit cube
v = [0 0 0; 1 0 0; 1 1 0; 0 1 0; ... % Bottom face vertices (1-4)
     0 0 1; 1 0 1; 1 1 1; 0 1 1]';   % Top face vertices (5-8)

% Extend to 4x8 homogeneous coordinates [x; y; z; 1]
cube_pts = [v; ones(1, 8)];

% Define 6 faces using vertex indices (for fill3/patch plotting)
faces = [1 2 3 4;   % Bottom face
         5 6 7 8;   % Top face
         1 2 6 5;   % Front face
         2 3 7 6;   % Right face
         3 4 8 7;   % Back face
         4 1 5 8];  % Left face

%% 2. Define 3D Homogeneous Transformation Matrices (4x4)

% --- Original Identity Matrix ---
H_orig = eye(4);

% --- 1. Translation (3 DoF) ---
tx = 1.5; ty = 0.8; tz = 0.5;
H_trans = [1 0 0 tx;
           0 1 0 ty;
           0 0 1 tz;
           0 0 0  1];

% --- 2. Rigid / Euclidean (6 DoF: 3D Rotation + Translation) ---
% 3D Rotation around Z and X axes
theta_z = pi/6; % 30 deg
theta_x = pi/8; % 22.5 deg
Rz = [cos(theta_z) -sin(theta_z) 0; sin(theta_z) cos(theta_z) 0; 0 0 1];
Rx = [1 0 0; 0 cos(theta_x) -sin(theta_x); 0 sin(theta_x) cos(theta_x)];
R = Rz * Rx;

H_rigid = [R, [tx; ty; tz];
           0 0 0 1];

% --- 3. Similarity (7 DoF: Scale + Rotation + Translation) ---
s = 1.4; % Scale factor
H_sim = [s*R, [tx; ty; tz];
         0 0 0 1];

% --- 4. Affine (12 DoF: Non-uniform Scale, Shearing, Rotation, Translation) ---
A = [1.2, 0.4, 0.1;  % Linear 3x3 matrix (non-uniform scale + shear)
     0.2, 0.9, 0.3;
     0.1, 0.2, 1.1];
H_affine = [A, [tx; ty; tz];
            0 0 0 1];

% --- 5. Projective / Homography (15 DoF: Perspective Warping / Keystoning) ---
% Non-zero bottom row entries [v^T, v4] create 3D perspective distortion
H_proj = [1.2, 0.2, 0.1, 0.5;
          0.1, 1.1, 0.2, 0.3;
          0.2, 0.1, 0.9, 0.2;
          0.15, 0.1, 0.2, 1.0];

% Cell array collections
transforms = {H_orig, H_trans, H_rigid, H_sim, H_affine, H_proj};
titles = {'Original Cube', ...
          '1. Translation (3 DoF: Preserves Orientation)', ...
          '2. Rigid / Euclidean (6 DoF: Preserves Lengths)', ...
          '3. Similarity (7 DoF: Preserves Angles)', ...
          '4. Affine (12 DoF: Preserves Parallelism)', ...
          '5. Projective (15 DoF: Preserves Straight Lines)'};

%% 3. Visualization
figure('Color', 'w', 'Position', [50, 50, 1200, 750]);

for i = 1:length(transforms)
    subplot(2, 3, i);
    hold on; grid on; axis equal;
    view(3); % Set 3D perspective view
    
    % Transform points
    transformed_pts_hom = transforms{i} * cube_pts;
    
    % Perspective division by 4th coordinate (w)
    X = transformed_pts_hom(1, :) ./ transformed_pts_hom(4, :);
    Y = transformed_pts_hom(2, :) ./ transformed_pts_hom(4, :);
    Z = transformed_pts_hom(3, :) ./ transformed_pts_hom(4, :);
    
    P_trans = [X; Y; Z]';
    P_orig  = cube_pts(1:3, :)';
    
    % Plot original cube reference in dashed blue wireframe
    patch('Vertices', P_orig, 'Faces', faces, 'FaceColor', 'none', ...
          'EdgeColor', 'b', 'LineStyle', '--', 'LineWidth', 1.2, ...
          'DisplayName', 'Original');
      
    % Plot transformed cube in semi-transparent red
    patch('Vertices', P_trans, 'Faces', faces, 'FaceColor', 'r', ...
          'FaceAlpha', 0.35, 'EdgeColor', 'r', 'LineWidth', 1.5, ...
          'DisplayName', 'Transformed');
      
    title(titles{i}, 'FontSize', 9, 'FontWeight', 'bold');
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
    % Set uniform plot bounds
    xlim([-1, 4]); ylim([-1, 4]); zlim([-1, 4]);
    
    if i == 1
        legend('Location', 'northeast');
    end
end