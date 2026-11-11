% compare_models.m - is the models.mat made by the new run the same as the one before it?
a = load('/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/cache/before_simplify_2026-11-11/models_before_run.mat');
b = load('/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk/models.mat');
printf('models.mat identical: %d\n', isequal(a, b));
