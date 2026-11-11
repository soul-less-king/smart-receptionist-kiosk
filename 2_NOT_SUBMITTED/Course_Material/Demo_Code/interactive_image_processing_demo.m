function interactive_image_processing_demo()
    % INTERACTIVE_IMAGE_PROCESSING_DEMO
    % MATLAB App demonstrating Chapter 3 Image Processing core concepts:
    % 1. Pixel Neighborhoods & Distance Metrics
    % 2. Arithmetic & Logic Operations
    % 3. Linear Spatial Filtering & Kernels
    % 4. Canny Edge Detection & Scale Space Analysis

    % Create Main Figure Interface
    fig = uifigure('Name', 'Interactive Image Processing Demo - CMAI 480', ...
                   'Position', [100 100 1200 700]);

    % Create Tab Group
    tabGroup = uitabgroup(fig, 'Position', [10 10 1180 680]);

    % Setup Individual Tabs
    setupTab1_NeighborhoodAndDistance(uitab(tabGroup, 'Title', '1. Neighborhood & Metrics'));
    setupTab2_ArithmeticAndLogic(uitab(tabGroup, 'Title', '2. Arithmetic & Logic'));
    setupTab3_LinearFiltering(uitab(tabGroup, 'Title', '3. Spatial Filtering'));
    setupTab4_CannyAndScaleSpace(uitab(tabGroup, 'Title', '4. Edge & Scale Space'));
end

%% ==================== TAB 1: NEIGHBORHOOD & DISTANCE ====================
function setupTab1_NeighborhoodAndDistance(tab)
    axGrid = uiaxes(tab, 'Position', [50 150 450 450]);
    axDist = uiaxes(tab, 'Position', [550 150 580 450]);

    % UI Controls
    uilabel(tab, 'Position', [50 100 100 22], 'Text', 'Center Pixel p:');
    pX = uispinner(tab, 'Position', [150 100 60 22], 'Limits', [1 9], 'Value', 5);
    pY = uispinner(tab, 'Position', [220 100 60 22], 'Limits', [1 9], 'Value', 5);

    uilabel(tab, 'Position', [310 100 100 22], 'Text', 'Target Pixel q:');
    qX = uispinner(tab, 'Position', [410 100 60 22], 'Limits', [1 9], 'Value', 7);
    qY = uispinner(tab, 'Position', [480 100 60 22], 'Limits', [1 9], 'Value', 8);

    lblMetrics = uilabel(tab, 'Position', [550 60 550 60], 'Text', '', ...
                         'FontWeight', 'bold', 'FontSize', 12);

    % Update Callback
    updateView = @(~,~) refreshTab1();
    pX.ValueChangedFcn = updateView; pY.ValueChangedFcn = updateView;
    qX.ValueChangedFcn = updateView; qY.ValueChangedFcn = updateView;

    refreshTab1();

    function refreshTab1()
        px = pX.Value; py = pY.Value;
        qx = qX.Value; qy = qY.Value;

        % Neighborhood visualization matrix
        gridImg = zeros(9, 9, 3);
        
        % Highlight N4 (Green), ND (Blue), N8 (Cyan overlay)
        N4_coords = [px+1 py; px-1 py; px py+1; px py-1];
        ND_coords = [px+1 py+1; px+1 py-1; px-1 py+1; px-1 py-1];

        for k = 1:size(N4_coords, 1)
            r = N4_coords(k, 1); c = N4_coords(k, 2);
            if r>=1 && r<=9 && c>=1 && c<=9, gridImg(r, c, 2) = 0.8; end
        end
        for k = 1:size(ND_coords, 1)
            r = ND_coords(k, 1); c = ND_coords(k, 2);
            if r>=1 && r<=9 && c>=1 && c<=9, gridImg(r, c, 3) = 0.8; end
        end

        % Highlight Center p (Red) and Target q (Yellow)
        gridImg(px, py, :) = [1 0 0];
        gridImg(qx, qy, :) = [1 1 0];

        imagesc(axGrid, gridImg);
        grid(axGrid, 'on'); axGrid.XTick = 1:9; axGrid.YTick = 1:9;
        title(axGrid, 'Pixel Grid (p: Red, q: Yellow, N_4: Green, N_D: Blue)');

        % Distance calculations
        De = sqrt((px - qx)^2 + (py - qy)^2);
        D4 = abs(px - qx) + abs(py - qy);
        D8 = max(abs(px - qx), abs(py - qy));

        % Plot Distance Circle on axDist
        [X, Y] = meshgrid(1:9, 1:9);
        DistMap = sqrt((X - px).^2 + (Y - py).^2);
        imagesc(axDist, DistMap); colorbar(axDist); hold(axDist, 'on');
        plot(axDist, qy, qx, 'r*', 'MarkerSize', 12, 'LineWidth', 2);
        th = linspace(0, 2*pi, 100);
        plot(axDist, py + De*cos(th), px + De*sin(th), 'r--', 'LineWidth', 1.5);
        hold(axDist, 'off');
        title(axDist, 'Euclidean Distance Map D_e(p,q)');

        lblMetrics.Text = sprintf(['Metric Calculations:\n' ...
                                   '• Euclidean Distance D_e(p,q) = sqrt((x-s)^2 + (y-t)^2) = %.2f\n' ...
                                   '• City-Block Distance D_4(p,q) = |x-s| + |y-t| = %d\n' ...
                                   '• Chessboard Distance D_8(p,q) = max(|x-s|, |y-t|) = %d'], ...
                                  De, D4, D8);
    end
