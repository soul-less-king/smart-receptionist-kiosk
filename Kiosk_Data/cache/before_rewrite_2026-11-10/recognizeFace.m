% recognizeFace.m - Part 3: light correction and our own Eigenfaces. CMAI 480 Kiosk. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

function v = homomorphicFilter(rgbFace)  % corrects the light of a face picture and returns it as one normalized column
    face = imresize(im2double(rgb2gray(rgbFace)), [80 60]);  % every face becomes 80 rows by 60 columns
    logFace = log(max(face, 0) + 0.01);
    light = imgaussfilt(logFace, 8);                         % slow light changes: Gaussian of width 8
    out = 0.7 * light + 1.4 * (logFace - light);             % shrink the light, boost the face detail
    v = zscore(out(:));
end

function [model, weights] = trainEigenfaces(faces)  % Eigenfaces from the equations: eigenvectors of A'A (Assignment 1); also returns the weights of these faces
    model.mean = mean(faces, 2);
    A = faces - model.mean;
    [V, D] = eig(A' * A);
    [~, order] = sort(diag(D), 'descend');
    U = A * V(:, order(1:min(100, columns(A) - 1)));         % keep at most 100 eigenfaces
    model.U = U ./ sqrt(sum(U .^ 2));
    weights = model.U' * A;
end

function weights = projectFaces(faces, model)  % turns faces into their eigenface weights
    weights = model.U' * (faces - model.mean);
end

function [index, accepted] = matchFace(weights, gallery, labels)  % nearest face; accepted only if clearly nearer than the next person (Assignment 3)
    distances = sqrt(sum((gallery - weights) .^ 2));
    [nearest, index] = min(distances);
    accepted = nearest / min(distances(labels ~= labels(index))) <= 0.85;
end

function today = loadTodaysList(M)  % reads the photos in today/Name_Code/*.jpg, finds each face and trains Eigenfaces on them
    folders = dir('today/*_*');
    today = struct('names', {{}}, 'codes', {{}}, 'state', {{}}, 'labels', []);
    faces = [];
    for i = 1:numel(folders)
        parts = strsplit(folders(i).name, '_');
        [today.names{i}, today.codes{i}, today.state{i}] = deal(parts{1}, parts{2}, 'Expected');
        for photo = glob(['today/' folders(i).name '/*.jpg'])'
            try                                                  % a photo with no usable face is simply skipped
                rgb = imread(photo{1});
                rgb = imresize(rgb, 640 / columns(rgb));         % photos become the size of a camera frame
                faces(:, end + 1) = homomorphicFilter(cropFace(rgb, detectFace(rgb, M)));
                today.labels(end + 1) = i;
            end
        end
    end
    if numel(unique(today.labels)) > 1
        [today.model, today.gallery] = trainEigenfaces(faces);
    end
end
