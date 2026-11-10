% checkLiveness.m - Part 4: is this a live person? Texture plus blink. CMAI 480 Kiosk. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

function h = lbpHistogram(faces)  % Local Binary Pattern over all frames: compare each pixel with its 8 neighbors (Chapter 3)
    center = faces(2:end-1, 2:end-1, :);
    code = zeros(size(center));
    neighbors = [-1 -1; -1 0; -1 1; 0 1; 1 1; 1 0; 1 -1; 0 -1];
    for k = 1:8
        shifted = circshift(faces, [-neighbors(k, :) 0]);
        code += (shifted(2:end-1, 2:end-1, :) >= center) * 2 ^ (k - 1);
    end
    h = histc(code(:), 0:255)' / numel(code);
end

function isReal = looksReal(h, lbpReal, lbpFake)  % true when the texture is closer to real skin than to paper or screens
    isReal = norm(h - lbpReal) < norm(h - lbpFake);
end

function s = bandSimilarity(faces, band)  % how similar one face band is to its usual look in each frame (NCC)
    rows = round(band * size(faces, 1));
    patches = reshape(faces(rows(1):rows(2), :, :), [], size(faces, 3));
    s = corr(patches, median(patches, 2));
end

function seen = blinkSeen(faces)  % a blink changes the eyes while the lower face stays the same
    seen = max(bandSimilarity(faces, [0.62 0.95]) - bandSimilarity(faces, [0.26 0.56])) > 0.06;  % lower-face rows, eye rows, limit
end
