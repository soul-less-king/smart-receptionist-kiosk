% kiosk.m - Part 1: the screen: consent, face check-in, booking code, receptionist list.
% Consent-Based Smart Receptionist Kiosk, CMAI 480, Qatar University.
% Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
function kiosk()
    findFace; recognizeFace; checkLiveness;
    K.S = settings();
    K.M = load('models.mat');
    K.net = load('vgg_conv.mat');
    K.today = loadTodaysList(K.S);
    K.started = 0;
    K.fig = figure('name', 'Consent-Based Smart Receptionist Kiosk | CMAI 480 | Alsheikh, Al-Thani, Sleiman, Alshiss, Khan', ...
        'numbertitle', 'off', 'menubar', 'none', 'toolbar', 'none', 'position', [60 40 1060 680], 'color', [0.94 0.95 0.97]);
    K.view = axes('parent', K.fig, 'units', 'pixels', 'position', [20 225 640 445]);
    K.picture = image(zeros(480, 640, 3, 'uint8'), 'parent', K.view);
    axis(K.view, 'off');
    K.status = addText(K.fig, [20 180 640 36], 'Welcome. The camera stays off until you agree.', 15);
    addText(K.fig, [20 128 640 48], {'Your face is compared only with today''s visitors and no picture is kept after check-in.', 'You may use a booking code instead.'}, 11);
    addButton(K.fig, [20 82 315 40], 'I Agree - Scan My Face', @onAgree);
    addButton(K.fig, [345 82 315 40], 'No Thanks - Use Booking Code', @onDecline);
    addText(K.fig, [20 34 130 34], 'Booking code:', 12);
    K.code = uicontrol(K.fig, 'style', 'edit', 'position', [150 34 200 36], 'fontsize', 13);
    addButton(K.fig, [360 34 300 36], 'Check In With Code', @onCode);
    addText(K.fig, [680 640 360 30], 'Receptionist: Today''s Visitors', 14);
    K.visitors = uicontrol(K.fig, 'style', 'listbox', 'position', [680 225 360 410], 'fontsize', 12);
    addText(K.fig, [680 180 360 30], 'Enroll a visitor who agreed:', 12);
    K.name = uicontrol(K.fig, 'style', 'edit', 'position', [680 138 360 36], 'fontsize', 13);
    addButton(K.fig, [680 82 360 40], 'Enroll From Camera', @onEnroll);
    K.times = addText(K.fig, [680 34 360 36], 'Last check-in time: -', 12);
    guidata(K.fig, K);
    showVisitors(K);
end

% Adds a text label to the window.
function h = addText(fig, position, words, fontSize)
    h = uicontrol(fig, 'style', 'text', 'string', words, 'position', position, 'fontsize', fontSize, ...
        'backgroundcolor', get(fig, 'color'), 'horizontalalignment', 'left');
end

% Adds a button that ignores extra clicks while it is working.
function addButton(fig, position, words, action)
    uicontrol(fig, 'style', 'pushbutton', 'string', words, 'position', position, 'fontsize', 13, ...
        'interruptible', 'off', 'busyaction', 'cancel', 'callback', @(src, ~) runSafely(action, src));
end

% Any unexpected problem shows a message instead of crashing the kiosk.
function runSafely(action, src)
    try
        action(src);
    catch
        if ishghandle(src)
            say(guidata(src), 'Something went wrong. Please try again or use the booking code.');
        end
    end
end

% Shows a message to the visitor.
function say(K, words)
    set(K.status, 'string', words);
    drawnow();
end

% Refreshes the receptionist list.
function showVisitors(K)
    rows = cell(numel(K.today.names), 1);
    for i = 1:numel(rows)
        rows{i} = sprintf('%-22s %s', K.today.names{i}, K.today.state{i});
    end
    set(K.visitors, 'string', rows, 'value', 1);
    drawnow();
end

% Turns the camera on after consent, records frames, and turns it off again.
function frames = recordFrames(K, count)
    pkg load image-acquisition;
    camera = videoinput('v4l2', '/dev/video0');
    set(camera, 'VideoResolution', [640 480]);
    start(camera, 2);
    frames = cell(count, 1);
    for t = 1:count
        frames{t} = getsnapshot(camera);
        set(K.picture, 'cdata', frames{t});
        drawnow();
    end
    stop(camera);
    set(K.picture, 'cdata', zeros(480, 640, 3, 'uint8'));
