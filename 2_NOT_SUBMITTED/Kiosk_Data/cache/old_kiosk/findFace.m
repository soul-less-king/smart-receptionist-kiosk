% findFace.m - Part 2: finds the face in a frame and cuts it out.
% Consent-Based Smart Receptionist Kiosk, CMAI 480, Qatar University.
% Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

% One convolution layer: slide the kernels over the feature maps (Lecture 4).
function y = applyConv(x, layer)
    W = layer.weights{1};
    x = padarray(x, [1 1], 0);
    [h, w, c, count] = size(W);
    rows = size(x, 1) - h + 1;
    cols = size(x, 2) - w + 1;
    P = zeros(rows, cols, h * w, c, 'single');
    for i = 1:h * w
        [dr, dc] = ind2sub([h w], i);
        P(:, :, i, :) = x(dr:rows+dr-1, dc:cols+dc-1, :);
    end
    y = reshape(reshape(P, rows * cols, []) * reshape(W, [], count) + layer.weights{2}(:)', rows, cols, count);
end

% 2x2 max pooling halves the height and width (Lecture 4).
function y = maxPool(x)
    a = max(x(1:2:end-1, :, :), x(2:2:end, :, :));
    y = max(a(:, 1:2:end-1, :), a(:, 2:2:end, :));
end

% Runs the pretrained VGG-Face layers on an image (Lectures 5 and 6).
function x = runVgg(rgb, net, lastLayer)
    x = single(rgb) - net.avg;
    for k = 1:lastLayer
        L = net.layers{k};
        if strcmp(L.type, 'conv')
            x = applyConv(x, L);
        elseif strcmp(L.type, 'relu')
            x = max(x, 0);
        else
            x = maxPool(x);
        end
    end
end

% Finds the face in one pass: the strongest blob of the feature map (Lectures 7, 9).
function box = detectFace(rgb, net, S)
    map = sum(runVgg(imresize(rgb, 0.5), net, 30), 3);
    [strength, peak] = max(map(:));
    if strength < S.minFaceResponse
        box = [];
        return;
    end
    blobs = bwlabel(map > S.faceLevel * strength);
    [r, c] = find(blobs == blobs(peak));
    h = 1.2 * (max(r) - min(r) + 1);
    box = round(32 * [mean(c) - 0.36 * h - 0.5, mean(r) - 0.5 * h - 0.5, 0.72 * h, h]) + [1 1 0 0];
end

% Cuts the box out of a picture and resizes it.
function face = cropFace(picture, box, outputSize)
    [rows, cols, ~] = size(picture);
    top = max(box(2), 1);
    left = max(box(1), 1);
    bottom = min(box(2) + box(4) - 1, rows);
    right = min(box(1) + box(3) - 1, cols);
    face = imresize(picture(top:bottom, left:right, :), outputSize);
end

% Cuts the same box out of every frame: the visitor stands still for 3 seconds.
function faces = cropAllFrames(gray, box, S)
    faces = zeros([S.textureSize numel(gray)]);
    for t = 1:numel(gray)
        faces(:, :, t) = cropFace(gray{t}, box, S.textureSize);
    end
end
