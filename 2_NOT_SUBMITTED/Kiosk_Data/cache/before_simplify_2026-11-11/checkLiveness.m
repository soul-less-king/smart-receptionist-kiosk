% checkLiveness.m - Part 4 of the kiosk: is this a live person? Two checks must pass: skin texture and an eye blink. CMAI 480 Computer Vision, Fall 2026. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

function histogram = lbpHistogram(faces)  % Local Binary Patterns: each pixel gets an 8-bit code by comparing it with its 8 neighbors (N8, Chapter 3)
    center = faces(2:end-1, 2:end-1, :);
    code = zeros(size(center));
    neighbors = [-1 -1; -1 0; -1 1; 0 1; 1 1; 1 0; 1 -1; 0 -1];       % row and column steps to the 8 neighbors
    for bit = 1:8
        neighbor = circshift(faces, [-neighbors(bit, :) 0]);
        code = code + (neighbor(2:end-1, 2:end-1, :) >= center) * 2 ^ (bit - 1);   % this bit is 1 when the neighbor is not darker
    end
    histogram = histc(code(:), 0:255)' / numel(code);                  % share of pixels with each of the 256 codes, over all frames
end

function isReal = looksReal(histograms, lbpReal, lbpFake)  % for each texture histogram (one per row): is it closer to real skin than to paper or screens? (SSD, Feature Extraction Part 3)
    isReal = sum((histograms - lbpReal) .^ 2, 2) < sum((histograms - lbpFake) .^ 2, 2);
end

function seen = blinkSeen(faces)  % a blink changes the eyes while the lower face stays the same; similarity is NCC with each band's usual (median) look (Feature Extraction Part 3)
    eyes = reshape(faces(round(0.26 * rows(faces)):round(0.56 * rows(faces)), :, :), [], size(faces, 3));          % rows from 26% to 56% of the face, one column per frame
    lowerFace = reshape(faces(round(0.62 * rows(faces)):round(0.95 * rows(faces)), :, :), [], size(faces, 3));     % rows from 62% to 95% of the face
    seen = max(corr(lowerFace, median(lowerFace, 2)) - corr(eyes, median(eyes, 2))) > 0.06;
end
