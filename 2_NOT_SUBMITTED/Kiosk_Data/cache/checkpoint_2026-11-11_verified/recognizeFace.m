% recognizeFace.m - Part 3 of the kiosk: corrects the light on a face and recognizes it with our own Eigenfaces.
% Programmers: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan. CMAI 480 Computer Vision, Fall 2026.
pkg load image;

function faceColumn = homomorphicFilter(face)  % picture = light x detail: take the log, shrink the slowly changing light and boost the detail (Chapter 3; doctor's comment)
    logFace = log(max(imresize(im2double(rgb2gray(face)), [80 60]), 0) + 0.01);   % gray, 80 rows by 60 columns; the log turns light x detail into light + detail
    light = imgaussfilt(logFace, 8);                                  % the light changes slowly: a Gaussian blur of width 8
    faceColumn = zscore(reshape(0.7 * light + 1.4 * (logFace - light), [], 1));   % shrink the light, boost the detail, then one column with average 0 and spread 1
end

function [model, weights] = trainEigenfaces(faces)  % Eigenfaces from the equations, using the small matrix A'A (Assignment 1; Linear Algebra slides)
    model.averageFace = mean(faces, 2);
    differences = faces - model.averageFace;                          % A: each face minus the average face
    [vectors, values] = eig(differences' * differences);              % eigenvectors v of A'A
    [~, largestFirst] = sort(diag(values), 'descend');
    eigenfaces = differences * vectors(:, largestFirst(1:min(100, columns(faces) - 1)));   % U = A v, keeping at most 100 eigenfaces
    model.eigenfaces = eigenfaces ./ sqrt(sum(eigenfaces .^ 2));      % each eigenface gets length 1
    weights = model.eigenfaces' * differences;                        % w = U'(face - average face) for the training faces
end

function weights = projectFaces(faces, model)  % the eigenface weights of any face: w = U'(face - average face)
    weights = model.eigenfaces' * (faces - model.averageFace);
end

function [closest, accepted] = matchFace(weights, photoWeights, photoOwners)  % the nearest enrolled photo, accepted only if clearly nearer than the nearest other person (ratio test, Assignment 3)
    distances = sqrt(sum((photoWeights - weights) .^ 2));             % Euclidean distance to every enrolled photo
    [nearest, closest] = min(distances);
    accepted = nearest / min(distances(photoOwners ~= photoOwners(closest))) <= 0.85;
end

function today = loadTodaysList(faceTemplate)  % reads the photos in today/Name_Code/*.jpg, finds each face and trains Eigenfaces on today's visitors only
    folders = dir('today/*_*');
    today.names = regexprep({folders.name}, '_[^_]*$', '');           % the folder name before the last underscore
    today.codes = regexprep({folders.name}, '.*_', '');               % the folder name after the last underscore
    today.status = repmat({'Expected'}, size(today.names));
    today.photoOwners = [];
    faces = [];
    for person = 1:numel(folders)
        for photo = glob(['today/' folders(person).name '/*.jpg'])'
            try                                                       % a photo without a usable face is skipped
                picture = imresize(imread(photo{1}), [NaN 640]);      % every photo gets the width of a camera frame
                faces(:, end + 1) = homomorphicFilter(cropFace(picture, detectFace(picture, faceTemplate)));
                today.photoOwners(end + 1) = person;
            end
        end
    end
    if numel(unique(today.photoOwners)) > 1                          % Eigenfaces need at least two people
        [today.model, today.photoWeights] = trainEigenfaces(faces);
    end
end
