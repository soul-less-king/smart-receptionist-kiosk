1;
function maps = convolution3x3(maps, layer)  % competitor only: every 3x3 filter of one layer slides over all input maps (Lecture 4)
    patches = im2col(padarray(maps, [1 1]), [3 3 size(maps, 3)], 'sliding');   % one column per pixel: its 3x3 neighborhood in every input map
    maps = reshape(patches' * reshape(layer.weights{1}, [], size(layer.weights{1}, 4)) + layer.weights{2}(:)', rows(maps), columns(maps), []);   % every filter times every patch, plus the bias
end

function embedding = vggFace(face, net)  % competitor only: the ready-made VGG-Face layers, then one average per feature map (Lectures 5, 6)
    maps = single(imresize(face, [224 224])) - net.avg;
    for layer = 1:31                                                  % VGG-16's 13 convolution layers, each followed by ReLU, and its 5 max pools
        if strcmp(net.layers{layer}.type, 'conv')
            maps = max(convolution3x3(maps, net.layers{layer}), 0);   % convolution, then ReLU
        elseif strcmp(net.layers{layer}.type, 'pool')
            maps = max(max(maps(1:2:end, 1:2:end, :), maps(2:2:end, 1:2:end, :)), max(maps(1:2:end, 2:2:end, :), maps(2:2:end, 2:2:end, :)));   % 2x2 max pooling: the largest of every 2x2 block
        end
    end
    embedding = double(squeeze(mean(mean(maps, 1), 2)));            % global average pooling: 512 numbers
    embedding = embedding / norm(embedding);
end

function described = describeImages(paths, net, faceTemplate, change)  % finds the face in each photo and describes it two ways: our Eigenfaces input and VGG-Face
    described.boxes = zeros(numel(paths), 4);
    for photo = 1:numel(paths)
        picture = change(imread(paths{photo}), photo);              % the change is nothing, a painted mask or strong backlight
        box = detectFace(picture, faceTemplate);
        if isempty(box)
            box = [1 1 columns(picture) rows(picture)];              % no face found: use the whole photo
        else
            described.boxes(photo, :) = box;
        end
        described.filtered(:, photo) = homomorphicFilter(cropFace(picture, box));
        described.vgg(:, photo) = vggFace(cropFace(picture, box), net);
    end
end

function enrolled = chooseGallery(people, perPerson)  % picks perPerson random photos of each person to enroll
    enrolled = false(size(people));
    for person = unique(people)
        photos = find(people == person);
        enrolled(photos(randperm(numel(photos), perPerson))) = true;
    end
end

function [predicted, accepted] = matchAll(features, people, enrolled, useEigenfaces)  % matches every photo that is not enrolled against the enrolled ones
    enrolledFeatures = features(:, enrolled);
    tests = features(:, ~enrolled);
    if useEigenfaces                                                  % our method trains Eigenfaces on the enrolled photos only
        [model, enrolledFeatures] = trainEigenfaces(enrolledFeatures);
        tests = projectFaces(tests, model);
    end
    enrolledPeople = people(enrolled);
    for photo = 1:columns(tests)
        [closest, accepted(photo)] = matchFace(tests(:, photo), enrolledFeatures, enrolledPeople);
        predicted(photo) = enrolledPeople(closest);
    end
end

function [accuracies, perPerson] = listCurve(features, people, useEigenfaces)  % accuracy as today's list grows from 5 to 50 people, over 20 random lists of each size
    rng(0);
    sizes = [5 10 20 30 40 50];
    perPerson = zeros(1, 50);
    for row = 1:6
        for repeat = 1:20
            onList = ismember(people, randperm(50, sizes(row)));
            listPeople = people(onList);
            enrolled = chooseGallery(listPeople, 5);
            predicted = matchAll(features(:, onList), listPeople, enrolled, useEigenfaces);
            truth = listPeople(~enrolled);
            accuracies(row, repeat) = mean(predicted == truth);
            if row == 6                                               % full lists: each person's accuracy, for the glasses test
                perPerson = perPerson + arrayfun(@(person) mean(predicted(truth == person) == person), 1:50) / 20;
            end
        end
    end
end

function result = strangerTest(features, people, useEigenfaces)  % 25 people on the list and 25 strangers: precision, recall, F1 and strangers accepted (Lecture 3)
    rng(0);
    onList = ismember(people, randperm(50, 25));
    enrolled = false(size(people));
    enrolled(onList) = chooseGallery(people(onList), 5);
    [predicted, accepted] = matchAll(features, people, enrolled, useEigenfaces);
    isVisitor = onList(~enrolled);
    correct = accepted & isVisitor & predicted == people(~enrolled);
    precision = sum(correct) / max(sum(accepted), 1);
    recall = sum(correct) / sum(isVisitor);
    result = [precision, recall, 2 * precision * recall / max(precision + recall, eps), mean(accepted(~isVisitor))];
end

function picture = paintMask(picture, box)  % covers the lower 45% of the face box with a plain light-gray mask
    picture(box(2) + round(0.55 * box(4)) - 1:box(2) + box(4) - 1, box(1):box(1) + box(3) - 1, :) = 205;
end

function frame = readFrame(path)  % reads one video frame as an 8-bit color picture; the very large phone frames are shrunk to a third
    frame = im2uint8(imread(path)) .* ones(1, 1, 3, 'uint8');      % three color channels, also for the two all-black frames that Octave reads as black-and-white
    if rows(frame) > 640
        frame = imresize(frame, 1 / 3);
    end
end
