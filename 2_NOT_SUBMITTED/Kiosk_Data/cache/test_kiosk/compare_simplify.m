% compare_simplify.m - loads the outputs of the old and new experiment helpers and reports any difference.
T = '/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/cache/test_kiosk/';
old = load([T 'eqs_old.bin']).R;
new = load([T 'eqs_new.bin']).R;
allSame = true;
for name = fieldnames(old)'
    same = isequal(old.(name{1}), new.(name{1}));
    allSame = allSame && same;
    printf('%-14s %s\n', name{1}, {'DIFFERENT', 'identical'}{same + 1});
end
printf('\nALL OUTPUTS IDENTICAL: %d\n', allSame);
