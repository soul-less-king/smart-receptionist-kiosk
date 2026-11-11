% experiments.m - Part 5: every test and chart in the report. Run once: results land in results/.
% Consent-Based Smart Receptionist Kiosk, CMAI 480, Qatar University.
% Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
findFace; recognizeFace; checkLiveness;
warning('off', 'all');

% Overlap of two boxes: intersection over union (Lecture 8).
function x = overlap(a, b)
    w = max(0, min(a(1) + a(3), b(1) + b(3)) - max(a(1), b(1)));
    h = max(0, min(a(2) + a(4), b(2) + b(4)) - max(a(2), b(2)));
    x = w * h / (a(3) * a(4) + b(3) * b(4) - w * h);
end

% Three descriptions of one face: plain pixels, homomorphic pixels, VGG-Face.
function [plain, filtered, vgg] = describeFace(rgb, box, net, S)
    if isempty(box), box = [1 1 columns(rgb) rows(rgb)]; end
    face = cropFace(im2double(rgb2gray(rgb)), box, S.faceSize);
    plain = (face(:) - mean(face(:))) / std(face(:));
    filtered = faceVector(face, S);
    x = runVgg(cropFace(rgb, box, [224 224]), net, 31);
    vgg = double(squeeze(mean(mean(x, 1), 2)));
    vgg = vgg / norm(vgg);
end

% Georgia Tech faces: find each face, measure the box, describe the face.
function gt = loadGeorgiaTech(DATA, net, S)
    file = 'results/georgiaTech.mat';
    if exist(file, 'file'), gt = load(file); return; end
    gt.labels = kron(1:50, ones(1, 15));
    gt.shots = repmat(1:15, 1, 50);
    gt.iou = zeros(1, 750);
    gt.seconds = gt.iou;
    gt.plain = zeros(prod(S.faceSize), 750);
    gt.filtered = gt.plain;
    gt.vgg = zeros(512, 750);
    for i = 1:750
        rgb = imread(sprintf('%sgt/images/gt_db/s%02d/%02d.jpg', DATA, gt.labels(i), gt.shots(i)));
        v = dlmread(sprintf('%sgt/labels/labels/lab%03d', DATA, (gt.labels(i) - 1) * 20 + gt.shots(i)));
        started = tic;
        box = detectFace(rgb, net, S);
        gt.seconds(i) = toc(started);
        if ~isempty(box), gt.iou(i) = overlap(box, [v(1) + 1, v(2) + 1, v(3) - v(1), v(4) - v(2)]); end
        [gt.plain(:, i), gt.filtered(:, i), gt.vgg(:, i)] = describeFace(rgb, box, net, S);
    end
    save('-binary', file, '-struct', 'gt');
end

% Picks a random enrollment set: perPerson images for each person.
function gallery = chooseGallery(labels, perPerson)
    gallery = false(size(labels));
    for p = unique(labels)
        where = find(labels == p);
        gallery(where(randperm(numel(where), perPerson))) = true;
    end
end

% Matches every non-gallery face against the gallery.
function [predicted, ratios] = matchAll(X, labels, gallery, useEigenfaces, S)
    G = X(:, gallery);
    T = X(:, ~gallery);
    if useEigenfaces
        model = trainEigenfaces(G, S.eigenfaces);
        G = projectFaces(G, model);
        T = projectFaces(T, model);
    end
    known = labels(gallery);
    predicted = zeros(1, columns(T));
    ratios = predicted;
    for i = 1:columns(T)
        [j, ratios(i)] = matchFace(T(:, i), G, known);
        predicted(i) = known(j);
    end
end

% Accuracy as today's list grows, averaged over random lists.
function accuracy = listAccuracy(X, labels, sizes, useEigenfaces, repeats, S)
    rng(0);
    accuracy = zeros(numel(sizes), repeats);
    for s = 1:numel(sizes)
        for r = 1:repeats
            L = labels(ismember(labels, randperm(50, sizes(s))));
            keep = ismember(labels, unique(L));
            gallery = chooseGallery(L, 5);
            accuracy(s, r) = mean(matchAll(X(:, keep), L, gallery, useEigenfaces, S) == L(~gallery));
        end
    end
end

