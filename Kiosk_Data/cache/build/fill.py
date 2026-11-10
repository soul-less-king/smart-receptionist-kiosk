import re, sys, json, os
log = open(sys.argv[1]).read()
tpl = open(sys.argv[2]).read()
out = sys.argv[3]
R = {}
for m in re.finditer(r"^(\w+) =\n\n((?:[ \t]*[-\d.e+]+(?:[ \t]+[-\d.e+]+)*\n)+)", log, re.M):
    R[m[1]] = [[float(x) for x in line.split()] for line in m[2].strip().split('\n')]
need = ['detection', 'listAccuracy', 'listSpread', 'strangersEigenfaces', 'strangersVgg', 'lighting', 'headTurn', 'glasses', 'maskAndBacklight', 'liveness', 'stepSeconds']
missing = [k for k in need if k not in R]
if missing: sys.exit(f'missing in log: {missing}')
V = {}
def pct(x, d=1): return f"{100*float(x):.{d}f}"
V['detHit'] = pct(R['detection'][0][0]); V['detIoU'] = f"{R['detection'][0][1]:.2f}"
sizes = [5, 10, 20, 30, 40, 50]
for c, key in enumerate(['eig', 'vgg']):
    pts = []
    for r, s in enumerate(sizes):
        V[f'{key}{s}'] = pct(R['listAccuracy'][r][c])
        pts.append(f"({s},{100*R['listAccuracy'][r][c]:.1f}) +- (0,{100*R['listSpread'][r][c]:.1f})")
    V[f'plot_{key}'] = ' '.join(pts)
for key, name in [('eig', 'strangersEigenfaces'), ('vgg', 'strangersVgg')]:
    a = R[name][0]
    V[key+'Prec'] = f"{a[0]:.2f}"; V[key+'Rec'] = f"{a[1]:.2f}"; V[key+'F1'] = f"{a[2]:.2f}"; V[key+'Str'] = pct(a[3])
L = R['lighting']
V['noneMod'], V['noneHarsh'], V['homMod'], V['homHarsh'] = [pct(x) for x in L[0] + L[1]]
for key, row in zip(['eigT', 'vggT'], R['headTurn']):
    for i, v in enumerate(row, 1): V[f'{key}{i}'] = pct(v, 0)
    V[f'plot_{key}'] = ' '.join(f"({i},{100*v:.1f})" for i, v in enumerate(row, 1))
V['eigGl'], V['eigNoGl'], V['vggGl'], V['vggNoGl'] = [pct(x, 0) for x in R['glasses'][0]]
B = R['maskAndBacklight']
V['eigMask'], V['eigBack'], V['vggMask'], V['vggBack'] = [pct(x, 0) for x in B[0] + B[1]]
for key, row in zip(['Real', 'Print', 'Cut', 'Monitor', 'Phone'], R['liveness']):
    V[f'live{key}Tex'], V[f'live{key}Bl'], V[f'live{key}Both'] = [pct(x, 0) for x in row]
V['cutStop'] = f"{100 - int(V['liveCutBoth'])}"
T = [row[0] for row in R['stepSeconds']]
V['spFind'], V['spCrop'], V['spTex'], V['spBlink'], V['spHom'] = [f"{x:.3f}" for x in T[:5]]  # experiments.m prints: find, crop, texture, blink, homomorphic, train, match, code
V['spMatch'] = f"{T[6]:.3f}"
V['detSec'] = f"{T[0]:.2f}"
V['spTrain'] = f"{T[5]:.3f}"
V['spCode'] = f"{T[7] * 1000:.3f}"
total = sum(T[:5]) + T[6]
V['spTotal'] = f"{total:.2f}"
record = float(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'record_seconds.txt')).read())
V['spRecord'] = f"{record:.2f}"
V['faceTotal'] = f"{record + total:.1f}"
for k, v in V.items(): tpl = tpl.replace(f"@@{k}@@", v)
json.dump(V, open(os.path.join(os.path.dirname(out) or '.', 'numbers.json'), 'w'), indent=1)
left = sorted(set(re.findall(r"@@(\w+)@@", tpl)))
open(out, 'w').write(tpl)
print('filled', len(V), 'values; unresolved:', left)
for k in ['detHit','detIoU','eig5','eig50','vgg5','vgg50','eigPrec','eigRec','eigF1','eigStr','vggPrec','vggRec','vggF1','vggStr','noneHarsh','homHarsh','livePrintBoth','liveCutBoth','liveMonitorBoth','livePhoneBoth','liveRealBoth','spTotal','faceTotal','eigMask','vggMask','eigBack','vggBack','eigT1','eigT5','vggT4','vggT5','eigGl','eigNoGl']:
    print(f'  {k} = {V[k]}')
