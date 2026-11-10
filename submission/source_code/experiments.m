% experiments.m - Part 5 of the kiosk: runs every test in the report and prints each result (about 50 minutes); it also makes models.mat for the kiosk. The ready-made VGG-Face model runs only here, strictly as a competitor. CMAI 480 Computer Vision, Fall 2026. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
findFace;                                                             % load Part 2
recognizeFace;                                                        % load Part 3
checkLiveness;                                                        % load Part 4

function maps = convolution3x3(maps, layer)  % competitor only: every 3x3 filter of one layer slides over all input maps (Lecture 4)
    patches = im2col(padarray(maps, [1 1]), [3 3 size(maps, 3)], 'sliding');   % one column per pixel: its 3x3 neighborhood in every input map
    maps = reshape(patches' * reshape(layer.weights{1}, [], size(layer.weights{1}, 4)) + layer.weights{2}(:)', rows(maps), columns(maps), []);   % every filter times every patch, plus the bias
end

function embedding = vggFace(face, net)  % competitor only: the ready-made VGG-Face layers, then one average per feature map (Lectures 5, 6)
    maps = single(imresize(face, [224 224])) - net.avg;
    for layer = 1:31                                                  % VGG-16's 13 convolution layers, each followed by ReLU, and its 5 max pools
        if strcmp(net.layers{layer}.type, 'conv')
            maps = max(convolution3x3(maps, net.layers{layer}), 0);   % convolution, then ReLU
        elseif strcmp(net.layers{layer}.type, 'pool')
            maps = max(max(maps(1:2:end, 1:2:end, :), maps(2:2:end, 1:2:end, :)), max(maps(1:2:end, 2:2:end, :), maps(2:2:end, 2:2:end, :)));   % 2x2 max pooling: the largest of every 2x2 block
        end
    end
    embedding = double(squeeze(mean(mean(maps, 1), 2)));            % global average pooling: 512 numbers
    embedding = embedding / norm(embedding);
end

function described = describeImages(paths, net, faceTemplate, change)  % finds the face in each photo and describes it two ways: our Eigenfaces input and VGG-Face
    described.boxes = zeros(numel(paths), 4);
    for photo = 1:numel(paths)
        picture = change(imread(paths{photo}), photo);              % the change is nothing, a painted mask or strong backlight
        box = detectFace(picture, faceTemplate);
        if isempty(box)
            box = [1 1 columns(picture) rows(picture)];              % no face found: use the whole photo
        else
            described.boxes(photo, :) = box;
        end
        described.filtered(:, photo) = homomorphicFilter(cropFace(picture, box));
        described.vgg(:, photo) = vggFace(cropFace(picture, box), net);
    end
end

function enrolled = chooseGallery(people, perPerson)  % picks perPerson random photos of each person to enroll
    enrolled = false(size(people));
    for person = unique(people)
        photos = find(people == person);
        enrolled(photos(randperm(numel(photos), perPerson))) = true;
    end
end

function [predicted, accepted] = matchAll(features, people, enrolled, useEigenfaces)  % matches every photo that is not enrolled against the enrolled ones
    enrolledFeatures = features(:, enrolled);
    tests = features(:, ~enrolled);
    if useEigenfaces                                                  % our method trains Eigenfaces on the enrolled photos only
        [model, enrolledFeatures] = trainEigenfaces(enrolledFeatures);
        tests = projectFaces(tests, model);
    end
    enrolledPeople = people(enrolled);
    for photo = 1:columns(tests)
        [closest, accepted(photo)] = matchFace(tests(:, photo), enrolledFeatures, enrolledPeople);
        predicted(photo) = enrolledPeople(closest);
    end
end

