% compare.m - loads the outputs of the old and new code and reports any difference.
T = '/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/cache/test_kiosk/';
old = load([T 'eq3_old.bin']).R;
new = load([T 'eq3_new.bin']).R;
allSame = true;
for name = fieldnames(old)'
    a = old.(name{1});
    b = new.(name{1});
    same = isequal(a, b);
    allSame = allSame && same;
    if same
        printf('%-14s identical\n', name{1});
    elseif isnumeric(a) && isequal(size(a), size(b))
        printf('%-14s DIFFERENT, largest difference %g\n', name{1}, max(abs(double(a(:)) - double(b(:)))));
    else
        printf('%-14s DIFFERENT\n', name{1});
    end
end
printf('\nALL OUTPUTS IDENTICAL: %d\n', allSame);
