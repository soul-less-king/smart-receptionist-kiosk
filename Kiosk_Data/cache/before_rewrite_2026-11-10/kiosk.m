% kiosk.m - Part 1: consent screen, face check-in, booking code, receptionist list. To start, type: kiosk. CMAI 480 Kiosk. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
function kiosk()
    findFace; recognizeFace; checkLiveness;
    tic;
    K.M = load('models.mat');
    K.today = loadTodaysList(K.M);
    fig = figure('name', 'Smart Receptionist Kiosk', 'numbertitle', 'off', 'menubar', 'none', 'toolbar', 'none', 'position', [60 40 1060 680], 'color', [0.94 0.95 0.97]);
    K.picture = image(zeros(480, 640, 3, 'uint8'), 'parent', axes('units', 'pixels', 'position', [43 225 594 445]));
    axis off;
    K.status = addText(fig, [20 180 640 36], 'Welcome. The camera stays off until you agree.', 15);
    addText(fig, [20 128 640 48], {'Your face is compared only with today''s visitors and no picture is kept after check-in.', 'You may use a booking code instead.'}, 11);
    addButton(fig, [20 82 315 40], 'I Agree - Scan My Face', @onAgree);
    addButton(fig, [345 82 315 40], 'No Thanks - Use Booking Code', @onDecline);
    addText(fig, [20 34 130 34], 'Booking code:', 12);
    K.code = uicontrol('style', 'edit', 'position', [150 34 200 36], 'fontsize', 13);
    addButton(fig, [360 34 300 36], 'Check In With Code', @onCode);
    addText(fig, [680 640 360 30], 'Receptionist: Today''s Visitors', 14);
    K.visitors = uicontrol('style', 'listbox', 'position', [680 34 360 601], 'fontsize', 12, 'fontname', 'monospace', 'max', 2);
    guidata(fig, K);
    showVisitors(K);
end

function h = addText(fig, position, words, fontSize)  % adds a text label
    h = uicontrol(fig, 'style', 'text', 'string', words, 'position', position, 'fontsize', fontSize, 'backgroundcolor', get(fig, 'color'), 'horizontalalignment', 'left');
end

function addButton(fig, position, words, action)  % adds a button that ignores extra clicks while it works
    uicontrol(fig, 'style', 'pushbutton', 'string', words, 'position', position, 'fontsize', 13, 'interruptible', 'off', 'busyaction', 'cancel', 'callback', @(src, ~) runSafely(action, src));
end

function runSafely(action, src)  % any unexpected problem shows a message instead of crashing
    try
        action(src);
    catch
        if ishghandle(src), say(guidata(src), 'Something went wrong. Please try again or use the booking code.'); end
    end
end

function say(K, words)  % shows a message to the visitor
    set(K.status, 'string', words);
    drawnow();
end

function showVisitors(K)  % refreshes the receptionist list
    set(K.visitors, 'value', [], 'string', cellfun(@(n, s) sprintf('%-16s %s', n, s), K.today.names, K.today.state, 'UniformOutput', false));
end

function frames = recordFrames(K)  % camera on only after consent: record, show the frames, then camera off
    pkg load image-acquisition;
    camera = videoinput('v4l2', '/dev/video0');
    set(camera, 'VideoResolution', [640 480]);
    start(camera, 2);
    for t = 1:45  % three seconds at 15 frames per second
        frames{t} = getsnapshot(camera);
        set(K.picture, 'cdata', frames{t});
        drawnow();
    end
    stop(camera);
    set(K.picture, 'cdata', zeros(480, 640, 3, 'uint8'));
end

function K = finishCheckIn(K, index, way)  % marks the visitor, tells the receptionist, shows how long it took
    if ~strcmp(K.today.state{index}, 'Expected'), say(K, [K.today.names{index} ' is already checked in.']); return; end
    K.today.state{index} = sprintf('Checked in by %s (%.1f s)', way, toc);
    say(K, ['Welcome, ' K.today.names{index} '. The receptionist has been told.']);
    showVisitors(K);
end

function onAgree(src)  % button: the visitor agreed, so record, find the face, check liveness and match with today's list
    K = guidata(src);
    if ~isfield(K.today, 'model'), say(K, 'Today''s list needs at least two people. Please use the booking code.'); return; end
    tic;
    say(K, 'Please look at the camera and blink normally.');
    frames = recordFrames(K);
    middle = frames{round(end / 2)};
    box = detectFace(middle, K.M);
    if isempty(box), say(K, 'No face found. Please stand in front of the camera.'); return; end
    faces = cropAllFrames(frames, box);
    if ~looksReal(lbpHistogram(faces), K.M.lbpReal, K.M.lbpFake), say(K, 'That does not look like a live face. Please use the booking code.'); return; end
    if ~blinkSeen(faces), say(K, 'No blink seen. Please try again or use the booking code.'); return; end
    [best, accepted] = matchFace(projectFaces(homomorphicFilter(cropFace(middle, box)), K.today.model), K.today.gallery, K.today.labels);
    if ~accepted, say(K, 'You are not on today''s list. Please use the booking code.'); return; end
    guidata(src, finishCheckIn(K, K.today.labels(best), 'face'));
end

function onDecline(src)  % button: the visitor said no, so the camera stays off
    tic;
    say(guidata(src), 'Please type your booking code below. The camera stays off.');
end

function onCode(src)  % button: check in with a booking code
    K = guidata(src);
    index = find(strcmp(K.today.codes, strtrim(get(K.code, 'string'))));
    set(K.code, 'string', '');
    if isempty(index), say(K, 'That code is not on today''s list. Please try again.'); return; end
    guidata(src, finishCheckIn(K, index, 'code'));
end
