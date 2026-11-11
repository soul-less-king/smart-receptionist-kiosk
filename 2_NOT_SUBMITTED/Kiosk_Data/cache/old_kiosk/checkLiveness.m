% checkLiveness.m - Part 4: is this a live person? Texture check plus blink check.
% Consent-Based Smart Receptionist Kiosk, CMAI 480, Qatar University.
% Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

% Local Binary Pattern: compare each pixel with its 8 neighbors (Chapter 3).
function h = lbpHistogram(gray)
    center = gray(2:end-1, 2:end-1);
    code = zeros(size(center));
    neighbors = [-1 -1; -1 0; -1 1; 0 1; 1 1; 1 0; 1 -1; 0 -1];
    for k = 1:8
        shifted = circshift(gray, -neighbors(k, :));
        code = code + (shifted(2:end-1, 2:end-1) >= center) * 2 ^ (k - 1);
    end
    h = histc(code(:), 0:255);
    h = h(:)' / sum(h);
end

% Average LBP histogram over all frames of the locked face.
function h = averageTexture(faces)
    h = zeros(1, 256);
    for t = 1:size(faces, 3)
        h = h + lbpHistogram(faces(:, :, t));
    end
    h = h / size(faces, 3);
end

% Positive when the texture is closer to real skin than to paper or screens.
function score = textureScore(faces, M)
    h = averageTexture(faces);
    score = norm(h - M.lbpFake) - norm(h - M.lbpReal);
end

% How similar one face band is to its usual look in each frame (NCC).
function s = bandSimilarity(faces, band)
    rows = round(band * size(faces, 1));
    patches = reshape(faces(rows(1):rows(2), :, :), [], size(faces, 3));
    usual = median(patches, 2);
    s = zeros(size(faces, 3), 1);
    for t = 1:size(faces, 3)
        c = corrcoef(patches(:, t), usual);
        s(t) = c(1, 2);
    end
end

% A blink changes the eyes while the lower face stays the same.
function score = blinkScore(faces, S)
    score = max(bandSimilarity(faces, S.restBand) - bandSimilarity(faces, S.eyeBand));
end
