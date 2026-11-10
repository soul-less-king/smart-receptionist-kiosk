% click_through.m - drives the kiosk window like a visitor would and prints what is shown.
% Run from inside a run folder made by make_run.py. The window stays hidden.
1;
global TEST_FRAMES
DATA = '/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/liveness_frames/';

function frames = clip(folder, first)
    files = dir([folder '*.jpg']);
    frames = arrayfun(@(f) imread([folder f.name]), files(first:first + 44), 'UniformOutput', false);
end

function press(words)
    h = findall(0, 'style', 'pushbutton', 'string', words);
    callback = get(h, 'callback');
    callback(h, []);
end

function show(step)
    message = findall(0, 'style', 'text', 'fontsize', 15);
    list = get(findall(0, 'style', 'listbox'), 'string');
    list = regexprep(list, '\(\d+\.\d s\)', '(time)');
    printf('%-34s | %s\n', step, get(message, 'string'));
    printf('%-34s   list: %s\n', '', strjoin(cellstr(list)', ' / '));
end

function typeCode(words)
    set(findall(0, 'style', 'edit'), 'string', words);
end

set(0, 'defaultfigurevisible', 'off');
lastwarn('');
kiosk;
show('start');
typeCode(''); press('Check In With Code'); show('empty code');
typeCode('9999'); press('Check In With Code'); show('wrong code 9999');
typeCode(' 1001 '); press('Check In With Code'); show('code 1001 with spaces, no consent');
typeCode('1001'); press('Check In With Code'); show('code 1001 again');
press('No Thanks - Use Booking Code'); show('decline');
typeCode('1002'); press('Check In With Code'); show('code 1002 after decline');
TEST_FRAMES = clip([DATA 'real/03/'], 31); press('I Agree - Scan My Face'); show('agree, real person on the list');
press('I Agree - Scan My Face'); show('agree again, same person');
TEST_FRAMES = clip([DATA 'print/01/'], 1); press('I Agree - Scan My Face'); show('agree, printed photo');
TEST_FRAMES = clip([DATA 'phone/01/'], 1); TEST_FRAMES = cellfun(@(f) imresize(f, 1 / 3), TEST_FRAMES, 'UniformOutput', false); press('I Agree - Scan My Face'); show('agree, phone replay');
TEST_FRAMES = clip([DATA 'real/01/'], 1); press('I Agree - Scan My Face'); show('agree, real person not on list');
TEST_FRAMES = repmat({zeros(480, 640, 3, 'uint8')}, 1, 45); press('I Agree - Scan My Face'); show('agree, empty scene');
TEST_FRAMES = 'error'; press('I Agree - Scan My Face'); show('agree, camera missing');
[w, id] = lastwarn();
printf('last warning: [%s] [%s]\n', w, id);
close all force;
