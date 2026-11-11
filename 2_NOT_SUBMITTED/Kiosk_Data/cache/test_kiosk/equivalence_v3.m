% equivalence_v3.m - same inputs through one code version; saves every output. Set isOld and outFile first.
findFace; recognizeFace; checkLiveness; experiments_functions;
P = '/home/userstorexxx-gmail-com/Desktop/projectCV/';
DATA = [P 'Kiosk_Data/'];
models = load([P 'Kiosk_Data/cache/before_rewrite_2026-11-10/models.mat']);
if isOld, templateArg = models; else, templateArg = models.faceTemplate; end
net = load([P 'Kiosk/vgg_conv.mat']);
R = struct();
% face finder on camera frames, GT photos, phone frames (small pictures) and an empty scene
pics = {};
for k = {'real/03/0053.jpg', 'real/09/0010.jpg', 'print/01/0100.jpg', 'monitor/02/0050.jpg', 'phone/01/0001.jpg', 'phone/05/0080.jpg', 'phone/09/0060.jpg'}, pics{end + 1} = readFrame([DATA 'liveness_frames/' k{1}]); end
for k = {'s01/01.jpg', 's17/09.jpg', 's33/04.jpg'}, pics{end + 1} = imread([DATA 'gt/images/gt_db/' k{1}]); end
pics{end + 1} = zeros(480, 640, 3, 'uint8');
for k = 1:numel(pics)
    b = detectFace(pics{k}, templateArg); if isempty(b), b = [0 0 0 0]; end; R.boxes(k, :) = b;
    R.homomorphic(:, k) = homomorphicFilter(cropFace(pics{k}, [100 80 200 260]));
    R.crop{k} = cropFace(pics{k}, [600 450 100 100]);
end
% readFrame on the all-black frames and big phone frames
R.black = readFrame([DATA 'liveness_frames/monitor/01/0001.jpg']);
R.phone = readFrame([DATA 'liveness_frames/phone/03/0010.jpg']);
% liveness pieces on several clips
for k = 1:4
    clipNames = {'real/03/', 'print/02/', 'monitor/05/', 'phone/07/'};
    files = dir([DATA 'liveness_frames/' clipNames{k} '*.jpg']);
    frames = arrayfun(@(f) readFrame([DATA 'liveness_frames/' clipNames{k} f.name]), files(1:45), 'UniformOutput', false);
    b = detectFace(frames{23}, templateArg); if isempty(b), b = [200 100 200 240]; end
    faces = cropAllFrames(frames, b);
    R.lbp(k, :) = lbpHistogram(faces); R.blink(k) = blinkSeen(faces);
    R.looks(k) = looksReal(R.lbp(k, :), models.lbpReal, models.lbpFake);
end
% VGG embeddings through describeImages
D = describeImages(glob([DATA 'gt/images/gt_db/s0[1-2]/0[1-2].jpg']), net, templateArg, @(rgb, i) rgb);
R.vgg = D.vgg; R.filtered = D.filtered; R.dboxes = D.boxes;
% liveness tally on random window results
rand('seed', 3); W = [kron((1:5)', ones(30, 1)), repmat(kron((1:10)', ones(3, 1)), 5, 1), rand(150, 1) > 0.5, rand(150, 256) / 256];
W(W(:, 1) == 2 & W(:, 2) == 4, :) = [];   % one clip with no windows at all
if isOld
    R.rates = liveRates(W);
else
    live = W;
    for half = 0:1
        learn = mod(live(:, 2), 2) == half;
        looks(~learn, 1) = looksReal(live(~learn, 4:end), mean(live(learn & live(:, 1) == 1, 4:end), 1), mean(live(learn & live(:, 1) > 1, 4:end), 1));
    end
    passed = [looks, live(:, 3), looks & live(:, 3)];
    for check = 1:3
        liveness(:, check) = mean(accumarray(live(:, 1:2), passed(:, check), [5 10], @any), 2);
    end
    R.rates = liveness;
end
% today's list from the test fixture
cd([P 'Kiosk_Data/cache/test_kiosk/fixture']);
today = loadTodaysList(templateArg);
R.names = today.names; R.codes = today.codes;
if isOld, R.owners = today.labels; R.todayWeights = today.gallery; else, R.owners = today.photoOwners; R.todayWeights = today.photoWeights; end
save('-binary', outFile, 'R');
printf('saved %s\n', outFile);
