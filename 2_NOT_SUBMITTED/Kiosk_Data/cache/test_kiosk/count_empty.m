% count_empty.m - how many Georgia Tech photos get no face box at all (decides whether a simpler describeImages keeps every number).
cd /home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk
findFace;
models = load('models.mat');
paths = glob('../Kiosk_Data/gt/images/gt_db/s*/*.jpg');
empty = 0;
for photo = 1:numel(paths)
    empty = empty + isempty(detectFace(imread(paths{photo}), models.faceTemplate));
end
printf('photos: %d, without any face box: %d\n', numel(paths), empty);
