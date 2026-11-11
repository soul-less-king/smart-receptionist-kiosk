% clock_test.m - shows the real check-in times, to confirm that each visitor gets their own clock.
1;
global TEST_FRAMES
DATA = '/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/liveness_frames/';

function press(words)
    h = findall(0, 'style', 'pushbutton', 'string', words);
    callback = get(h, 'callback');
    callback(h, []);
end

function showList(step)
    printf('%-44s %s\n', step, strjoin(cellstr(get(findall(0, 'style', 'listbox'), 'string'))', ' / '));
end

set(0, 'defaultfigurevisible', 'off');
kiosk;
pause(3);
set(findall(0, 'style', 'edit'), 'string', '1001'); press('Check In With Code'); showList('code typed 3 s after start, no No Thanks:');
press('No Thanks - Use Booking Code'); pause(2);
set(findall(0, 'style', 'edit'), 'string', '1002'); press('Check In With Code'); showList('No Thanks, 2 s of typing, code:');
files = dir([DATA 'real/03/*.jpg']);
TEST_FRAMES = arrayfun(@(f) imread([DATA 'real/03/' f.name]), files(31:75), 'UniformOutput', false);
pause(2); press('I Agree - Scan My Face'); showList('I Agree after 2 s idle:');
close all force;