% Known visitors versus strangers: ROC, AUC, precision, recall, F1 (Lecture 3).
function R = openSetTest(X, labels, useEigenfaces, limit, S)
    rng(0);
    known = ismember(labels, randperm(50, 25));
    gallery = false(size(labels));
    gallery(known) = chooseGallery(labels(known), 5);
    [predicted, ratios] = matchAll(X, labels, gallery, useEigenfaces, S);
    isKnown = known(~gallery);
    correct = isKnown & predicted == labels(~gallery);
    limits = sort(ratios);
    R.tpr = arrayfun(@(t) mean(ratios(isKnown) <= t & correct(isKnown)), limits);
    R.fpr = arrayfun(@(t) mean(ratios(~isKnown) <= t), limits);
    R.auc = trapz(R.fpr, R.tpr);
    accepted = ratios <= limit;
    tp = sum(accepted & correct);
    R.precision = tp / max(sum(accepted), 1);
    R.recall = tp / sum(isKnown);
    R.f1 = 2 * R.precision * R.recall / max(R.precision + R.recall, eps);
    R.strangers = mean(accepted(~isKnown));
end

% Per-person accuracy, used to compare people with and without glasses.
function perPerson = accuracyPerPerson(X, labels, useEigenfaces, repeats, S)
    rng(0);
    hits = zeros(1, 50);
    for r = 1:repeats
        gallery = chooseGallery(labels, 5);
        predicted = matchAll(X, labels, gallery, useEigenfaces, S);
        truth = labels(~gallery);
        for p = 1:50, hits(p) += mean(predicted(truth == p) == p); end
    end
    perPerson = hits / repeats;
end

% Changing light on Yale faces: none, histogram equalization, homomorphic.
function A = lightingTest(DATA, S)
    files = glob([DATA 'yale/images/p*/*.png']);
    files = files(~cellfun(@isempty, regexp(files, 'A[+-]\d+E[+-]\d+')));
    n = numel(files);
    labels = zeros(1, n);
    severity = labels;
    X = repmat({zeros(prod(S.faceSize), n)}, 1, 3);
    for i = 1:n
        t = regexp(files{i}, 'images/p(\d+)/.*A([+-]\d+)E([+-]\d+)', 'tokens');
        labels(i) = str2double(t{1}{1}) + 1;
        angle = max(abs(str2double(t{1}{2})), abs(str2double(t{1}{3})));
        severity(i) = (angle > 20) + (angle > 50);
        face = imresize(im2double(imread(files{i})), S.faceSize);
        equalized = histeq(max(min(face, 1), 0));
        X{1}(:, i) = (face(:) - mean(face(:))) / std(face(:));
        X{2}(:, i) = (equalized(:) - mean(equalized(:))) / std(equalized(:));
        X{3}(:, i) = faceVector(face, S);
    end
    keep = labels > 19;
    L = labels(keep);
    hard = severity(keep);
    truth = L(hard > 0);
    level = hard(hard > 0);
    A = zeros(3, 2);
    for v = 1:3
        predicted = matchAll(X{v}(:, keep), L, hard == 0, true, S);
        A(v, :) = [mean(predicted(level == 1) == truth(level == 1)), mean(predicted(level == 2) == truth(level == 2))];
    end
end

% Head turn: enroll frontal FEI faces, test at five turn levels.
function A = headTurnTest(DATA, net, S)
    file = 'results/headTurn.mat';
    if exist(file, 'file')
        load(file);
    else
        shots = [11 12 5 6 4 7 3 8 2 9 1 10];
        filtered = zeros(prod(S.faceSize), 600);
        vgg = zeros(512, 600);
        labels = kron(1:50, ones(1, 12));
        pose = repmat([0 0 1 1 2 2 3 3 4 4 5 5], 1, 50);
        for i = 1:600
            rgb = imread(sprintf('%sfei/images/%d-%02d.jpg', DATA, labels(i), shots(mod(i - 1, 12) + 1)));
            [~, filtered(:, i), vgg(:, i)] = describeFace(rgb, detectFace(rgb, net, S), net, S);
        end
        save('-binary', file, 'filtered', 'vgg', 'labels', 'pose');
    end
    A = zeros(2, 5);
    for level = 1:5
        keep = pose == 0 | pose == level;
        L = labels(keep);
        gallery = pose(keep) == 0;
        A(1, level) = mean(matchAll(filtered(:, keep), L, gallery, true, S) == L(~gallery));
        A(2, level) = mean(matchAll(vgg(:, keep), L, gallery, false, S) == L(~gallery));
    end