end

%% ==================== TAB 2: ARITHMETIC & LOGIC ====================
function setupTab2_ArithmeticAndLogic(tab)
    ax1 = uiaxes(tab, 'Position', [30 350 250 250]);
    ax2 = uiaxes(tab, 'Position', [310 350 250 250]);
    axOut = uiaxes(tab, 'Position', [610 200 400 400]);

    % Image Generation (Synthetic Shapes)
    [X, Y] = meshgrid(linspace(-1, 1, 256));
    ImgA = double((X.^2 + Y.^2) < 0.5); % Circle
    ImgB = double(X > 0 & Y > 0);        % Quadrant

    imshow(ImgA, [], 'Parent', ax1); title(ax1, 'Image A (Circle)');
    imshow(ImgB, [], 'Parent', ax2); title(ax2, 'Image B (Square)');

    uilabel(tab, 'Position', [30 250 120 22], 'Text', 'Select Operation:');
    opSelect = uidropdown(tab, 'Position', [150 250 180 22], ...
        'Items', {'Addition (Average/Noise)', 'Subtraction (Difference)', ...
                  'Multiplication (Shading/Mask)', 'Division', ...
                  'Logic AND', 'Logic OR', 'Logic COMPLEMENT (NOT A)'}, ...
        'ValueChangedFcn', @(~,~) processOp());

    uilabel(tab, 'Position', [30 200 120 22], 'Text', 'Add Noise to Img A:');
    noiseSlider = uislider(tab, 'Position', [150 210 180 3], 'Limits', [0 0.5], ...
                           'ValueChangedFcn', @(~,~) processOp());

    processOp();

    function processOp()
        noiseLevel = noiseSlider.Value;
        A = ImgA + noiseLevel * randn(size(ImgA));
        B = ImgB;

        op = opSelect.Value;
        switch op
            case 'Addition (Average/Noise)'
                Res = (A + B) / 2;
            case 'Subtraction (Difference)'
                Res = A - B;
            case 'Multiplication (Shading/Mask)'
                Res = A .* B;
            case 'Division'
                Res = A ./ (B + 0.1);
            case 'Logic AND'
                Res = binaryAnd(ImgA, ImgB);
            case 'Logic OR'
                Res = binaryOr(ImgA, ImgB);
            case 'Logic COMPLEMENT (NOT A)'
                Res = ~ImgA;
        end
        imshow(Res, [], 'Parent', axOut);
        title(axOut, ['Result of ' op]);
    end

    function r = binaryAnd(a,b), r = (a > 0.5) & (b > 0.5); end
    function r = binaryOr(a,b), r = (a > 0.5) | (b > 0.5); end
end