function [accuracies, perPerson] = listCurve(features, people, useEigenfaces)  % accuracy as today's list grows from 5 to 50 people, over 20 random lists of each size
    rng(0);
    sizes = [5 10 20 30 40 50];
    perPerson = zeros(1, 50);
    for row = 1:6
        for repeat = 1:20
            onList = ismember(people, randperm(50, sizes(row)));
            listPeople = people(onList);
            enrolled = chooseGallery(listPeople, 5);
            predicted = matchAll(features(:, onList), listPeople, enrolled, useEigenfaces);
            truth = listPeople(~enrolled);
            accuracies(row, repeat) = mean(predicted == truth);
            if row == 6                                               % full lists: each person's accuracy, for the glasses test
                perPerson = perPerson + arrayfun(@(person) mean(predicted(truth == person) == person), 1:50) / 20;
            end
        end
    end
end

function result = strangerTest(features, people, useEigenfaces)  % 25 people on the list and 25 strangers: precision, recall, F1 and strangers accepted (Lecture 3)
    rng(0);
    onList = ismember(people, randperm(50, 25));
    enrolled = false(size(people));
    enrolled(onList) = chooseGallery(people(onList), 5);
    [predicted, accepted] = matchAll(features, people, enrolled, useEigenfaces);
    isVisitor = onList(~enrolled);
    correct = accepted & isVisitor & predicted == people(~enrolled);
    precision = sum(correct) / max(sum(accepted), 1);
    recall = sum(correct) / sum(isVisitor);
    result = [precision, recall, 2 * precision * recall / max(precision + recall, eps), mean(accepted(~isVisitor))];
end

function picture = paintMask(picture, box)  % covers the lower 45% of the face box with a plain light-gray mask
    picture(box(2) + round(0.55 * box(4)) - 1:box(2) + box(4) - 1, box(1):box(1) + box(3) - 1, :) = 205;
end

function frame = readFrame(path)  % reads one video frame as an 8-bit color picture; the very large phone frames are shrunk to a third
    frame = im2uint8(imread(path)) .* ones(1, 1, 3, 'uint8');      % three color channels, also for the two all-black frames that Octave reads as black-and-white
    if rows(frame) > 640
        frame = imresize(frame, 1 / 3);
    end
end

if ~exist('vgg_conv.mat', 'file') || ~exist('../Kiosk_Data', 'dir')
    disp('This test script needs vgg_conv.mat and the public datasets of the report in ../Kiosk_Data. The kiosk itself needs neither.');
    return;
end
net = load('vgg_conv.mat');                                           % the VGG-Face convolution layers, for the competitor only
dataFolder = '../Kiosk_Data/';

%% Finding the face: Georgia Tech, 50 people with 15 photos each and a labelled face box; 150 photos teach the face template
people = kron(1:50, ones(1, 15));
shots = repmat(1:15, 1, 50);
paths = glob([dataFolder 'gt/images/gt_db/s*/*.jpg']);
corners = cell2mat(cellfun(@dlmread, glob([dataFolder 'gt/labels/labels/lab*']), 'UniformOutput', false));   % left, top, right, bottom of each labelled face
trueBoxes = [corners(:, 1:2) + 1, corners(:, 3:4) - corners(:, 1:2)];   % as [left top width height]
heldOut = ~ismember(shots, [2 7 12]);
models.faceTemplate = zeros(12, 8, 8);
for photo = find(~heldOut)                                            % the template: the average gradient histograms of these faces and their mirror images
    face = imresize(im2double(rgb2gray(cropFace(imread(paths{photo}), trueBoxes(photo, :)))), [96 64]);
    models.faceTemplate = models.faceTemplate + (gradientHistograms(face) + gradientHistograms(fliplr(face))) / (2 * nnz(~heldOut));
end
models.faceTemplate = models.faceTemplate - mean(mean(models.faceTemplate, 1), 2);   % each direction bin made zero-mean
gt = describeImages(paths, net, models.faceTemplate, @(picture, photo) picture);
overlap = diag(rectint(gt.boxes, trueBoxes));
iou = overlap ./ (prod(gt.boxes(:, 3:4), 2) + prod(trueBoxes(:, 3:4), 2) - overlap);   % intersection over union (Lecture 8)
detection = [mean(iou(heldOut) >= 0.5), mean(iou(heldOut))]       % share of faces found, average overlap

