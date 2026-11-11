% experiments.m - Part 5: runs every test in the report (about 25 minutes) and prints each result. CMAI 480 Kiosk. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
findFace; recognizeFace; checkLiveness;

function y = applyConv(x, layer)  % competitor only: one convolution layer, 3x3 kernels slide over the feature maps (Lecture 4)
    [rows, cols, channels] = size(x);
    x = padarray(x, [1 1], 0);
    P = zeros(rows, cols, 9, channels, 'single');
    for i = 1:9
        [dr, dc] = ind2sub([3 3], i);
        P(:, :, i, :) = x(dr:rows+dr-1, dc:cols+dc-1, :);
    end
    count = size(layer.weights{1}, 4);
    y = reshape(reshape(P, rows * cols, []) * reshape(layer.weights{1}, [], count) + layer.weights{2}(:)', rows, cols, count);
end

function y = maxPool(x)  % competitor only: 2x2 max pooling halves the height and width (Lecture 4)
    a = max(x(1:2:end-1, :, :), x(2:2:end, :, :));
    y = max(a(:, 1:2:end-1, :), a(:, 2:2:end, :));
end

function x = runVgg(rgb, net)  % competitor only: runs the ready-made VGG-Face layers one by one (Lectures 5, 6)
    x = single(rgb) - net.avg;
    for k = 1:31
        switch net.layers{k}.type
            case 'conv', x = applyConv(x, net.layers{k});
            case 'relu', x = max(x, 0);
            case 'pool', x = maxPool(x);
        end
    end
end

function T = learnFaceTemplate(paths, boxes)  % the average cell histograms of labelled faces and their mirror images, made zero-mean
    T = zeros(12, 8, 8);
    for i = 1:numel(paths)
        face = imresize(im2double(rgb2gray(cropFace(imread(paths{i}), boxes(i, :)))), [96 64]);
        T += (cellHistograms(face) + cellHistograms(fliplr(face))) / (2 * numel(paths));
    end
    T -= mean(mean(T, 1), 2);
end

function D = describeImages(paths, net, M, change)  % finds each face and describes it two ways: our Eigenfaces input and VGG-Face
    D.boxes = zeros(numel(paths), 4);
    for i = 1:numel(paths)
        rgb = change(imread(paths{i}), i);
        box = detectFace(rgb, M);
        if isempty(box), box = [1 1 columns(rgb) rows(rgb)]; else, D.boxes(i, :) = box; end
        D.filtered(:, i) = homomorphicFilter(cropFace(rgb, box));
        x = double(squeeze(mean(mean(runVgg(imresize(cropFace(rgb, box), [224 224]), net), 1), 2)));
        D.vgg(:, i) = x / norm(x);
    end
end

function isGallery = chooseGallery(labels, perPerson)  % picks perPerson random enrollment images for each person
    isGallery = false(size(labels));
    for person = unique(labels)
        where = find(labels == person);
        isGallery(where(randperm(numel(where), perPerson))) = true;
    end
end

function [predicted, accepted] = matchAll(features, labels, isGallery, useEigenfaces)  % matches every face outside the gallery against the gallery
    gallery = features(:, isGallery);
    tests = features(:, ~isGallery);
    if useEigenfaces
        [model, gallery] = trainEigenfaces(gallery);
        tests = projectFaces(tests, model);
    end
    known = labels(isGallery);
    for i = 1:columns(tests)
        [nearest, accepted(i)] = matchFace(tests(:, i), gallery, known);
        predicted(i) = known(nearest);
    end
end

function [accuracy, perPerson] = listCurve(features, labels, useEigenfaces)  % accuracy as the list grows from 5 to 50 people, over 20 random lists
    rng(0);
    sizes = [5 10 20 30 40 50];
    perPerson = zeros(1, 50);
    for s = 1:6
        for r = 1:20
            onList = ismember(labels, randperm(50, sizes(s)));
            isGallery = chooseGallery(labels(onList), 5);
            predicted = matchAll(features(:, onList), labels(onList), isGallery, useEigenfaces);
            truth = labels(onList)(~isGallery);
            accuracy(s, r) = mean(predicted == truth);
            if s == 6, perPerson += arrayfun(@(p) mean(predicted(truth == p) == p), 1:50) / 20; end
        end
    end
end

function R = strangerTest(features, labels, useEigenfaces)  % 25 known visitors and 25 strangers: precision, recall, F1, strangers accepted (Lecture 3)
    rng(0);
    known = ismember(labels, randperm(50, 25));
    isGallery = false(size(labels));
    isGallery(known) = chooseGallery(labels(known), 5);
    [predicted, accepted] = matchAll(features, labels, isGallery, useEigenfaces);
    isKnown = known(~isGallery);
    correct = accepted & isKnown & predicted == labels(~isGallery);
    precision = sum(correct) / max(sum(accepted), 1);
    recall = sum(correct) / sum(isKnown);
    R = [precision, recall, 2 * precision * recall / max(precision + recall, eps), mean(accepted(~isKnown))];
end

function A = lightingTest(DATA)  % Yale faces under changing light: without and with the homomorphic filter, for moderate and harsh light
    files = glob([DATA 'yale/images/p*/*A[+-]*E[+-]*.png']);
    for i = 1:numel(files)
        t = str2double(regexp(files{i}, 'images/p(\d+)/.*A([+-]\d+)E([+-]\d+)', 'tokens'){1});
        labels(i) = t(1) + 1;
        level(i) = sum(max(abs(t(2:3))) > [20 50]);  % 0 is near-frontal light, 1 moderate, 2 harsh
        picture = imread(files{i});
        face = imresize(im2double(picture), [80 60]);
        features(:, i, 1:2) = [zscore(face(:)), homomorphicFilter(repmat(picture, [1 1 3]))];
    end
    unseen = labels > 19;  % people 1 to 19 were used to choose the filter values
    tested = level(unseen & level > 0);
    for v = 1:2
        correct = matchAll(features(:, unseen, v), labels(unseen), level(unseen) == 0, true) == labels(unseen & level > 0);
        A(v, :) = [mean(correct(tested == 1)), mean(correct(tested == 2))];
    end
end

function rgb = paintMask(rgb, b)  % covers the lower 45% of the face box with a plain light mask
    rgb(b(2) + round(0.55 * b(4)) - 1:b(2) + b(4) - 1, b(1):b(1) + b(3) - 1, :) = 205;
end

function frame = readFrame(path)  % reads one video frame as RGB; shrinks the very large phone frames
    frame = im2uint8(imread(path));
    if size(frame, 3) == 1, frame = repmat(frame, [1 1 3]); end
    if rows(frame) > 640, frame = imresize(frame, 1 / 3); end
end

function T = measureLiveness(DATA, M)  % one row per 3-second window of every clip: kind, clip, blink seen, LBP histogram
    kinds = {'real', 'print', 'print_cut', 'monitor', 'phone'};
    T = [];
    for k = 1:5
        for clip = 1:10
            folder = sprintf('%sliveness_frames/%s/%02d/', DATA, kinds{k}, clip);
            files = dir([folder '*.jpg']);
            for w = 1:min(4, max(1, floor(numel(files) / 45)))  % up to four windows of 45 frames
                window = files((w - 1) * 45 + 1:min(w * 45, numel(files)));
                frames = arrayfun(@(f) readFrame([folder f.name]), window, 'UniformOutput', false);
                box = detectFace(frames{round(numel(frames) / 2)}, M);
                if isempty(box), continue; end
                faces = cropAllFrames(frames, box);
                T(end + 1, :) = [k, clip, blinkSeen(faces), lbpHistogram(faces)];
            end
        end
    end
end

function rates = liveRates(T)  % pass rate per clip for texture, blink and both; texture is trained on the other half of the clips
    [kind, clip, blink, texture] = deal(T(:, 1), T(:, 2), T(:, 3), T(:, 4:end));
    for fold = 0:1
        train = mod(clip, 2) == fold;
        lbpReal = mean(texture(train & kind == 1, :), 1);
        lbpFake = mean(texture(train & kind > 1, :), 1);
        for i = find(~train)', looks(i, 1) = looksReal(texture(i, :), lbpReal, lbpFake); end
    end
    passed = [looks, blink, looks & blink];
    for k = 1:5
        for c = 1:10
            clipPassed(c, :) = any(passed(kind == k & clip == c, :), 1);
        end
        rates(k, :) = mean(clipPassed, 1);
    end
end

if ~exist('vgg_conv.mat', 'file') || ~exist('../Kiosk_Data', 'dir'), disp('This test script needs vgg_conv.mat and the public datasets of the report in ../Kiosk_Data. The kiosk itself needs neither.'); return; end
net = load('vgg_conv.mat');
DATA = '../Kiosk_Data/';
labels = kron(1:50, ones(1, 15));
shots = repmat(1:15, 1, 50);
paths = glob([DATA 'gt/images/gt_db/s*/*.jpg']);
corners = cell2mat(arrayfun(@(i) dlmread(sprintf('%sgt/labels/labels/lab%03d', DATA, (labels(i) - 1) * 20 + shots(i)))(1:4), (1:750)', 'UniformOutput', false));
trueBoxes = [corners(:, 1:2) + 1, corners(:, 3:4) - corners(:, 1:2)];
heldOut = ~ismember(shots, [2 7 12]);  % the other 150 images teach the face template
M.faceTemplate = learnFaceTemplate(paths(~heldOut), trueBoxes(~heldOut, :));
gt = describeImages(paths, net, M, @(rgb, i) rgb);
overlap = diag(rectint(gt.boxes, trueBoxes));
iou = overlap ./ (prod(gt.boxes(:, 3:4), 2) + prod(trueBoxes(:, 3:4), 2) - overlap);
detection = [mean(iou(heldOut) >= 0.5), mean(iou(heldOut))]  % share of faces found, mean overlap (Lecture 8)

[eigenCurve, eigenPeople] = listCurve(gt.filtered, labels, true);
[vggCurve, vggPeople] = listCurve(gt.vgg, labels, false);
listAccuracy = [mean(eigenCurve, 2), mean(vggCurve, 2)]  % rows: 5, 10, 20, 30, 40, 50 people; columns: Eigenfaces, VGG-Face
listSpread = [std(eigenCurve, 0, 2), std(vggCurve, 0, 2)]
wearers = ismember(1:50, [3 6 8 12 19 21 28 36 39 42 47 48 49]);
glasses = [mean(eigenPeople(wearers)), mean(eigenPeople(~wearers)), mean(vggPeople(wearers)), mean(vggPeople(~wearers))]
strangersEigenfaces = strangerTest(gt.filtered, labels, true)
strangersVgg = strangerTest(gt.vgg, labels, false)
lighting = lightingTest(DATA)

feiLabels = kron(1:50, ones(1, 12));
feiShots = repmat([11 12 5 6 4 7 3 8 2 9 1 10], 1, 50);
pose = repmat([0 0 1 1 2 2 3 3 4 4 5 5], 1, 50);  % 0 is frontal, 5 is full profile
fei = describeImages(arrayfun(@(i) sprintf('%sfei/images/%d-%02d.jpg', DATA, feiLabels(i), feiShots(i)), 1:600, 'UniformOutput', false), net, M, @(rgb, i) rgb);
for level = 1:5
    keep = pose == 0 | pose == level;
    headTurn(1, level) = mean(matchAll(fei.filtered(:, keep), feiLabels(keep), pose(keep) == 0, true) == feiLabels(pose == level));
    headTurn(2, level) = mean(matchAll(fei.vgg(:, keep), feiLabels(keep), pose(keep) == 0, false) == feiLabels(pose == level));
end
headTurn

rng(0);
isGallery = chooseGallery(labels, 5);
tests = find(~isGallery & mod(shots, 3) == 0, 150);
enrolled = [true(1, nnz(isGallery)), false(1, 150)];
spoil = {@(rgb, k) paintMask(rgb, trueBoxes(tests(k), :)), @(rgb, k) uint8(127.5 * (double(rgb) / 255) .^ 2)};  % mask, strong backlight
for c = 1:2
    D = describeImages(paths(tests), net, M, spoil{c});
    maskAndBacklight(1, c) = mean(matchAll([gt.filtered(:, isGallery), D.filtered], [labels(isGallery), labels(tests)], enrolled, true) == labels(tests));
    maskAndBacklight(2, c) = mean(matchAll([gt.vgg(:, isGallery), D.vgg], [labels(isGallery), labels(tests)], enrolled, false) == labels(tests));
end
maskAndBacklight

live = measureLiveness(DATA, M);
liveness = liveRates(live)  % rows: real, print, cut print, monitor, phone; columns: texture, blink, both
M.lbpReal = mean(live(live(:, 1) == 1, 4:end), 1);
M.lbpFake = mean(live(live(:, 1) > 1, 4:end), 1);
save('models.mat', '-struct', 'M');

files = dir([DATA 'liveness_frames/real/03/*.jpg']);
frames = arrayfun(@(t) readFrame([DATA 'liveness_frames/real/03/' files(30 + t).name]), 1:45, 'UniformOutput', false);
codes = arrayfun(@(i) sprintf('%04d', i), 1:50, 'UniformOutput', false);
seconds = zeros(8, 1);
for repeat = 1:5
    tic; box = detectFace(frames{23}, M); seconds(1) += toc;
    tic; faces = cropAllFrames(frames, box); seconds(2) += toc;
    tic; looksReal(lbpHistogram(faces), M.lbpReal, M.lbpFake); seconds(3) += toc;
    tic; blinkSeen(faces); seconds(4) += toc;
    tic; face = homomorphicFilter(cropFace(frames{23}, box)); seconds(5) += toc;
    tic; [model, weights] = trainEigenfaces(gt.filtered(:, 1:250)); seconds(7) += toc;
    tic; matchFace(projectFaces(face, model), weights, labels(1:250)); seconds(6) += toc;
    tic; find(strcmp(codes, '0042')); seconds(8) += toc;
end
stepSeconds = seconds / 5  % find face, crop frames, texture, blink, homomorphic, match, train, booking code
