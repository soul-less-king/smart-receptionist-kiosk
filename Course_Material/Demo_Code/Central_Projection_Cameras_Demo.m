% Central Projection Camera Hierarchy Demo
% CMAI 480 Computer Vision

clc; clear; close all;

%% 1. Define a 3D Scene Object (Unit Cube)
% Define 8 vertices of a 3D cube in homogeneous coordinates [X; Y; Z; 1]
vertices_3D = [
    0 1 1 0 0 1 1 0; % X
    0 0 1 1 0 0 1 1; % Y
    4 4 4 4 5 5 5 5; % Z (placed in front of the camera)
    1 1 1 1 1 1 1 1  % Homogeneous scale factor
];

% Cube edges connecting the 8 vertices
edges = [1 2; 2 3; 3 4; 4 1; 5 6; 6 7; 7 8; 8 5; 1 5; 2 6; 3 7; 4 8];

%% 2. Define Shared Calibration Parameters
% Intrinsic matrix K (focal lengths fx, fy, principal point x0, y0, skew s)
fx = 800; fy = 600; 
%x0 = 320; y0 = 240; 
x0 = 0; y0 = 0; 
s = 0;
K = [fx  s x0;
      0 fy y0;
      0  0  1]; % Upper-triangular, non-singular

% Extrinsic matrix [R | t] (Identity rotation, zero translation for simplicity)
R = eye(3);
t = [0; 0; 0];
Rt = [R, t];

%% 3. Camera Projection Matrix Definitions

% A. Pinhole / Physically Realizable Camera: P = K * [R | t]
P_pinhole = K * Rt

% B. Finite Projective Camera: Rank(M) = 3 where P = [M | p4]
% Applies an additional projective distortion matrix
H_proj = [1     0.1     0.2;
          0.05  1       0.1;
          0.001 0.002   1]; 
P_finite = H_proj * P_pinhole 

% C. General Projective Camera: Rank(P) = 3
% A general 3x4 matrix with full rank
P_general = [700    120     300     100;
             20     650     200     50;
             0.001  0.002   0.9     2]

% D. Affine Camera: Last row is [0, 0, 0, 1]
P_affine = [100 20 0  320;
            10 90  0  240;
             0  0  0   1]

% E. True Orthographic Camera: Direct parallel projection without scaling
P_ortho = [ 1 0 0 0; 
            0 1 0 0; 
            0 0 0 1]


% F. Scaled Orthographic Camera: Uniform scale factor 's_ortho'
s_ortho = 180;
K_scaled = [s_ortho   0         x0;
            0       s_ortho     y0;
            0         0         1]; 
P_scaled_ortho = K_scaled * [Rt(1:2,:); 
                             0 0 0 1 ]
% P_scaled_ortho = [s_ortho   0       0   x0; 
%                   0        s_ortho  0   y0; 
%                   0         0       0   1];

% G. Weak Perspective Camera: Approximation assuming scene depth Z ~ Z0
Z0 = 4.5; % Average depth
K_weak = [fx/Z0   0    x0;
            0   fy/Z0  y0;
            0     0     1]; 
P_weak = K_weak * [Rt(1:2,:); 
                    0 0 0 1 ]

%% 4. Plot Projections Side-by-Side

figure('Name', '3D World Scene');
% 3D Original World Scene
hold on; grid on; axis equal;
for e = 1:size(edges, 1)
    plot3(vertices_3D(1, edges(e,:)), vertices_3D(2, edges(e,:)), vertices_3D(3, edges(e,:)), 'r-o', 'LineWidth', 2);
end
plot3(0, 0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8); % Camera origin center
xlabel('X (World)'); ylabel('Y (World)'); zlabel('Z (Depth)');
title('0. Original 3D Scene & Camera Center');
view(3); rotate3d on;
hold off;

cameras = {
    P_pinhole, '1. Pinhole / Physically Realizable';
    P_finite, '2. Finite Projective';
    P_general, '3. General Projective';
    P_affine, '4. Affine Camera';
    P_ortho, '5. Orthographic';
    P_scaled_ortho, '6. Scaled Orthographic';
    P_weak, '7. Weak Perspective'
};

figure('Name', 'Central Projection Camera Hierarchy', 'Position', [100 100 1200 700]);

for i = 1:size(cameras, 1)
    P = cameras{i, 1};
    title_str = cameras{i, 2};
    
    % Perform Camera Projection: x_2D = P * X_3D
    pts_2D_hom = P * vertices_3D;
    
    % Convert from Homogeneous to Cartesian coordinates (divide by 3rd row)
    pts_2D = pts_2D_hom(1:2, :) ./ pts_2D_hom(3, :);
    
    % Plot 2D image plane wireframe
    subplot(2, 4, i);
    hold on; grid on; axis equal;
    for e = 1:size(edges, 1)
        p1 = pts_2D(:, edges(e, 1));
        p2 = pts_2D(:, edges(e, 2));
        plot([p1(1) p2(1)], [p1(2) p2(2)], 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
    end
    title(title_str, 'FontSize', 9);
    xlabel('x (pixels)'); ylabel('y (pixels)');
end