%% Accuracy as today's list grows from 5 to 50 people, and people who wear glasses
[eigenCurve, eigenPerPerson] = listCurve(gt.filtered, people, true);
[vggCurve, vggPerPerson] = listCurve(gt.vgg, people, false);
listAccuracy = [mean(eigenCurve, 2), mean(vggCurve, 2)]           % rows: 5, 10, 20, 30, 40, 50 people; columns: Eigenfaces, VGG-Face
listSpread = [std(eigenCurve, 0, 2), std(vggCurve, 0, 2)]
wearers = ismember(1:50, [3 6 8 12 19 21 28 36 39 42 47 48 49]);     % people who wear glasses in some photos
glasses = [mean(eigenPerPerson(wearers)), mean(eigenPerPerson(~wearers)), mean(vggPerPerson(wearers)), mean(vggPerPerson(~wearers))]

%% Visitors versus strangers
strangersEigenfaces = strangerTest(gt.filtered, people, true)
strangersVgg = strangerTest(gt.vgg, people, false)

%% Changing light: Yale faces enrolled under near-frontal light, without and with the homomorphic filter
yaleFiles = glob([dataFolder 'yale/images/p*/*A[+-]*E[+-]*.png']);
for photo = 1:numel(yaleFiles)
    numbers = str2double(regexp(yaleFiles{photo}, 'images/p(\d+)/.*A([+-]\d+)E([+-]\d+)', 'tokens', 'once'));   % folder number, light angle across, light angle up
    yalePeople(photo) = numbers(1) + 1;
    harshness(photo) = sum(max(abs(numbers(2:3))) > [20 50]);       % 0 is near-frontal light, 1 moderate, 2 harsh
    picture = imread(yaleFiles{photo});
    yaleFeatures(:, photo, 1:2) = [zscore(reshape(imresize(im2double(picture), [80 60]), [], 1)), homomorphicFilter(repmat(picture, [1 1 3]))];   % without, then with the filter
end
unseen = yalePeople > 19;                                            % people 1 to 19 were used to choose the filter values
tested = harshness(unseen & harshness > 0);
for version = 1:2
    correct = matchAll(yaleFeatures(:, unseen, version), yalePeople(unseen), harshness(unseen) == 0, true) == yalePeople(unseen & harshness > 0);
    lighting(version, :) = [mean(correct(tested == 1)), mean(correct(tested == 2))];
end
lighting                                                             % rows: without, with the filter; columns: moderate, harsh light

%% Head turn: FEI faces, enrolled with frontal photos and tested at each turn
feiPeople = kron(1:50, ones(1, 12));
feiShots = repmat([11 12 5 6 4 7 3 8 2 9 1 10], 1, 50);             % FEI photo numbers, from frontal to full profile
turn = repmat([0 0 1 1 2 2 3 3 4 4 5 5], 1, 50);                     % 0 is frontal, 5 is full profile
fei = describeImages(arrayfun(@(photo) sprintf('%sfei/images/%d-%02d.jpg', dataFolder, feiPeople(photo), feiShots(photo)), 1:600, 'UniformOutput', false), net, models.faceTemplate, @(picture, photo) picture);
for level = 1:5
    keep = turn == 0 | turn == level;
    headTurn(1, level) = mean(matchAll(fei.filtered(:, keep), feiPeople(keep), turn(keep) == 0, true) == feiPeople(turn == level));
    headTurn(2, level) = mean(matchAll(fei.vgg(:, keep), feiPeople(keep), turn(keep) == 0, false) == feiPeople(turn == level));
end
headTurn                                                             % rows: Eigenfaces, VGG-Face; columns: turn levels 1 to 5

%% Mask and strong backlight, painted on 150 photos that are not enrolled
rng(0);
enrolledPhotos = chooseGallery(people, 5);
tests = find(~enrolledPhotos & mod(shots, 3) == 0, 150);
enrolledFirst = [true(1, nnz(enrolledPhotos)), false(1, 150)];       % the enrolled photos come first, then the 150 spoiled photos
spoilers = {@(picture, k) paintMask(picture, trueBoxes(tests(k), :)), @(picture, k) uint8(127.5 * (double(picture) / 255) .^ 2)};   % mask, strong backlight
for spoiler = 1:2
    spoiled = describeImages(paths(tests), net, models.faceTemplate, spoilers{spoiler});
    maskAndBacklight(1, spoiler) = mean(matchAll([gt.filtered(:, enrolledPhotos), spoiled.filtered], [people(enrolledPhotos), people(tests)], enrolledFirst, true) == people(tests));
    maskAndBacklight(2, spoiler) = mean(matchAll([gt.vgg(:, enrolledPhotos), spoiled.vgg], [people(enrolledPhotos), people(tests)], enrolledFirst, false) == people(tests));