end

% The full face check: find, lock, liveness, then match against today's list.
function [index, message] = checkInByFace(frames, K)
    index = 0;
    S = K.S;
    gray = cellfun(@(f) im2double(rgb2gray(f)), frames, 'UniformOutput', false);
    middle = round(numel(frames) / 2);
    box = detectFace(frames{middle}, K.net, S);
    if isempty(box)
        message = 'No face found. Please stand in front of the camera.';
        return;
    end
    faces = cropAllFrames(gray, box, S);
    if textureScore(faces, K.M) <= S.textureLimit
        message = 'That does not look like a live face. Please use the booking code.';
    elseif blinkScore(faces, S) <= S.blinkLimit
        message = 'No blink seen. Please try again or use the booking code.';
    else
        weights = projectFaces(faceVector(cropFace(gray{middle}, box, S.faceSize), S), K.today.model);
        [best, ratio] = matchFace(weights, K.today.gallery, K.today.labels);
        if ratio > S.matchRatio
            message = 'You are not on today''s list. Please use the booking code.';
        else
            index = K.today.labels(best);
            message = '';
        end
    end
end

% Marks the visitor as checked in, tells the receptionist and logs the time.
function K = completeCheckIn(K, index, way)
    if strcmp(K.today.state{index}, 'Expected')
        K.today.state{index} = ['Checked in (' way ')'];
        seconds = toc(K.started);
        set(K.times, 'string', sprintf('Last check-in time: %.1f s by %s', seconds, way));
        say(K, ['Welcome, ' K.today.names{index} '. The receptionist has been told.']);
        file = fopen('checkins.csv', 'a');
        fprintf(file, '%s,%s,%s,%.2f\n', datestr(now), K.today.names{index}, way, seconds);
        fclose(file);
        showVisitors(K);
    else
        say(K, [K.today.names{index} ' is already checked in.']);
    end
end

% Button: the visitor agreed to use their face.
function onAgree(src)
    K = guidata(src);
    if numel(K.today.names) < 2
        say(K, 'Please enroll at least two visitors first.');
        return;
    end
    K.started = tic;
    say(K, 'Please look at the camera and blink normally.');
    [index, message] = checkInByFace(recordFrames(K, K.S.captureFrames), K);
    if index > 0
        K = completeCheckIn(K, index, 'face');
    else
        say(K, message);
    end
    guidata(src, K);
end

% Button: the visitor said no, so the camera stays off.
function onDecline(src)
    K = guidata(src);
    K.started = tic;
    say(K, 'Please type your booking code below. The camera stays off.');
    guidata(src, K);
end

% Button: check in with a booking code.
function onCode(src)
    K = guidata(src);
    if K.started == 0
        K.started = tic;
    end
    index = find(strcmp(K.today.codes, strtrim(get(K.code, 'string'))));
    set(K.code, 'string', '');
    if isempty(index)
        say(K, 'That code is not on today''s list. Please try again.');
    else
        K = completeCheckIn(K, index, 'code');
    end
    guidata(src, K);
end

% Button: the receptionist enrolls a visitor who agreed.
function onEnroll(src)
    K = guidata(src);
    name = strtrim(get(K.name, 'string'));
    if isempty(name) || any(name == '_') || any(strcmp(K.today.names, name))
        say(K, 'Please type a new visitor name, without underscores.');
        return;
    end
    say(K, 'Enrolling: please look at the camera.');
    frames = recordFrames(K, K.S.enrollFrames);
    box = detectFace(frames{end}, K.net, K.S);
    if isempty(box)
        say(K, 'No face found. Please try again.');
        return;
    end
    code = sprintf('%04d', randi([1000 9999]));
    folder = ['today/' name '_' code];
    mkdir(folder);
    for t = 1:numel(frames)
        imwrite(cropFace(im2double(rgb2gray(frames{t})), box, K.S.faceSize), sprintf('%s/%02d.png', folder, t));
    end
    K.today = loadTodaysList(K.S);
    set(K.name, 'string', '');
    say(K, sprintf('%s enrolled. Booking code: %s', name, code));
    showVisitors(K);
    guidata(src, K);
end
