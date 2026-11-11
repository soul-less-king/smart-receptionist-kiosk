% findFace.m - Part 2: finds the face and cuts it out. CMAI 480 Kiosk. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

function H = cellHistograms(gray)  % gradient orientation histogram of every 8x8 cell, 8 bins per cell (Assignment 2, Feature Extraction Part 2)
    [gx, gy] = gradient(gray);
    bin = min(floor(mod(atan2(gy, gx), 2 * pi) / (2 * pi) * 8) + 1, 8);
    [r, c] = ndgrid(1:rows(gray), 1:columns(gray));
    H = accumarray([ceil(r(:) / 8), ceil(c(:) / 8), bin(:)], hypot(gx, gy)(:), [ceil(size(gray) / 8), 8]);
    H = H ./ (sqrt(sum(H .^ 2, 3)) + 0.01);  % normalizing each cell makes the histograms robust to light
end

function box = detectFace(rgb, M)  % slides the face template over an image pyramid; the strongest match is the face (Lecture 8, Feature Extraction Parts 2, 3)
    [box, best] = deal([], 9);                         % a weaker match than 9 means nobody is there
    gray = im2double(rgb2gray(rgb));
    for scale = 1.15 .^ -(2:11)                        % face heights from 127 to 445 pixels
        H = cellHistograms(imresize(gray, scale));
        if rows(H) < 12 || columns(H) < 8, break; end  % the picture is now smaller than the template
        score = convn(H, M.faceTemplate(end:-1:1, end:-1:1, end:-1:1), 'valid');
        [strength, where] = max(score(:));
        if strength > best
            best = strength;
            [r, c] = ind2sub(size(score), where);
            box = round([c - 1, r - 1, 8, 12] * 8 / scale) + [1 1 0 0];  % from template cells back to picture pixels
        end
    end
end

function face = cropFace(picture, box)  % cuts the box out of a picture
    rows = max(box(2), 1):min(box(2) + box(4) - 1, size(picture, 1));
    cols = max(box(1), 1):min(box(1) + box(3) - 1, size(picture, 2));
    face = picture(rows, cols, :);
end

function faces = cropAllFrames(frames, box)  % same box in every frame: the visitor stands still for 3 seconds
    for t = 1:numel(frames)
        faces(:, :, t) = imresize(im2double(rgb2gray(cropFace(frames{t}, box))), [120 90]);
    end
end
