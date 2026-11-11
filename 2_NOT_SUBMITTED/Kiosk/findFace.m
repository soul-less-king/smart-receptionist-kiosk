% findFace.m - Part 2 of the kiosk: finds the face in a picture and cuts it out.
% Programmers: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan. CMAI 480 Computer Vision, Fall 2026.
pkg load image;

function histograms = gradientHistograms(gray)  % for every 8x8 cell of pixels, a histogram of edge directions in 8 bins (Assignment 2; SIFT, Feature Extraction Part 2)
    [horizontalChange, verticalChange] = gradient(gray);
    direction = min(floor(mod(atan2(verticalChange, horizontalChange), 2 * pi) / (2 * pi) * 8) + 1, 8);   % bins of 45 degrees, numbered 1 to 8
    [row, column] = ndgrid(1:rows(gray), 1:columns(gray));
    histograms = accumarray([ceil(row(:) / 8), ceil(column(:) / 8), direction(:)], hypot(horizontalChange(:), verticalChange(:)), [ceil(size(gray) / 8), 8]);   % each pixel adds its edge strength to its cell and direction
    histograms = histograms ./ (sqrt(sum(histograms .^ 2, 3)) + 0.01);   % every cell gets length 1, so the light has little effect
end

function box = detectFace(picture, faceTemplate)  % slides the face template over smaller and smaller copies of the picture; the strongest match is the face (Lecture 8)
    box = [];
    bestScore = 9;                                                     % a match weaker than 9 means nobody is there
    gray = im2double(rgb2gray(picture));
    for scale = 1.15 .^ -(2:11)                                        % face heights from 127 to 445 pixels
        scores = convn(gradientHistograms(imresize(gray, scale)), faceTemplate(end:-1:1, end:-1:1, end:-1:1), 'valid');   % the flipped template turns convolution into correlation (Chapter 3)
        [score, where] = max(scores(:));
        if score > bestScore
            bestScore = score;
            [cellRow, cellColumn] = ind2sub(size(scores), where);
            box = round([cellColumn - 1, cellRow - 1, 8, 12] * 8 / scale) + [1 1 0 0];   % [left top width height] in pixels of the picture
        end
    end
end

function face = cropFace(picture, box)  % cuts the box [left top width height] out of the picture, staying inside the picture
    face = picture(max(box(2), 1):min(box(2) + box(4) - 1, rows(picture)), max(box(1), 1):min(box(1) + box(3) - 1, columns(picture)), :);
end

function faces = cropAllFrames(frames, box)  % the same box in every frame, because the visitor stands still; each face becomes gray and 120x90
    for frame = 1:numel(frames)
        faces(:, :, frame) = imresize(im2double(rgb2gray(cropFace(frames{frame}, box))), [120 90]);
    end
end
