% eq_simplify.m - runs the experiment helper functions of one code version on fixed made-up features and saves every output.
% Run from a folder holding findFace.m, recognizeFace.m, checkLiveness.m and experiments_functions.m. The version is detected by itself.
findFace; recognizeFace; checkLiveness; experiments_functions;
isOld = nargin('chooseGallery') == 2;
T = '/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/cache/test_kiosk/';
rand('seed', 7); randn('seed', 7);
people = kron(1:50, ones(1, 15));
centers = randn(300, 50);
noise = randn(300, 750);
R = struct();
for trial = 1:10
    spread = [1.0 1.6 2.0 2.4 3.0](ceil(trial / 2));
    useEigenfaces = mod(trial, 2);
    features = centers(:, people) + spread * noise;
    tag = sprintf('%d', trial);
    [curve, perPerson] = listCurve(features, people, logical(useEigenfaces));
    R.(['curve' tag]) = curve;
    R.(['perPerson' tag]) = perPerson;
    R.(['strangers' tag]) = strangerTest(features, people, logical(useEigenfaces));
    % the call pattern of the Yale, FEI and mask sections
    turn = repmat([0 0 1 1 2 2 3 3 4 4 5 5 0 1 2], 1, 50);
    for level = 1:5
        keep = turn == 0 | turn == level;
        if isOld
            correct = matchAll(features(:, keep), people(keep), turn(keep) == 0, logical(useEigenfaces)) == people(turn == level);
        else
            correct = matchAll(features(:, keep), people(keep), turn(keep) == 0, logical(useEigenfaces));
        end
        R.(['correct' tag]){level} = correct;
    end
end
rng(0);
if isOld, R.gallery = chooseGallery(people, 5); else, R.gallery = chooseGallery(people); end
for trial = 1:10
    printf('trial %d: curve %s strangers %s\n', trial, mat2str(mean(R.(sprintf('curve%d', trial)), 2)', 3), mat2str(R.(sprintf('strangers%d', trial)), 3));
end
if isOld, outFile = [T 'eqs_old.bin']; else, outFile = [T 'eqs_new.bin']; end
save('-binary', outFile, 'R');
printf('saved %s\n', outFile);
