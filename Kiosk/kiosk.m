% kiosk.m - Part 1 of the kiosk: the screen. It asks for consent, checks the visitor in by face or by booking code and updates the receptionist's list. To start, type: kiosk   (today's photos go in today/Name_Code/*.jpg). CMAI 480 Computer Vision, Fall 2026. Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
function kiosk()
    findFace;                                                         % load Part 2
    recognizeFace;                                                    % load Part 3
    checkLiveness;                                                    % load Part 4
    app.models = load('models.mat');                                  % the face template and the texture averages, made by experiments.m
    app.today = loadTodaysList(app.models.faceTemplate);
    window = figure('name', 'Smart Receptionist Kiosk', 'numbertitle', 'off', 'menubar', 'none', 'toolbar', 'none', 'position', [60 40 1060 680], 'color', [0.94 0.95 0.97]);
    app.cameraView = imshow(zeros(480, 640, 3, 'uint8'), 'parent', axes('units', 'pixels', 'position', [43 225 594 445]));
    app.message = addText(window, [20 180 640 36], '', 15);
    addText(window, [20 128 640 48], {'Your face is compared only with today''s visitors and no picture is kept after check-in.', 'You may use a booking code instead.'}, 11);
    addButton(window, [20 82 315 40], 'I Agree - Scan My Face', @onAgree);
    addButton(window, [345 82 315 40], 'No Thanks - Use Booking Code', @(app) updateScreen(app, 'Please type your booking code below. The camera stays off.'));
    addText(window, [20 34 130 34], 'Booking code:', 12);
    app.codeBox = uicontrol('style', 'edit', 'position', [150 34 200 36], 'fontsize', 13);
    addButton(window, [360 34 300 36], 'Check In With Code', @onCode);
    addText(window, [680 640 360 30], 'Receptionist: Today''s Visitors', 14);
    app.visitorList = uicontrol('style', 'listbox', 'position', [680 34 360 601], 'fontsize', 12, 'fontname', 'monospace', 'max', 2);
    updateScreen(app, 'Welcome. The camera stays off until you agree.');
    guidata(window, app);
end

function app = onAgree(app)  % button: the visitor agreed, so record, find the face, check it is alive and compare it with today's list
    stopIf(~isfield(app.today, 'model'), 'Today''s list needs at least two people. Please use the booking code.');
    tic;
    updateScreen(app, 'Please look at the camera and blink normally.');
    frames = recordFrames(app);
    middleFrame = frames{round(end / 2)};
    box = detectFace(middleFrame, app.models.faceTemplate);
    stopIf(isempty(box), 'No face found. Please stand in front of the camera.');
    faces = cropAllFrames(frames, box);
    stopIf(~looksReal(lbpHistogram(faces), app.models.lbpReal, app.models.lbpFake), 'That does not look like a live face. Please use the booking code.');
    stopIf(~blinkSeen(faces), 'No blink seen. Please try again or use the booking code.');
    [closest, accepted] = matchFace(projectFaces(homomorphicFilter(cropFace(middleFrame, box)), app.today.model), app.today.photoWeights, app.today.photoOwners);   % cut out the face, correct its light, turn it into eigenface weights, find the nearest photo
    stopIf(~accepted, 'You are not on today''s list. Please use the booking code.');
    app = checkIn(app, app.today.photoOwners(closest), sprintf('face (%.1f s)', toc));
end

function app = onCode(app)  % button: check in with a booking code
    person = find(strcmp(app.today.codes, strtrim(get(app.codeBox, 'string'))));
    set(app.codeBox, 'string', '');
    stopIf(isempty(person), 'That code is not on today''s list. Please try again.');
    app = checkIn(app, person, 'code');
end

function app = checkIn(app, person, way)  % marks the visitor as checked in and tells the receptionist
    stopIf(~strcmp(app.today.status{person}, 'Expected'), [app.today.names{person} ' is already checked in.']);
    app.today.status{person} = ['Checked in by ' way];
    updateScreen(app, ['Welcome, ' app.today.names{person} '. The receptionist has been told.']);
end

function frames = recordFrames(app)  % the camera turns on only after consent: 45 frames (about 3 seconds) are recorded and shown, then it turns off
    pkg load image-acquisition;
    camera = videoinput('v4l2', '/dev/video0', [640 480]);
    start(camera, 2);
    for frame = 1:45
        frames{frame} = getsnapshot(camera);
        set(app.cameraView, 'cdata', frames{frame});
        drawnow();
    end
    stop(camera);
    set(app.cameraView, 'cdata', zeros(480, 640, 3, 'uint8'));       % the screen goes black again and no frame is kept
end

function stopIf(condition, message)  % stops the check-in and shows the visitor why
    if condition
        error('kiosk:stop', '%s', message);
    end
end

function runSafely(action, button)  % runs a button's action and keeps its result; a stop or an unexpected problem shows a message instead of crashing
    try
        guidata(button, action(guidata(button)));
    catch problem
        if strcmp(problem.identifier, 'kiosk:stop')
            updateScreen(guidata(button), problem.message);
        elseif ishghandle(button)
            updateScreen(guidata(button), 'Something went wrong. Please try again or use the booking code.');
        end
    end
end

function app = updateScreen(app, message)  % shows a message to the visitor and refreshes the receptionist's list: each visitor's name, then their status
    set(app.message, 'string', message);
    set(app.visitorList, 'value', [], 'string', cellfun(@(name, status) sprintf('%-16s %s', name, status), app.today.names, app.today.status, 'UniformOutput', false));
end

function label = addText(window, position, words, fontSize)  % adds a text label
    label = uicontrol(window, 'style', 'text', 'string', words, 'position', position, 'fontsize', fontSize, 'backgroundcolor', get(window, 'color'), 'horizontalalignment', 'left');
end

function addButton(window, position, words, action)  % adds a button; extra clicks while it is busy are ignored
    uicontrol(window, 'style', 'pushbutton', 'string', words, 'position', position, 'fontsize', 13, 'interruptible', 'off', 'busyaction', 'cancel', 'callback', @(button, ~) runSafely(action, button));
end