%% ==================== TAB 3: SPATIAL FILTERING ====================
function setupTab3_LinearFiltering(tab)
    axOrig = uiaxes(tab, 'Position', [30 200 350 350]);
    axFilt = uiaxes(tab, 'Position', [420 200 350 350]);
    
    % Kernel Matrix Display Table
    uitable(tab, 'Position', [800 250 350 180], 'Tag', 'KernelTable');

    % Load Test Image (builtin cameraman)
    img = double(imread('cameraman.tif')) / 255;
    imshow(img, 'Parent', axOrig); title(axOrig, 'Original Image');

    uilabel(tab, 'Position', [30 100 100 22], 'Text', 'Preset Filters:');
    ddFilter = uidropdown(tab, 'Position', [130 100 200 22], ...
        'Items', {'Identity', 'Shift Left (1 px)', 'Shift right (1 px)', 'Shift top (1 px)', 'Shift bottom (1 px)', 'Mean (3x3 Blur)', ...
                  'Sharpening', 'Laplacian', 'Sobel X (Horizontal)', 'Sobel Y (Vertical)'}, ...
        'ValueChangedFcn', @(~,~) applyFilter());

    applyFilter();

    function applyFilter()
        switch ddFilter.Value
            case 'Identity'
                H = [0 0 0; 0 1 0; 0 0 0];
            case 'Shift Left (1 px)'
                H = [0 0 0; 0 0 1; 0 0 0];
            case 'Shift right (1 px)'
                H  = [0 0 0; 1 0 0; 0 0 0];
            case 'Shift top (1 px)'
                H   = [0 0 0; 0 0 0; 0 1 0];
            case 'Shift bottom (1 px)'
                H = [0 1 0; 0 0 0; 0 0 0];
            case 'Mean (3x3 Blur)'
                H = ones(3,3)/9;
            case 'Sharpening'
                H = [-1/9 -1/9 -1/9; -1/9 17/9 -1/9; -1/9 -1/9 -1/9];
            case 'Laplacian'
                H = [0 1 0; 1 -4 1; 0 1 0];
            case 'Sobel X (Horizontal)'
                H = (1/8) * [-1 0 1; -2 0 2; -1 0 1];
            case 'Sobel Y (Vertical)'
                H = (1/8) * [1 2 1; 0 0 0; -1 -2 -1];
        end

        % Display Matrix in Table
        tbl = findobj(tab, 'Tag', 'KernelTable');
        tbl.Data = H;

        % Perform Spatial Convolution G = H * F
        outImg = imfilter(img, H, 'replicate', 'corr');
        imshow(outImg, [], 'Parent', axFilt);
        title(axFilt, ['Filtered Image: ' ddFilter.Value]);
    end
end

%% ==================== TAB 4: CANNY & SCALE SPACE ====================
function setupTab4_CannyAndScaleSpace(tab)
    ax1 = uiaxes(tab, 'Position', [30 200 350 350]);
    ax2 = uiaxes(tab, 'Position', [410 200 350 350]);
    ax3 = uiaxes(tab, 'Position', [790 200 350 350]);

    img = imread('coins.png');
    imshow(img, 'Parent', ax1); title(ax1, 'Original Image');

    % Controls
    uilabel(tab, 'Position', [30 100 120 22], 'Text', 'Gaussian Scale (\sigma):');
    spSigma = uispinner(tab, 'Position', [160 100 80 22], 'Limits', [0.5 10], ...
                        'Value', 1.0, 'Step', 0.5, 'ValueChangedFcn', @(~,~) runCanny());

    uilabel(tab, 'Position', [260 100 120 22], 'Text', 'Low Threshold:');
    spLow = uispinner(tab, 'Position', [380 100 80 22], 'Limits', [0 0.9], ...
                      'Value', 0.1, 'Step', 0.05, 'ValueChangedFcn', @(~,~) runCanny());

    uilabel(tab, 'Position', [480 100 120 22], 'Text', 'High Threshold:');
    spHigh = uispinner(tab, 'Position', [600 100 80 22], 'Limits', [0.1 1.0], ...
                       'Value', 0.3, 'Step', 0.05, 'ValueChangedFcn', @(~,~) runCanny());

    runCanny();

    function runCanny()
        sig = spSigma.Value;
        thLow = spLow.Value;
        thHigh = spHigh.Value;

        % 1. Gaussian Smooth (Scale Space step)
        smoothImg = imgaussfilt(img, sig);
        imshow(smoothImg, 'Parent', ax2); 
        title(ax2, sprintf('Gaussian Smoothed (\\sigma = %.1f)', sig));

        % 2. Canny Edge Detection with Hysteresis
        edges = edge(img, 'Canny', [thLow thHigh], sig);
        imshow(edges, 'Parent', ax3);
        title(ax3, sprintf('Canny Edges (T_{low}=%.2f, T_{high}=%.2f)', thLow, thHigh));
    end
end