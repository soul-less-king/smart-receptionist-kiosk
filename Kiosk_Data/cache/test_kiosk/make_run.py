"""Copy a kiosk code folder into a test run folder and swap the camera for stored frames.

usage: python3 -I make_run.py <code folder> <run folder>
"""
import re, shutil, sys, pathlib

code, run = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
fixture = pathlib.Path(__file__).parent / 'fixture'
if run.exists():
    shutil.rmtree(run)
run.mkdir(parents=True)
for f in ['kiosk.m', 'findFace.m', 'recognizeFace.m', 'checkLiveness.m', 'models.mat']:
    shutil.copy(code / f, run / f)
shutil.copytree(fixture / 'today', run / 'today')

kiosk = (run / 'kiosk.m').read_text()
# the camera function is the one that calls videoinput; replace its whole body
pattern = re.compile(r'(function frames = (\w+)\((\w+)\)[^\n]*\n)(?:(?!\nfunction ).)*?videoinput.*?\nend\n', re.S)
match = pattern.search(kiosk)
if not match:
    sys.exit('camera function not found')
stub = match.group(1) + '    global TEST_FRAMES\n    if ischar(TEST_FRAMES), error(\'test: camera missing\'); end\n    frames = TEST_FRAMES;\nend\n'
(run / 'kiosk.m').write_text(kiosk[:match.start()] + stub + kiosk[match.end():])
print('camera function replaced:', match.group(2))