end
maskAndBacklight                                                     % rows: Eigenfaces, VGG-Face; columns: mask, backlight

%% Liveness per attack: one row per 3-second window of every clip (kind, clip, blink seen, LBP histogram); a clip passes if any window passes
kinds = {'real', 'print', 'print_cut', 'monitor', 'phone'};
live = [];
for kind = 1:5
    for clip = 1:10
        folder = sprintf('%sliveness_frames/%s/%02d/', dataFolder, kinds{kind}, clip);
        files = dir([folder '*.jpg']);
        for first = 1:45:min(136, max(1, numel(files) - 44))          % up to four windows of 45 frames; a short clip is one window
            frames = arrayfun(@(file) readFrame([folder file.name]), files(first:min(first + 44, numel(files))), 'UniformOutput', false);
            box = detectFace(frames{round(numel(frames) / 2)}, models.faceTemplate);
            if ~isempty(box)                                          % no face in the middle frame: the window is skipped
                faces = cropAllFrames(frames, box);
                live(end + 1, :) = [kind, clip, blinkSeen(faces), lbpHistogram(faces)];
            end
        end
    end
end
for half = 0:1                                                       % the texture averages are learned on the other half of the clips
    learn = mod(live(:, 2), 2) == half;
    looks(~learn, 1) = looksReal(live(~learn, 4:end), mean(live(learn & live(:, 1) == 1, 4:end), 1), mean(live(learn & live(:, 1) > 1, 4:end), 1));
end
passed = [looks, live(:, 3), looks & live(:, 3)];
for check = 1:3                                                      % texture, blink, both
    liveness(:, check) = mean(accumarray(live(:, 1:2), passed(:, check), [5 10], @any), 2);   % share of the 10 clips of each kind in which any window passes
end
liveness                                                             % rows: real, print, cut print, monitor, phone; columns: texture, blink, both
models.lbpReal = mean(live(live(:, 1) == 1, 4:end), 1);
models.lbpFake = mean(live(live(:, 1) > 1, 4:end), 1);
save('models.mat', '-struct', 'models');

%% Speed of each step on one real 3-second clip, averaged over 5 runs; the clock is read after every step
files = dir([dataFolder 'liveness_frames/real/03/*.jpg']);
frames = arrayfun(@(file) readFrame([dataFolder 'liveness_frames/real/03/' file.name]), files(31:75), 'UniformOutput', false);
codes = arrayfun(@(code) sprintf('%04d', code), 1:50, 'UniformOutput', false);
for repeat = 1:5
    tic;
    box = detectFace(frames{23}, models.faceTemplate);
    readings(repeat, 1) = toc;
    faces = cropAllFrames(frames, box);
    readings(repeat, 2) = toc;
    looksReal(lbpHistogram(faces), models.lbpReal, models.lbpFake);
    readings(repeat, 3) = toc;
    blinkSeen(faces);
    readings(repeat, 4) = toc;
    face = homomorphicFilter(cropFace(frames{23}, box));
    readings(repeat, 5) = toc;
    [model, weights] = trainEigenfaces(gt.filtered(:, 1:250));
    readings(repeat, 6) = toc;
    matchFace(projectFaces(face, model), weights, people(1:250));
    readings(repeat, 7) = toc;
    find(strcmp(codes, '0042'));
    readings(repeat, 8) = toc;
end
stepSeconds = mean(diff([zeros(5, 1), readings], 1, 2))'           % each step's time is the gap between two clock readings: find face, crop frames, texture, blink, homomorphic, train, match, booking code
