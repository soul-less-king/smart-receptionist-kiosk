const path = require('path');
const pptxgen = require('pptxgenjs');
const SKILL = '/home/userstorexxx-gmail-com/.config/Claude/local-agent-mode-sessions/skills-plugin/92aeccd8-54c9-462f-b856-bec5ae1bd9e7/496ac194-b970-41c1-91cd-eb712f0f1b09/skills/pptx';
const { applyTheme } = require(SKILL + '/scripts/apply_theme.js');
const V = require(process.argv[2]);
const OUT = process.argv[3];

const THEME = {
  name: 'Kiosk', headFontFace: 'Cambria', bodyFontFace: 'Calibri',
  colors: { dk1: '12232E', lt1: 'FFFFFF', dk2: '0B3C49', lt2: 'E6F2F0', accent1: '1C7C7D', accent2: 'E4572E', accent3: '5DD39E', accent4: 'F2B134', accent5: '6C8EAD', accent6: '8A9BA8', hlink: '1C7C7D', folHlink: '6C8EAD' },
};
const HEX = THEME.colors;

(async () => {
  const pres = new pptxgen();
  pres.layout = 'LAYOUT_WIDE';
  pres.title = 'Consent-Based Smart Receptionist Kiosk';
  pres.author = 'CMAI 480 Team';
  pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
  const C = pres.SchemeColor;

  pres.defineSlideMaster({
    title: 'DARK', background: { color: C.text2 },
    objects: [
      { placeholder: { options: { name: 'title', type: 'title', x: 0.8, y: 2.0, w: 11.7, h: 1.9, fontSize: 44, bold: true, color: C.background1, align: 'left', valign: 'bottom', margin: 0 }, text: '' } },
      { placeholder: { options: { name: 'sub', type: 'body', x: 0.8, y: 4.1, w: 11.7, h: 2.2, fontSize: 18, color: C.background2, align: 'left', valign: 'top', margin: 0 }, text: '' } },
    ],
  });
  pres.defineSlideMaster({
    title: 'CONTENT', background: { color: C.background1 },
    slideNumber: { x: 12.3, y: 7.0, w: 0.6, h: 0.3, fontSize: 11, color: C.accent6, align: 'right' },
    objects: [
      { placeholder: { options: { name: 'title', type: 'title', x: 0.6, y: 0.35, w: 12.1, h: 0.95, fontSize: 36, bold: true, color: C.text2, align: 'left', valign: 'middle', margin: 0 }, text: '' } },
    ],
  });

  const section = (t) => pres.addSection({ title: t });
  const add = (master, sectionTitle, title, notes) => {
    const s = pres.addSlide({ masterName: master, sectionTitle });
    s.addText(title, { placeholder: 'title' });
    if (notes) s.addNotes(notes);
    return s;
  };
  const circle = (s, x, y, label, fill) => {
    s.addText(String(label), { shape: pres.ShapeType.ellipse, x, y, w: 0.56, h: 0.56, fill: { color: fill || C.accent1 }, color: C.background1, fontSize: 18, bold: true, align: 'center', valign: 'middle', margin: 0, isTextBox: true, objectName: 'Number ' + label });
  };
  const card = (s, x, y, w, h, name) => {
    s.addShape(pres.ShapeType.roundRect, { x, y, w, h, rectRadius: 0.08, fill: { color: C.background2 }, line: { color: C.background2 }, objectName: name || 'Card' });
  };

  section('Opening');
  let s = add('DARK', 'Opening', 'Consent-Based Smart Receptionist Kiosk', 'Good afternoon. We are presenting a kiosk that checks visitors in by face, only with their permission, and always offers a booking code instead.');
  s.addText([
    { text: 'CMAI 480 Computer Vision, Dr. Khalil Ahmad Yousef, Fall 2026', options: { breakLine: true } },
    { text: 'Abdulrahman Alsheikh, Fahad Al-Thani, Hadi Sleiman,', options: { breakLine: true } },
    { text: 'Islam Alshiss, Hashir Khan' },
  ], { placeholder: 'sub' });

  s = add('CONTENT', 'Opening', 'Who did what: one part per person', 'Each of us owns one part of the code and can explain and change it. All of us can explain the whole system.');
  const rows = [
    [{ text: 'Part', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }, { text: 'What it does', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }, { text: 'File', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }, { text: 'Owner', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }],
    ['1', 'Consent screen, booking code, receptionist list', 'kiosk.m', 'Hadi Sleiman (leader)'],
    ['2', 'Finds the face with a gradient-histogram template, cuts it out', 'findFace.m', 'Islam Alshiss'],
    ['3', 'Homomorphic light correction, Eigenfaces from the equations', 'recognizeFace.m', 'Hashir Khan'],
    ['4', 'Liveness: LBP texture check and blink check', 'checkLiveness.m', 'Fahad Al-Thani'],
    ['5', 'All experiments, the ready-made competitor, report results', 'experiments.m', 'Abdulrahman Alsheikh'],
  ];
  s.addTable(rows, { x: 0.6, y: 1.55, w: 12.1, colW: [0.8, 6.3, 2.3, 2.7], fontSize: 16, color: C.text1, rowH: 0.72, border: { type: 'solid', pt: 1, color: C.background2 }, valign: 'middle', fontFace: '+mn-lt', objectName: 'Contribution table' });

  section('Problem');
  s = add('CONTENT', 'Problem', 'The problem: checking visitors in by hand', 'Reception staff check every name by hand. It is slow when people arrive together, repetitive, and visitors say their names aloud in a full waiting room.');
  const prob = [['Slow', 'One person at a time, while others wait in line'], ['Repetitive', 'The same list check repeated all day by staff'], ['Not private', 'Visitors must say their name aloud in the waiting room']];
  prob.forEach((p, i) => {
    const y = 1.7 + i * 1.45;
    card(s, 0.6, y, 7.3, 1.2, 'Problem card');
    circle(s, 0.85, y + 0.32, i + 1);
    s.addText(p[0], { x: 1.65, y: y + 0.14, w: 6, h: 0.45, fontSize: 22, bold: true, color: C.text2, margin: 0, isTextBox: true, objectName: 'Problem title' });
    s.addText(p[1], { x: 1.65, y: y + 0.6, w: 6.1, h: 0.45, fontSize: 16, color: C.text1, margin: 0, isTextBox: true, objectName: 'Problem text' });
  });
  s.addText('10 to 50', { x: 8.4, y: 2.1, w: 4.3, h: 1.3, fontSize: 66, bold: true, color: C.accent1, margin: 0, align: 'center', isTextBox: true, objectName: 'Stat' });
  s.addText('people on a typical daily list, so we only ever compare a face with today\'s list', { x: 8.4, y: 3.5, w: 4.3, h: 1.3, fontSize: 18, color: C.text1, margin: 0, align: 'center', isTextBox: true, objectName: 'Stat caption' });

  s = add('CONTENT', 'Problem', 'The gap in existing approaches', 'Existing systems either need heavy tools, are hard to explain, or rely on a single cue. And most make the face the only way in.');
  const gapHead = (t) => ({ text: t, options: { bold: true, color: C.background1, fill: { color: C.accent1 } } });
  s.addTable([
    [gapHead('Existing approach'), gapHead('Where it falls short'), gapHead('What we do instead')],
    ['Manual reception desk', 'Slow, repetitive, not private', 'Automatic check-in in seconds'],
    ['Face-only kiosks', 'Exclude visitors who refuse or wear face coverings', 'Equal booking-code path'],
    ['Deep models (YOLO, ArcFace)', 'Accurate but need Python and GPU; hard to explain', 'Our own Eigenfaces in Octave, deep model only as competitor'],
    ['Single-cue liveness', 'One cue alone is easy to fool', 'Texture and blink must both pass'],
  ], { x: 0.6, y: 1.6, w: 12.1, colW: [3.4, 4.5, 4.2], fontSize: 16, color: C.text1, rowH: 0.9, border: { type: 'solid', pt: 1, color: C.background2 }, valign: 'middle', fontFace: '+mn-lt', objectName: 'Gap table' });

  section('Solution');
  s = add('CONTENT', 'Solution', 'Our solution: four ideas', 'First consent, then a second equal way in, then today\'s list only, and finally our own method measured against a ready-made one. The doctor\'s two suggestions are built in.');
  const ideas = [
    ['Consent first', 'Camera stays off until the visitor agrees; no picture is kept'],
    ['Two equal paths', 'A booking code works for anyone who declines or cannot be recognized'],
    ['Only today\'s list', 'We never search a big database, and we measure lists from 5 to 50 people'],
    ['Doctor\'s additions', 'Homomorphic light correction, LBP texture plus blink, ready-made model as competitor'],
  ];
  ideas.forEach((p, i) => {
    const x = 0.6 + (i % 2) * 6.2, y = 1.6 + Math.floor(i / 2) * 2.5;
    card(s, x, y, 5.9, 2.2, 'Idea card');
    circle(s, x + 0.25, y + 0.25, i + 1, i === 3 ? C.accent2 : C.accent1);
    s.addText(p[0], { x: x + 1.0, y: y + 0.25, w: 4.7, h: 0.55, fontSize: 22, bold: true, color: C.text2, margin: 0, isTextBox: true, objectName: 'Idea title' });
    s.addText(p[1], { x: x + 0.3, y: y + 1.0, w: 5.3, h: 1.0, fontSize: 16, color: C.text1, margin: 0, isTextBox: true, objectName: 'Idea text' });
  });

  section('Method');
  s = add('CONTENT', 'Method', 'How it works: the pipeline', 'After consent the kiosk records three seconds, finds the face, checks liveness, corrects the light, and matches against today\'s list. Any failure goes to the booking code.');
  const steps = ['Consent', 'Record 3 s', 'Find face', 'Liveness', 'Fix light', 'Eigenfaces', 'Check in'];
  const bw = 1.55, gap = 0.2, x0 = 0.6, y0 = 2.0;
  steps.forEach((t, i) => {
    const x = x0 + i * (bw + gap);
    s.addText(t, { shape: pres.ShapeType.roundRect, rectRadius: 0.08, x, y: y0, w: bw, h: 1.0, fill: { color: i === 6 ? C.accent2 : C.accent1 }, color: C.background1, fontSize: 16, bold: true, align: 'center', valign: 'middle', margin: 0.03, isTextBox: true, objectName: 'Step ' + t });
    if (i < 6) s.addShape(pres.ShapeType.line, { x: x + bw, y: y0 + 0.5, w: gap, h: 0, line: { color: C.accent6, width: 2, endArrowType: 'triangle' }, objectName: 'Arrow' });
  });
  s.addText('Booking code', { shape: pres.ShapeType.roundRect, rectRadius: 0.08, x: 5.0, y: 4.0, w: 3.3, h: 0.9, fill: { color: C.background2 }, color: C.text2, fontSize: 18, bold: true, align: 'center', valign: 'middle', margin: 0, isTextBox: true, objectName: 'Booking code' });
  s.addText('Declines, or any step fails', { x: 0.6, y: 4.2, w: 4.2, h: 0.5, fontSize: 16, color: C.text1, margin: 0, align: 'right', isTextBox: true, objectName: 'Failure label' });
  s.addText('Receptionist list updates either way', { x: 8.5, y: 4.2, w: 4.2, h: 0.5, fontSize: 16, color: C.text1, margin: 0, isTextBox: true, objectName: 'Result label' });
  s.addText('Everything runs in GNU Octave on the webcam, one visitor at a time, with no cloud.', { x: 0.6, y: 5.6, w: 12.1, h: 0.5, fontSize: 18, italic: true, color: C.accent1, margin: 0, align: 'center', isTextBox: true, objectName: 'Note' });

  s = add('CONTENT', 'Method', 'Inside each step, from the course', 'Every step uses material from the course. Eigenfaces come from the eigenspace slide and Assignment 1. The homomorphic filter and the dual-feature liveness are the doctor\'s suggestions.');
  const parts = [
    ['Find the face', 'Orientation histograms in cells; template slid over a pyramid; strongest match wins', 'Assignment 2, Feature Extraction Parts 2 and 3, Lecture 8'],
    ['Fix the light', 'log image, Gaussian low-pass, shrink light, boost detail', 'Ch. 3 + doctor\'s comment'],
    ['Eigenfaces', 'eig of A\'A from the equations; nearest face plus ratio test', 'Linear Algebra, Assignments 1, 3'],
    ['Liveness', 'LBP texture compared with real and fake; blink from eye vs lower face', 'Ch. 3, NCC + doctor\'s comment'],
  ];
  parts.forEach((p, i) => {
    const x = 0.6 + (i % 2) * 6.2, y = 1.6 + Math.floor(i / 2) * 2.5;
    card(s, x, y, 5.9, 2.2, 'Method card');
    circle(s, x + 0.25, y + 0.25, i + 1);
    s.addText(p[0], { x: x + 1.0, y: y + 0.25, w: 4.7, h: 0.55, fontSize: 22, bold: true, color: C.text2, margin: 0, isTextBox: true, objectName: 'Method title' });
    s.addText(p[1], { x: x + 0.3, y: y + 0.95, w: 5.3, h: 0.75, fontSize: 16, color: C.text1, margin: 0, isTextBox: true, objectName: 'Method text' });
    s.addText(p[2], { x: x + 0.3, y: y + 1.7, w: 5.3, h: 0.35, fontSize: 12, italic: true, color: C.accent1, margin: 0, isTextBox: true, objectName: 'Method source' });
  });

  section('Results');
  s = add('CONTENT', 'Results', 'Results: simple works only on short lists', `Eigenfaces reach ${V.eig5} percent for 5 people and ${V.eig50} for 50, while VGG-Face stays near ${V.vgg50}. The homomorphic filter lifts harsh light from ${V.noneHarsh} to ${V.homHarsh} percent. Liveness stops prints; screens are hardest. Finding the face works ${V.detHit} percent of the time.`);
  const chartBase = () => ({ catAxisLabelFontFace: '+mn-lt', valAxisLabelFontFace: '+mn-lt', catAxisLabelFontSize: 12, valAxisLabelFontSize: 12, catAxisLabelColor: HEX.dk1, valAxisLabelColor: HEX.dk1, valGridLine: { color: 'E1E7EA', size: 1 }, catGridLine: { style: 'none' }, showTitle: true, titleFontFace: '+mn-lt', titleFontSize: 14, titleColor: HEX.dk2, valAxisMinVal: 0, valAxisMaxVal: 100, legendFontFace: '+mn-lt', legendFontSize: 12, legendColor: HEX.dk1 });
  const num = (k) => parseFloat(V[k]);
  s.addChart(pres.charts.LINE, [
    { name: 'Eigenfaces (ours)', labels: ['5', '10', '20', '30', '40', '50'], values: [5, 10, 20, 30, 40, 50].map((n) => num('eig' + n)) },
    { name: 'VGG-Face (competitor)', labels: ['5', '10', '20', '30', '40', '50'], values: [5, 10, 20, 30, 40, 50].map((n) => num('vgg' + n)) },
  ], Object.assign(chartBase(), { x: 0.6, y: 1.45, w: 6.1, h: 3.95, title: 'Accuracy (%) as today\'s list grows', chartColors: [HEX.accent1, HEX.accent2], lineSize: 3, lineDataSymbolSize: 8, showLegend: true, legendPos: 'b', objectName: 'List size chart', altText: 'Line chart of accuracy against list size' }));
  s.addChart(pres.charts.BAR, [
    { name: 'Pass rate, both checks', labels: ['Real', 'Print', 'Cut print', 'Monitor', 'Phone'], values: ['Real', 'Print', 'Cut', 'Monitor', 'Phone'].map((k) => num('live' + k + 'Both')) },
  ], Object.assign(chartBase(), { x: 6.9, y: 1.45, w: 5.8, h: 3.95, barDir: 'col', title: 'Liveness: pass rate (%) per clip, both checks', chartColors: [HEX.accent1], showValue: true, dataLabelPosition: 'outEnd', dataLabelFontFace: '+mn-lt', dataLabelFontSize: 12, dataLabelColor: HEX.dk1, showLegend: false, objectName: 'Liveness chart', altText: 'Bar chart of liveness pass rate per attack' }));
  const stats = [[V.detHit + '%', 'faces found correctly (IoU 0.5)'], [V.noneHarsh + '% to ' + V.homHarsh + '%', 'harsh light with the homomorphic filter'], ['about ' + V.faceTotal + ' s', 'for a full face check-in']];
  stats.forEach((p, i) => {
    const x = 0.6 + i * 4.1;
    s.addText(p[0], { x, y: 5.55, w: 3.9, h: 0.75, fontSize: 30, bold: true, color: C.accent2, margin: 0, align: 'center', isTextBox: true, objectName: 'Stat' });
    s.addText(p[1], { x, y: 6.3, w: 3.9, h: 0.4, fontSize: 14, color: C.text1, margin: 0, align: 'center', isTextBox: true, objectName: 'Stat caption' });
  });

  section('Close');
  s = add('DARK', 'Close', 'Conclusion and future work', 'Simple methods help on short lists in controlled light. The booking code is essential. Next we would collect our own consented data and add moire analysis for screens.');
  s.addText([
    { text: 'Eigenfaces work only for short lists in controlled light; the ready-made model is far stronger', options: { bullet: true, breakLine: true } },
    { text: 'Homomorphic filtering rescues harsh light; texture stops prints; screen replay remains hardest', options: { bullet: true, breakLine: true } },
    { text: 'The booking code is essential, not a backup', options: { bullet: true, breakLine: true } },
    { text: 'Next: our own consented data, moire analysis for screens, a stronger identity model if allowed', options: { bullet: true } },
  ], { placeholder: 'sub', paraSpaceAfter: 8 });

  s = add('CONTENT', 'Close', 'Live demo and questions', 'We now run the real kiosk. Two team members are on today\'s list. We check one in by face, test a printed photo against the liveness check, and use the booking code. Then we take questions.');
  const demo = ['Two team members are already on today\'s list', 'Agree, look at the camera, and check in by face', 'Show a printed photo to test the liveness check', 'Decline consent and check in with the booking code', 'See the receptionist list update, then questions'];
  demo.forEach((t, i) => {
    const y = 1.6 + i * 0.97;
    circle(s, 0.7, y + 0.1, i + 1, i === 2 ? C.accent2 : C.accent1);
    s.addText(t, { x: 1.55, y, w: 11, h: 0.75, fontSize: 22, color: C.text1, margin: 0, valign: 'middle', isTextBox: true, objectName: 'Demo step' });
  });

  await pres.writeFile({ fileName: OUT });
  await applyTheme(OUT, THEME);
  console.log('deck written', OUT);
})();
