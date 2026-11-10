% equivalence.m - runs the same small inputs through one version of the code and saves every output.
% Call with isOld and outFile set, from a folder holding that version's part files and experiments_functions.m.
findFace; recognizeFace; checkLiveness; experiments_functions;
P = '/home/userstorexxx-gmail-com/Desktop/projectCV/';
DATA = [P 'Kiosk_Data/'];
models = load([P 'Kiosk_Data/cache/before_rewrite_2026-11-10/models.mat']);
if isOld, templateArg = models; else, templateArg = models.faceTemplate; end
net = load([P 'Kiosk/vgg_conv.mat']);
R = struct();

img = imread([DATA 'gt/images/gt_db/s01/01.jpg']);
gray = im2double(rgb2gray(img));
if isOld, R.hist = cellHistograms(gray); else, R.hist = gradientHistograms(gray); end

paths = glob([DATA 'gt/images/gt_db/s0[1-4]/0[1-3].jpg']);
D = describeImages(paths, net, templateArg, @(rgb, i) rgb);
R.filtered = D.filtered; R.vgg = D.vgg; R.dboxes = D.boxes;
owners = kron(1:4, ones(1, 3));
[model, weights] = trainEigenfaces(D.filtered(:, 1:10));
R.weights = weights;
R.projected = projectFaces(D.filtered(:, 11:12), model);
[R.matchIndex, R.matchAccepted] = matchFace(R.projected(:, 1), weights, owners(1:10));
[R.predicted, R.accepted] = matchAll(D.filtered, owners, logical([1 1 0 1 1 0 1 1 0 1 1 0]), true);
[R.predictedVgg, R.acceptedVgg] = matchAll(D.vgg, owners, logical([1 1 0 1 1 0 1 1 0 1 1 0]), false);
R.template = learnFaceTemplate(paths(1:6), repmat([200 100 181 241], 6, 1));

rng(1); features = randn(300, 750); people = kron(1:50, ones(1, 15));
[R.curve, R.perPerson] = listCurve(features, people, true);
[R.curveVgg, R.perPersonVgg] = listCurve(features, people, false);
R.strangers = strangerTest(features, people, true);
R.strangersVgg = strangerTest(features, people, false);
rng(0); R.gallery = chooseGallery(people, 5);

R.lighting = lightingTest(DATA);

files = dir([DATA 'liveness_frames/real/03/*.jpg']);
frames = arrayfun(@(f) readFrame([DATA 'liveness_frames/real/03/' f.name]), files(31:75), 'UniformOutput', false);
box = detectFace(frames{23}, templateArg);
faces = cropAllFrames(frames, box);
R.box = box; R.faces = faces;
R.lbp = lbpHistogram(faces); R.blink = blinkSeen(faces); R.band = bandSimilarity(faces, [0.26 0.56]);
R.looks = looksReal(R.lbp, models.lbpReal, models.lbpFake);
R.phoneFrame = readFrame([DATA 'liveness_frames/phone/01/0001.jpg']);
R.noFace = isempty(detectFace(zeros(480, 640, 3, 'uint8'), templateArg));

rng(2); W = [kron((1:5)', ones(20, 1)), repmat(kron((1:10)', ones(2, 1)), 5, 1), rand(100, 1) > 0.5, rand(100, 256)];
R.rates = liveRates(W);
R.mask = paintMask(img, [100 100 200 240]);

cd([P 'Kiosk_Data/cache/test_kiosk/fixture']);
today = loadTodaysList(templateArg);
R.names = today.names; R.codes = today.codes;
if isOld, R.owners = today.labels; R.todayWeights = today.gallery; else, R.owners = today.photoOwners; R.todayWeights = today.photoWeights; end
save('-binary', outFile, 'R');
printf('saved %s\n', outFile);