end

% Simulated mask and strong backlight applied to whole frames.
function A = spoiledFrameTest(DATA, gt, net, S)
    file = 'results/spoiled.mat';
    if exist(file, 'file'), load(file); return; end
    rng(0);
    gallery = chooseGallery(gt.labels, 5);
    tests = find(~gallery & mod(gt.shots, 3) == 0, 150);
    A = zeros(2, 2);
    for condition = 1:2
        filtered = zeros(prod(S.faceSize), numel(tests));
        vgg = zeros(512, numel(tests));
        for k = 1:numel(tests)
            i = tests(k);
            rgb = imread(sprintf('%sgt/images/gt_db/s%02d/%02d.jpg', DATA, gt.labels(i), gt.shots(i)));
            if condition == 1
                v = dlmread(sprintf('%sgt/labels/labels/lab%03d', DATA, (gt.labels(i) - 1) * 20 + gt.shots(i)));
                rgb(v(2) + round(0.55 * (v(4) - v(2))):v(4), v(1) + 1:v(3), :) = 205;
            else
                rgb = uint8(127.5 * (double(rgb) / 255) .^ 2);
            end
            [~, filtered(:, k), vgg(:, k)] = describeFace(rgb, detectFace(rgb, net, S), net, S);
        end
        labels = [gt.labels(gallery), gt.labels(tests)];
        known = [true(1, nnz(gallery)), false(1, numel(tests))];
        A(1, condition) = mean(matchAll([gt.filtered(:, gallery), filtered], labels, known, true, S) == gt.labels(tests));
        A(2, condition) = mean(matchAll([gt.vgg(:, gallery), vgg], labels, known, false, S) == gt.labels(tests));
    end
    save('-binary', file, 'A');
end

% Reads one video frame as RGB; shrinks the very large phone frames.
function frame = readFrame(path)
    frame = imread(path);
    if islogical(frame), frame = uint8(frame) * 255; end
    if size(frame, 3) == 1, frame = repmat(frame, [1 1 3]); end
    if rows(frame) > 640, frame = imresize(frame, 1 / 3); end
end

% Texture and blink measurements for every 3-second window of every clip.
function L = loadLiveness(DATA, net, S)
    file = 'results/liveness.mat';
    if exist(file, 'file'), L = load(file); return; end
    kinds = {'real', 'print', 'print_cut', 'monitor', 'phone'};
    L = struct('kind', [], 'clip', [], 'texture', [], 'blink', []);
    for k = 1:5
        for clip = 1:10
            folder = sprintf('%sliveness_frames/%s/%02d/', DATA, kinds{k}, clip);
            files = dir([folder '*.jpg']);
            for w = 1:min(4, max(1, floor(numel(files) / S.captureFrames)))
                first = (w - 1) * S.captureFrames;
                count = min(S.captureFrames, numel(files) - first);
                middle = readFrame([folder files(first + round(count / 2)).name]);
                box = detectFace(middle, net, S);
                if isempty(box), continue; end
                gray = cell(count, 1);
                for t = 1:count, gray{t} = im2double(rgb2gray(readFrame([folder files(first + t).name]))); end
                faces = cropAllFrames(gray, box, S);
                L.kind(end + 1) = k;
                L.clip(end + 1) = clip;
                L.texture(end + 1, :) = averageTexture(faces);
                L.blink(end + 1) = blinkScore(faces, S);
            end
        end
    end
    save('-binary', file, '-struct', 'L');
end

% Pass rate per clip for texture, blink and both, trained on half the clips.
function rates = evaluateLiveness(L, S)
    score = zeros(size(L.kind));
    for fold = 0:1
        train = mod(L.clip, 2) == fold;
        real = mean(L.texture(train & L.kind == 1, :), 1);
        fake = mean(L.texture(train & L.kind > 1, :), 1);
        for i = find(~train)
            score(i) = norm(L.texture(i, :) - fake) - norm(L.texture(i, :) - real);
        end
    end
    rates = zeros(5, 3);
    for k = 1:5
        passed = zeros(3, 10);
        for clip = 1:10
            w = L.kind == k & L.clip == clip;
            passed(:, clip) = [any(score(w) > S.textureLimit); any(L.blink(w) > S.blinkLimit); any(score(w) > S.textureLimit & L.blink(w) > S.blinkLimit)];
        end
        rates(k, :) = mean(passed, 2)';
    end
