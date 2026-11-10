% recognizeFace.m - Part 3: light correction and our own Eigenfaces recognizer.
% Consent-Based Smart Receptionist Kiosk, CMAI 480, Qatar University.
% Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
pkg load image;

% Homomorphic filter: in the log image, shrink slow light and boost face detail.
function out = homomorphicFilter(face, S)
    logFace = log(max(face, 0) + 0.01);
    light = imgaussfilt(logFace, S.sigma);
    out = S.gammaLow * light + S.gammaHigh * (logFace - light);
end

% Turns a face into one normalized column of numbers.
function v = faceVector(face, S)
    out = homomorphicFilter(face, S);
    v = (out(:) - mean(out(:))) / std(out(:));
end

% Eigenfaces from the equations: eigenvectors of A'A, as in Assignment 1.
function model = trainEigenfaces(faces, count)
    model.mean = mean(faces, 2);
    A = faces - model.mean;
    [V, D] = eig(A' * A);
    [~, order] = sort(diag(D), 'descend');
    U = A * V(:, order(1:min(count, size(A, 2) - 1)));
    model.U = U ./ sqrt(sum(U .^ 2));
end

% Turns faces into their eigenface weights.
function weights = projectFaces(faces, model)
    weights = model.U' * (faces - model.mean);
end

% Finds the nearest enrolled face; ratio compares it with the next person.
function [index, ratio] = matchFace(weights, gallery, labels)
    distances = sqrt(sum((gallery - weights) .^ 2));
    [nearest, index] = min(distances);
    ratio = nearest / min(distances(labels ~= labels(index)));
end

% Reads today's visitors from the today folder and trains Eigenfaces on them.
function today = loadTodaysList(S)
    folders = dir('today/*_*');
    today.names = {};
    today.codes = {};
    today.state = {};
    today.labels = [];
    faces = [];
    for i = 1:numel(folders)
        parts = strsplit(folders(i).name, '_');
        today.names{i} = parts{1};
        today.codes{i} = parts{2};
        today.state{i} = 'Expected';
        files = dir(['today/' folders(i).name '/*.png']);
        for j = 1:numel(files)
            faces(:, end + 1) = faceVector(im2double(imread(['today/' folders(i).name '/' files(j).name])), S);
            today.labels(end + 1) = i;
        end
    end
    if numel(folders) > 1
        today.model = trainEigenfaces(faces, S.eigenfaces);
        today.gallery = projectFaces(faces, today.model);
    end
end