end

% Time of each processing step, averaged over five runs.
function T = measureSpeed(DATA, gt, net, M, S)
    folder = [DATA 'liveness_frames/real/03/'];
    files = dir([folder '*.jpg']);
    frames = cell(S.captureFrames, 1);
    gray = frames;
    for t = 1:S.captureFrames
        frames{t} = readFrame([folder files(30 + t).name]);
        gray{t} = im2double(rgb2gray(frames{t}));
    end
    model = trainEigenfaces(gt.filtered(:, 1:250), S.eigenfaces);
    gallery = projectFaces(gt.filtered(:, 1:250), model);
    codes = arrayfun(@(i) sprintf('%04d', i), 1:50, 'UniformOutput', false);
    T = zeros(1, 8);
    for repeat = 1:5
        a = tic; box = detectFace(frames{23}, net, S); T(1) += toc(a);
        a = tic; faces = cropAllFrames(gray, box, S); T(2) += toc(a);
        a = tic; textureScore(faces, M); T(3) += toc(a);
        a = tic; blinkScore(faces, S); T(4) += toc(a);
        a = tic; v = faceVector(cropFace(gray{23}, box, S.faceSize), S); T(5) += toc(a);
        a = tic; matchFace(projectFaces(v, model), gallery, gt.labels(1:250)); T(6) += toc(a);
        a = tic; trainEigenfaces(gt.filtered(:, 1:250), S.eigenfaces); T(7) += toc(a);
        a = tic; find(strcmp(codes, '0042')); T(8) += toc(a);
    end
    T = T / 5;
end

% Starts a chart.
function newChart(words, xWords, yWords)
    figure('visible', 'off', 'position', [0 0 620 400]);
    title(words); xlabel(xWords); ylabel(yWords); grid on; hold on;
end

% Saves the chart into results/.
function saveChart(name)
    print(gcf, ['results/' name '.png'], '-dpng', '-r170');
    close(gcf);
end

S = settings();
net = load('vgg_conv.mat');
DATA = '../Kiosk_Data/';
if ~exist('results', 'dir'), mkdir('results'); end
gt = loadGeorgiaTech(DATA, net, S);
heldOut = ~ismember(gt.shots, [2 7 12]);
printf('DETECTION held-out: IoU>=0.5 %.3f, mean IoU %.3f, %.2f s per frame\n', mean(gt.iou(heldOut) >= 0.5), mean(gt.iou(heldOut)), mean(gt.seconds));

sizes = [5 10 20 30 40 50];
repeats = 20;
plainCurve = listAccuracy(gt.plain, gt.labels, sizes, true, repeats, S);
filteredCurve = listAccuracy(gt.filtered, gt.labels, sizes, true, repeats, S);
vggCurve = listAccuracy(gt.vgg, gt.labels, sizes, false, repeats, S);
newChart('Accuracy as today''s list grows', 'People on today''s list', 'Top-1 accuracy');
errorbar(sizes, mean(plainCurve, 2), std(plainCurve, 0, 2), '-o');
errorbar(sizes, mean(filteredCurve, 2), std(filteredCurve, 0, 2), '-s');
errorbar(sizes, mean(vggCurve, 2), std(vggCurve, 0, 2), '-^');
legend('Eigenfaces', 'Eigenfaces + homomorphic', 'VGG-Face (ready-made)', 'location', 'southwest');
ylim([0 1]);
saveChart('list_size');
printf('LIST SIZE'); printf(' %d', sizes); printf('\nEigenfaces            '); printf(' %.3f', mean(plainCurve, 2));
printf('\nEigenfaces+homomorphic'); printf(' %.3f', mean(filteredCurve, 2)); printf('\nVGG-Face              '); printf(' %.3f', mean(vggCurve, 2)); printf('\n');

pcaOpen = openSetTest(gt.filtered, gt.labels, true, S.matchRatio, S);
vggOpen = openSetTest(gt.vgg, gt.labels, false, S.matchRatio, S);
newChart('Accepting today''s visitors, rejecting strangers (25 known, 25 unknown)', 'Strangers accepted', 'Visitors correctly accepted');
plot(pcaOpen.fpr, pcaOpen.tpr, 'linewidth', 2);
plot(vggOpen.fpr, vggOpen.tpr, 'linewidth', 2);
plot([0 1], [0 1], 'k--');
legend(sprintf('Eigenfaces + homomorphic (AUC %.2f)', pcaOpen.auc), sprintf('VGG-Face (AUC %.2f)', vggOpen.auc), 'Chance', 'location', 'southeast');
saveChart('roc');
printf('OPEN SET Eigen AUC %.3f precision %.3f recall %.3f F1 %.3f strangers %.3f\n', pcaOpen.auc, pcaOpen.precision, pcaOpen.recall, pcaOpen.f1, pcaOpen.strangers);
printf('OPEN SET VGG   AUC %.3f precision %.3f recall %.3f F1 %.3f strangers %.3f\n', vggOpen.auc, vggOpen.precision, vggOpen.recall, vggOpen.f1, vggOpen.strangers);

lighting = lightingTest(DATA, S);
newChart('Eigenfaces under changing light (unseen people)', 'Lighting', 'Top-1 accuracy');
bar(lighting');
set(gca, 'xtick', 1:2, 'xticklabel', {'Moderate', 'Harsh'});
legend('No correction', 'Histogram equalization', 'Homomorphic filter', 'location', 'northoutside', 'orientation', 'horizontal');
ylim([0 1]);
saveChart('lighting');
printf('LIGHTING none %.3f %.3f | histeq %.3f %.3f | homomorphic %.3f %.3f (moderate, harsh)\n', lighting(1, :), lighting(2, :), lighting(3, :));

headTurn = headTurnTest(DATA, net, S);
newChart('Failure case: turning the head', 'Head turn level (1 small, 5 full profile)', 'Top-1 accuracy');
plot(1:5, headTurn(1, :), '-o', 'linewidth', 2);
plot(1:5, headTurn(2, :), '-^', 'linewidth', 2);
legend('Eigenfaces + homomorphic', 'VGG-Face', 'location', 'southwest');
ylim([0 1]);
saveChart('head_turn');
printf('HEAD TURN eigen'); printf(' %.3f', headTurn(1, :)); printf('\nHEAD TURN vgg  '); printf(' %.3f', headTurn(2, :)); printf('\n');

glasses = ismember(1:50, [3 6 8 12 19 21 28 36 39 42 47 48 49]);
pcaPeople = accuracyPerPerson(gt.filtered, gt.labels, true, repeats, S);
vggPeople = accuracyPerPerson(gt.vgg, gt.labels, false, repeats, S);
printf('GLASSES eigen wearers %.3f others %.3f | vgg wearers %.3f others %.3f\n', mean(pcaPeople(glasses)), mean(pcaPeople(~glasses)), mean(vggPeople(glasses)), mean(vggPeople(~glasses)));
spoiled = spoiledFrameTest(DATA, gt, net, S);
printf('SIMULATED mask eigen %.3f vgg %.3f | backlight eigen %.3f vgg %.3f\n', spoiled(1, 1), spoiled(2, 1), spoiled(1, 2), spoiled(2, 2));

L = loadLiveness(DATA, net, S);
rates = evaluateLiveness(L, S);
kinds = {'Real', 'Print', 'Cut print', 'Monitor', 'Phone'};
newChart('Pass rate per clip (real should be high, attacks low)', '', 'Pass rate');
bar(rates);
set(gca, 'xtick', 1:5, 'xticklabel', kinds);
legend('Texture only', 'Blink only', 'Both (kiosk rule)', 'location', 'northoutside', 'orientation', 'horizontal');
ylim([0 1]);
saveChart('liveness');
for k = 1:5, printf('LIVENESS %-15s texture %.2f blink %.2f both %.2f\n', kinds{k}, rates(k, :)); end
M.lbpReal = mean(L.texture(L.kind == 1, :), 1);
M.lbpFake = mean(L.texture(L.kind > 1, :), 1);
save('models.mat', '-struct', 'M');

T = measureSpeed(DATA, gt, net, M, S);
printf('SPEED Find face %.3f Crop frames %.3f Texture %.3f Blink %.3f Homomorphic %.3f Match %.4f Train %.3f Code %.5f | total %.2f s\n', T, sum(T(1:6)));
save('results/results.mat', 'sizes', 'plainCurve', 'filteredCurve', 'vggCurve', 'pcaOpen', 'vggOpen', 'lighting', 'headTurn', 'spoiled', 'rates', 'T', 'pcaPeople', 'vggPeople', 'glasses');
disp('ALL EXPERIMENTS DONE');
