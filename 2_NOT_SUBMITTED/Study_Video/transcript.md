# Study video transcript

Consent-Based Smart Receptionist Kiosk, the whole project explained.

## 00:00  Welcome

Welcome. This video explains our whole project, the Consent-Based Smart Receptionist Kiosk, from A to Z. It is made for the five of us: Abdulrahman, Fahad, Hadi, Islam and Hashir.
We use simple words and go step by step. When we talk about a line of code, that line is highlighted in yellow, and important words get a yellow box.
Here is the plan. First, what the course asked for, and how we are graded. Then the problem and our idea, and the big picture. Then what we submit, and how to run it.
Then the main part: every function in all five files, line by line. After that, the datasets, the report and the slides, what we used from the class notes, and the rubric, box by box.
Then the changes the doctor may ask for in the oral exam, and at the end, who owns which part. Pause the video any time, and go back when something is not clear.

## 00:58  1 · What the course asked for

The brief is the PDF called Course Project Proposal. It asks each team of five to build a complete computer vision system.
It asks for the MATLAB environment. We wrote our code in GNU Octave, which uses the same language.
Our report says this openly, in the meta-discussion: because of Octave, the screen uses Octave's own buttons and boxes instead of App Designer. Be ready to say this if the doctor asks.
The system must use a camera. Our kiosk records three seconds of webcam video, but only after the visitor agrees.
It must combine at least two computer vision modules. We have four: finding the face, fixing the light, liveness, and recognition.
At least one core step must be written from the equations. We wrote several: the face finder, Eigenfaces, the homomorphic filter, Local Binary Patterns, and the blink check.
Data must come from public datasets or with consent, and there must be a non-biometric way in. We used public datasets, and the booking code is our non-biometric way in.
We deliver a report, documented code and a live demo. Then each of us gets questions and must change code live.
The brief says every student must be able to explain, reproduce and modify all submitted code. That is why this video exists.
The rubric file gives three grades. The report is worth 17.5 points, and most of it is for the method, the numbers, the speed analysis and the failure cases.
The code is worth 7 points, and half of the code grade is simply: does it run without errors or warnings.
The presentation is worth 10.5 points, including the demo and our ability to explain and change code live. Together that is 35 points, the project's share of the course.
The report, the slides and the code are due on Tuesday, November 17. The presentations are on November 24 and 26: about 10 to 15 minutes, then questions, the live demo, and live code changes.

## 03:11  2 · The problem and our idea

Now the problem we solve. In an office or a clinic, a receptionist checks every visitor's name against a list, by hand. This is slow when several people arrive together. It is the same job, all day.
And it is not private, because each visitor must say their name out loud in a full waiting room.
Our idea was a kiosk. The visitor walks up, agrees to a face scan, and is checked in within seconds. The camera stays off until the visitor agrees.
Second idea: two equal ways in. Some people wear a face covering, or simply say no, so the booking code is a full path, not a backup.
Third idea: we only compare with today's list, usually 10 to 50 people, never a big database.
This is why a simple method might be enough, and we test it with a graph as the list grows from 5 to 50 people.
Fourth idea: we write Eigenfaces ourselves, from the equations, and compare them with a ready-made model.
Doctor Khalil liked the proposal, especially the consent flow, the equal second path, and the test as the list grows. He asked for three things.
First, a homomorphic filter, to fix changing office light before our Eigenfaces.
Second, liveness with two features: a texture check with Local Binary Patterns, to catch paper and screens, and a physical cue, the eye blink.
Third, he allowed a ready-made face model, but strictly as a competitor to our own code. So the ready-made model, VGG-Face, appears only in the experiments file, never in the kiosk.
We also said what we do not do: one visitor at a time, no cloud, no phone app, no real booking system, and no doors or payments.
A small, clear scope is a good answer if the doctor asks why something is missing.

## 05:09  3 · The big picture

Here is the whole system in one picture. Each box is a step, and the name under it is the file that does it.
Step one, consent. The screen explains what will happen, and the camera is off.
Step two. When the visitor presses I Agree, the kiosk records 45 frames, about three seconds of video.
Step three, find the face, with our own face template slid over the picture at many sizes.
Step four, liveness. Two checks must pass: the skin texture must look real, and we must see a blink.
Step five, fix the light, with the homomorphic filter.
Step six, recognize. Our Eigenfaces turn the face into a few numbers, and we find the nearest photo on today's list. A ratio test refuses unclear matches.
Step seven, check in. The visitor is welcomed, and the receptionist's list changes from Expected to Checked in.
If the visitor says no, or any step fails, the visitor types the booking code instead. The list updates either way.
The code is split into five files, called Part 1 to Part 5. Each file holds a few small functions.
Part 1, `kiosk.m`, is the screen. It has ten functions: it builds the window, runs the buttons, records the camera, and handles every error.
Part 2, `findFace.m`, finds the face and cuts it out. Four functions.
Part 3, `recognizeFace.m`, fixes the light and recognizes the face with our own Eigenfaces. Four functions.
Part 4, `checkLiveness.m`, decides if the face is alive. Three functions.
Part 5, `experiments.m`, is not part of the kiosk. It runs every test in our report, it builds the small model file the kiosk needs, and it is the only place where the ready-made VGG-Face model runs.
In total there are 29 functions: 21 run in the kiosk, and 8 only in the experiments.
The rubric asks for modular code with more than one level of function calls. Here is what runs after one click on I Agree.
Level one is the click itself. Octave runs the button's callback.
Level two is `runSafely`. It reads the kiosk data, runs the action, and saves the data back.
Level three is `onAgree`, the face path, step by step.
Level four is the helpers that `onAgree` calls: record, find, crop, the two liveness checks, the light filter, matching and check-in.
Level five is helpers of helpers: `detectFace` calls `gradientHistograms`, `cropAllFrames` calls `cropFace`, and `checkIn` calls `stopIf` and `updateScreen`. So our calls go five levels deep.
What is written from scratch? The face finder, the homomorphic filter, Eigenfaces with the ratio test, the LBP texture, and the blink check.
We still call small built-in tools, like gradient, image resize, the Gaussian filter, eig for eigenvectors, and corr for correlation.
That is allowed: the brief only says we must not rely only on high-level functions.
The ready-made VGG-Face weights are used only as a competitor, and even there, the layers run through our own short loop.

## 08:38  4 · What we submit, and how to run it

This is exactly what we hand in: the report as a PDF, the slides, and the source code folder.
The source code folder holds our five dot-M files, the small file models dot mat, and an empty folder called today.
We do not submit the datasets, which are more than a gigabyte, or the competitor's weights file. Without them, `experiments.m` prints a polite message and stops, instead of crashing.
We also do not submit test logs, backups, the course slides, or this video.
To run the kiosk: install GNU Octave with two packages, image and image acquisition. Plug in a webcam.
Put photos of today's visitors in the `today` folder, one subfolder per visitor, named `Name_Code`. Eigenfaces need at least two people. Then, in Octave, go into the source code folder and type kiosk.
The kiosk also needs models dot mat. It holds three things: the face template, which is the average edge pattern of a face,
12 by 8 cells with 8 directions each, and two average texture histograms, one for real faces and one for fake faces. `experiments.m` makes this file; the kiosk only reads it.

## 09:58  5 · Part 1 · kiosk.m, the screen

Every one of our files starts with two comment lines. Line 1 says what the file does, and how to start the kiosk. Line 2 names the programmers, the course and the term.
The rubric asks for exactly this: information about the programmers, and the overall program function.
The first function is also called `kiosk`. It runs once, when you type kiosk. It loads everything, and builds the window you see on the right.
Lines 4 to 6 load the other parts. In Octave, a script file can hold functions. Calling the file's name runs it, and its functions become ready to use.
So after these three lines, the kiosk can use every function in Parts 2, 3 and 4.
Line 7 loads `models.mat` into `app.models`. `app` is one structure, like a box with labelled drawers, that holds everything the kiosk needs.
Line 8 calls `loadTodaysList`, which we will see in Part 3. It reads the photos in the today folder, and returns today's names, booking codes and statuses, plus the trained Eigenfaces.
Line 9 creates the window with `figure`. We give it a name, and hide the figure number, the menu and the toolbar.
Position means: 60 pixels from the left of the screen, 40 from the bottom, 1060 wide and 680 tall. The last three numbers are the light background color, as red, green and blue between 0 and 1.
Line 10 makes the camera view. `zeros(480, 640, 3)` is a black color picture, and `imshow` shows it inside new axes at the position 43, 225, with size 594 by 445.
We keep it as `app.cameraView`, so later we can swap the black picture for live frames.
Line 11 adds an empty line of text. This is where the kiosk talks to the visitor, so we keep it as `app.message`.
Line 12 is the consent notice, in two lines: the face is compared only with today's visitors, no picture is kept, and a booking code can be used instead.
Inside quotes, two single quotes mean one apostrophe.
Line 13 adds the I Agree button. The at sign makes a handle to the function `onAgree`, so pressing the button runs `onAgree`.
Line 14 adds the No Thanks button. Its action is a tiny function written in place: it only shows a message asking for the booking code. The camera never turns on.
Lines 15 to 17 build the booking-code path: a label, an edit box where the visitor types, kept as `app.codeBox`, and the Check In With Code button, which runs `onCode`.
Lines 18 and 19 build the receptionist's side: a title and a list box. The list uses a monospace font, so names and statuses line up in columns.
Setting max to 2 allows the list to have no selected row, so it is only a display.
Line 20 shows the welcome message, and fills the list for the first time.
Line 21 is important. `guidata` stores `app` inside the window. Every button later reads `app` from the window, changes it, and stores it back. That is how the kiosk remembers who has checked in.
Typical changes here: a bigger window or a new color, on line 9. New button words, on lines 13 to 17. A different welcome message, on line 20.
`onAgree` is the heart of the face path. It runs when the visitor presses I Agree. Each line is one step, and any failed step stops with a clear message.
Line 25 first checks that today's list has an Eigenfaces model. With fewer than two people, there is no model, so we stop and ask for the booking code.
`stopIf` means: if this is true, stop here and show this message.
Line 26 starts a stopwatch with `tic`. At the end, `toc` reads how many seconds have passed, and that time is shown in the receptionist's list.
Line 27 asks the visitor to look at the camera and blink normally.
Line 28 records 45 frames from the webcam with `recordFrames`. `frames` is a cell array: 45 pictures in a row.
Line 29 takes the middle frame, number 23. We look for the face only once, in the middle, because the visitor stands still.
Line 30 finds the face with `detectFace` from Part 2. `box` is four numbers: left, top, width and height.
Line 31: if no face was found, `box` is empty, so we stop and ask the visitor to stand in front of the camera.
Line 32 cuts the same box out of all 45 frames, and makes each face gray and 120 by 90 pixels.
Line 33 is the texture check. `lbpHistogram` describes the skin texture, and `looksReal` compares it with the average real texture and the average fake texture. If it is closer to fake, we stop.
Line 34 is the blink check. If no blink is seen in the three seconds, we stop. Both checks must pass: this is the dual-feature liveness the doctor asked for.
Line 35 cuts the face out of the middle frame, in color, and the homomorphic filter fixes its light. The result is one long column of 4800 numbers.
Line 36 turns the face into eigenface weights: subtract the average face, then multiply by the eigenfaces, turned on their side. The apostrophe means transpose. These few numbers describe the face.
Line 37 compares these weights with every photo on today's list. `closest` is the nearest photo, and `accepted` says if the match is clear enough.
Line 38: if the match is not clear, the visitor is asked to use the booking code.
Line 39 checks the visitor in. `photoOwners` at `closest` tells us which person owns the nearest photo. The way is written as face, plus the time from `toc` with one decimal, for example: face, 4.8 seconds.
If the doctor asks to try only one liveness check, put a percent sign at the start of line 33 or line 34. That turns the line into a comment. Commenting out is safer than deleting in a hurry.
`onCode` runs when the visitor presses Check In With Code.
Line 43 reads the text in the code box with `get`, removes spaces at both ends with `strtrim`, and compares it with every booking code using `strcmp`.
`find` gives the position of the match: that is the person's number.
Line 44 empties the box, so the next visitor does not see the code.
Line 45: if no code matched, and that includes an empty box, we stop with the message: that code is not on today's list.
Line 46 checks the person in, and the way is written as code.
`checkIn` is shared by both paths. Line 50 stops if the person is no longer Expected, so nobody can check in twice. The message says that this person is already checked in.
Line 51 changes the status, for example to: Checked in by code, or: Checked in by face, 4.8 seconds. Square brackets join pieces of text together.
Line 52 welcomes the visitor by name, says the receptionist has been told, and refreshes the list.
`recordFrames` is the only function that touches the camera, and it only runs after consent.
Line 56 loads Octave's camera package, image acquisition.
Line 57 opens the webcam. `v4l2` means Video for Linux, the camera system of Linux. `/dev/video0` is the first webcam, and 640 by 480 is the picture size.
Line 58 starts the camera, with two picture buffers.
Lines 59 to 63 are the loop. 45 times: take a snapshot, keep it in `frames`, show it in the camera view by changing its `cdata`, and `drawnow`, so the screen updates at once.
45 frames are about three seconds.
Line 64 stops the camera. Line 65 puts the black picture back. The frames live only during this check-in, and are never saved to disk.
If the doctor asks for a five-second recording, change 45 to 75 on line 59.
`stopIf` is tiny. If the condition is true, it raises an error with the label `kiosk:stop` and our message. Percent S means: show the message exactly as written.
This error does not crash the kiosk, because `runSafely` catches it. One `stopIf` line replaces a whole if block, which keeps `onAgree` short.
`runSafely` wraps every button. This is our robustness: the user can do strange things, and the kiosk still never crashes.
Line 76 does three things in one sentence. `guidata(button)` reads `app` from the window. `action(...)` runs the button's function, like `onAgree`, on that `app`.
Then `guidata`, with the button and the result, stores the new `app` back in the window.
If anything inside goes wrong, Octave jumps to `catch`, and `problem` describes the error.
Lines 78 and 79: if it was one of our `stopIf` messages, show it to the visitor.
Lines 80 and 81: for any other problem, for example no camera, show a calm general message. `ishghandle` checks that the window still exists.
If the window was closed during recording, we do nothing, instead of causing a second error. And because a stopped action never reaches the saving step, a failed check-in never changes the list.
`updateScreen` shows a message on line 87, and rebuilds the receptionist's list on line 88.
`cellfun` walks through the names and the statuses together, and `sprintf` writes each row. `%-16s` means: the name, padded with spaces to 16 characters, so all statuses start in the same column.
Value empty means no row is selected. For longer names, change 16 to 24.
`addText` makes a text label with `uicontrol`, style text, at a position, with a font size.
Its background is the window's own color, so it looks like plain text, and left alignment makes it read like a sentence.
`addButton` makes a push button. Two settings protect us from impatient clicking. Interruptible off means a running action cannot be interrupted.
Busy action cancel means clicks that arrive while the button is busy are thrown away. The callback sends every click through `runSafely`.
The tilde means: Octave also sends an event value, and we ignore it.

## 21:38  6 · Part 2 · findFace.m, finding the face

`findFace.m` starts with the same two comment lines, and then `pkg load image`. This loads Octave's image package, with tools like image resize and the Gaussian filter.
`gradientHistograms` is the base of our face finder. It describes a picture by the direction of its edges, in small cells.
This is the idea of SIFT and HOG from Feature Extraction Part 2, and the orientation histograms from Assignment 2.
Line 6: `gradient` measures how fast the brightness changes, from left to right and from top to bottom, at every pixel. Edges are where the brightness changes fast.
Line 7 turns the two changes into an angle with `atan2`. `mod` by two pi keeps it between zero and a full circle.
Dividing by two pi and multiplying by 8 splits the circle into 8 bins of 45 degrees, numbered 1 to 8. The `min` with 8 is a safety net for rounding.
Line 8 makes two tables: the row number and the column number of every pixel.
Line 9 is the clever line. The row divided by 8, rounded up, is the cell row; the column divided by 8 is the cell column.
`accumarray` then adds every pixel's edge strength, from `hypot`, into the slot for its cell and its direction. The result is one 8-bin histogram for every 8 by 8 cell.
Line 10 divides each cell's histogram by its length, so every cell has a length of about one. If the light gets brighter, all edges get stronger together, and this division cancels it.
The 0.01 avoids dividing by zero in a flat cell.
`detectFace` slides the face template over smaller and smaller copies of the picture. This is the sliding window from Lecture 8, together with an image pyramid from Feature Extraction.
Line 14 starts with an empty box. If nothing beats the bar, the function returns empty, which means: no face.
Line 15 sets the bar. A best match weaker than 9 means nobody is there. To make detection stricter, raise 9; to find faces more easily, lower it.
Line 16 makes the picture gray, with values from 0 to 1. We do this once, before the loop, to save time.
Line 17 loops over ten scales, from 1.15 to the power minus 2, down to 1.15 to the power minus 11. Each step shrinks the picture by about 15 percent.
The template always has 12 by 8 cells, so a smaller picture means we look for a bigger face. Together, the scales cover face heights from 127 to 445 pixels.
Line 18 shrinks the picture, computes its cell histograms, and slides the template over it with `convn`. Convolution flips the template, so we flip it first, with end to 1 in all three directions.
Flipped twice means plain correlation, from Chapter 3. Valid means: only places where the whole template fits. Each score is a sum of products, which is high where the edges match a face.
Line 19 finds the best score at this scale, and where it is.
Lines 20 and 21: if it beats the best so far, keep it.
Line 22 turns the position number into a cell row and a cell column.
Line 23 turns cells into pixels. Times 8 gives pixels in the small picture, and divided by the scale gives pixels in the original picture. The width is 8 cells and the height is 12 cells.
We add 1 because pictures start at pixel 1 in Octave.
`cropFace` cuts the box out of the picture. The rows go from the top to top plus height minus 1, and the columns from left to left plus width minus 1.
`max` with 1, and `min` with the picture size, keep the box inside the picture, so a face at the edge never causes an error. The colon at the end keeps all three color channels.
`cropAllFrames` uses the same box in all frames, because the visitor stands still. For each frame, it crops, makes the face gray, and resizes it to 120 by 90.
`faces` becomes a stack of 45 small gray faces, which both liveness checks use.

## 26:13  7 · Part 3 · recognizeFace.m, light and Eigenfaces

`homomorphicFilter` is the doctor's first suggestion. The idea: a picture is light times detail. The light changes slowly across the face, like a shadow on one side.
The detail, like the eyes and the mouth, changes quickly.
Line 6 makes the face gray, resizes it to 80 by 60, and takes the log. The log turns light times detail into light plus detail, so we can separate them by subtraction.
`max` with zero removes tiny negative values left by resizing, and plus 0.01 avoids the log of zero.
Line 7 blurs the log face with a Gaussian of width 8. A strong blur keeps only what changes slowly, which is the light. Chapter 3 covers the Gaussian filter and uneven illumination.
Line 8: the detail is the log face minus the light. We shrink the light to 0.7, boost the detail to 1.4, and add them back.
`reshape` makes one column of 4800 numbers, and `zscore` gives it an average of 0 and a spread of 1, so every face is on the same scale.
We chose 8, 0.7 and 1.4 using Yale people 1 to 19 only, and we report results on people 20 to 38, who were never used for tuning.
If the doctor asks to turn the filter off, set both weights to 1: then only the log remains.
`trainEigenfaces` is our main from-scratch method. It follows the eigenface equations from the linear algebra review and Assignment 1. The input `faces` has one column per photo.
Line 12: the average face is the mean of all the columns. Mean with 2 means: along each row.
Line 13: A is every face minus the average face. Eigenfaces describe how faces differ from the average.
Line 14 is the trick. A times A transpose would be 4800 by 4800, which is too big. A transpose times A is only n by n, where n is the number of photos.
`eig` gives its eigenvectors v and its eigenvalues.
Line 15 sorts the eigenvalues from largest to smallest. A large eigenvalue means that direction explains a lot of the difference between faces.
The tilde means we do not need the sorted values, only their order.
Line 16 makes the eigenfaces: U equals A times v. This is the link between A transpose A and A A transpose from our slides.
We keep at most 100 eigenfaces, and at most the number of photos minus 1, because the last one carries no information after the average is removed.
Line 17 gives every eigenface a length of 1.
Line 18 computes the weights of every training photo: w equals U transpose, times the face minus the average. Each photo is now described by at most 100 numbers, instead of 4800.
`matchFace` finds the nearest photo. Line 22 computes the Euclidean distance from the visitor's weights to every enrolled photo: the square root of the sum of squared differences.
Line 23: `min` gives the smallest distance, called `nearest`, and its position, called `closest`.
Line 24 is the ratio test, from feature matching in Assignment 3. We divide the nearest distance by the nearest distance to a different person.
If the two are almost equal, the face is ambiguous, so we refuse. The match is accepted only when the ratio is 0.85 or less; a lower number is stricter.
`loadTodaysList` runs when the kiosk starts, and turns the today folder into the list.
Line 28 lists everything in the today folder whose name contains an underscore, like Alice underscore 1001.
Line 29 gets the names. `regexprep` with this pattern deletes the last underscore and everything after it. So Al underscore Thani underscore 1234 gives the name Al underscore Thani.
Line 30 deletes everything up to the last underscore, which leaves the booking code.
Line 31: everyone starts as Expected. Lines 32 and 33 start two empty lists: who owns each photo, and the faces.
Lines 34 and 35 go through every person, and every J-P-G photo in that person's folder. The apostrophe after `glob` turns the list on its side, so the loop visits one photo at a time.
Line 36 starts a try block. If anything fails for one photo, for example no face is found, that photo is skipped and the kiosk keeps going.
Line 37 reads the photo and resizes it to 640 pixels wide, like a camera frame. `NaN` means: choose the height that keeps the shape.
Line 38 finds the face, cuts it out, fixes the light, and adds the column to `faces`. These are the same steps the kiosk uses for a visitor, so photos and visitors are treated the same way.
Line 39 remembers who owns that photo.
Lines 43 to 45: if at least two people have usable photos, we train Eigenfaces on today's photos only. This is our idea of comparing only with today's list.

## 31:58  8 · Part 4 · checkLiveness.m, is the face alive?

`lbpHistogram` is the texture check: the doctor's Local Binary Patterns. Paper and screens have a different fine texture from real skin.
Line 6 takes every pixel except the border, because border pixels do not have 8 neighbors. It works on all 45 faces at once. Line 7 starts every code at zero.
Line 8 lists the steps to the 8 neighbors, the N8 neighborhood from Chapter 3: up-left, up, up-right, right, down-right, down, down-left and left.
Inside the loop, line 10 shifts the whole picture by one step, so at every position we now see that neighbor's value.
Line 11 compares. If the neighbor is not darker than the center, this bit is 1. Bit 1 is worth 1, bit 2 is worth 2, then 4, 8, and so on up to 128.
Adding them gives a code from 0 to 255 for every pixel.
Line 13 counts how many pixels have each code, from 0 to 255, over all frames, and divides by the number of pixels. The result is 256 shares that add up to 1: a texture fingerprint.
`looksReal` compares a texture histogram with two averages from `models.mat`: real skin, and fake faces.
The sum of squared differences, SSD from Feature Extraction Part 3, measures how far apart two histograms are. If the face is closer to real than to fake, it looks real.
The sums run along each row, so the experiments can test many histograms at once.
`blinkSeen` is the physical cue, the blink. During a blink the eyes change, but the lower face stays the same.
If the whole picture moves, like a sheet of paper being bent, both parts change together, and that is not a blink.
Line 21 takes the eye band, the rows from 26 to 56 percent of the face height, and makes each frame one column.
Line 22 does the same for the lower face, from 62 to 95 percent.
Line 23: the median over all frames is the usual look of each band.
`corr` measures how similar each frame is to that usual look; this is normalized cross-correlation, NCC, from Feature Extraction Part 3. We subtract the eye similarity from the lower-face similarity.
At a blink the eyes drop but the lower face does not, so the gap grows. If the biggest gap is more than 0.06, we saw a blink.

## 34:40  9 · Part 5 · experiments.m, every test in the report

`experiments.m` is Part 5. Its header says that it runs every test in the report and prints each result, in about 50 minutes, and that it makes `models.mat`.
Then it loads Parts 2, 3 and 4, just like the kiosk. It is a script: functions first, then the tests.
`vggFace` is the ready-made competitor. The weights come from VGG-Face, a VGG-16 network trained on faces. We borrowed only its numbers; the loop that runs them is ours, using Lectures 4, 5 and 6.
Line 8 resizes the color face to 224 by 224, the size the network expects, and subtracts the average image it was trained with.
Line 9 walks through 31 layers: 13 convolutions, 13 ReLUs and 5 max pools. We apply ReLU right after each convolution, so the ReLU layers themselves are skipped.
Lines 11 to 13 are one convolution layer. `padarray` adds a border of zeros. `im2col` cuts out the 3 by 3 neighborhood of every pixel, in every input map, as one column.
One big matrix product applies every filter to every patch, we add the bias, reshape back into maps, and `max` with zero is ReLU.
Line 15 is 2 by 2 max pooling: from every 2 by 2 block, keep the largest value. The maps halve in size.
Lines 18 and 19 are global average pooling: each of the 512 final maps is averaged into one number, and the 512 numbers are scaled to length 1. This is how VGG describes the face.
`describeImages` prepares the data for the tests. For each photo, it first applies a change: nothing, a painted mask, or strong backlight.
Then it finds the face with our own detector. If no face is found, the whole photo is used, and the box stays all zeros, so it counts as a miss in the overlap test.
Then each photo is described twice: with our homomorphic filter, for Eigenfaces, and with VGG-Face. Both methods always get the same face crop, which makes the comparison fair.
`chooseGallery` picks 5 random photos of each person to enroll, like the photos in the today folder. `randperm` picks 5 different positions, and the other photos are the tests.
`matchAll` is the test version of the kiosk's matching, for both methods. Lines 46 and 47 split the photos into enrolled ones and test ones. The tilde means not.
Lines 48 to 51: for our method, train Eigenfaces on the enrolled photos only, then turn the test photos into weights. VGG features are used as they are.
Lines 52 to 57 match every test photo with the same `matchFace` as the kiosk. `correct` says if the nearest photo belongs to the right person, and `accepted` says if the ratio test agreed.
`listCurve` answers the central question of our proposal: what happens as today's list grows? `rng(0)` fixes the random numbers, so every run gives exactly the same lists and the same results.
For each list size, we try 20 random lists. `randperm` picks who is on the list, `chooseGallery` enrolls 5 photos of each person, and the accuracy is the share of correct matches.
With all 50 people, we also keep each person's accuracy, for the glasses test. Each person has 10 test photos in a row, so reshaping into 10 rows and 50 columns gives one column per person.
`strangerTest` checks that the kiosk refuses strangers. 25 people are on the list and 25 are strangers; only the 25 get enrolled photos.
Welcomed means: let in, under the right name.
Precision is the share of let-in photos that were right. Recall is the share of visitors' photos that were let in correctly. F1 combines both; these three come from Lecture 3.
The last number is the share of strangers who were wrongly let in.
`paintMask` simulates a face mask: it paints the lower 45 percent of the face box light gray, with the value 205.
`readFrame` reads one frame of a liveness clip. Multiplying by ones of size 1 by 1 by 3 makes sure there are always three color channels, because two all-black frames are stored in black and white.
Phone frames are very large, so they are shrunk to a third.
This guard is why the submitted folder runs without errors. If the weights file or the datasets are missing, the script prints a message and stops politely.
Otherwise it loads the VGG weights, and sets the data folder, which sits next to the code folder.
Section 1, finding the face, uses the Georgia Tech face database: 50 people, 15 photos each, with a labelled face box.
`kron` makes the person number of each photo: fifteen ones, fifteen twos, and so on. `repmat` makes the shot number, 1 to 15, for every person.
`glob` lists the 750 photos. The labels give the left, top, right and bottom of each face, which we turn into left, top, width and height.
Photos 2, 7 and 12 of each person, 150 photos, teach the template. The other 600 are held out for testing, so we never test on photos we learned from.
The template is the average of the gradient histograms of these 150 faces, each resized to 96 by 64 pixels, which is 12 by 8 cells.
We also add each face's mirror image, with `fliplr`, so the template is symmetric. Then each direction bin is made zero-mean, so the score rewards the face pattern, not just a lot of edges.
`describeImages` then finds the face in all 750 photos, and describes each one for both methods.
`rectint` gives the overlap area of our box and the labelled box. Intersection over union, from Lecture 8, divides the overlap by the total area covered.
`detection` prints two numbers: the share of test faces found with an IoU of at least 0.5, which is 99.7 percent, and the average IoU, 0.82.
Section 2 runs `listCurve` for both methods, and prints the average accuracy and the spread for each list size.
Our Eigenfaces fall from 78.1 percent with 5 people to 45.8 percent with 50 people, while VGG-Face stays at about 99.5 percent.
Then the glasses test. We wrote down the 13 people who wear glasses in some photos. With Eigenfaces they scored 53 percent, against 43 percent for the others, so glasses did not hurt.
Section 3 runs the stranger test for both methods. Eigenfaces reach a precision of 0.79 and a recall of 0.36, and let in 5.3 percent of strangers.
VGG-Face reaches 0.96 and 0.98, and lets in 2.4 percent. Our recall is low because the ratio test is strict, and a refused visitor simply uses the booking code.
Section 4 tests the homomorphic filter on Yale faces. Each Yale file name holds the angles of the light.
`regexp` reads the person number and the two light angles from the file name.
Harshness counts how many limits the larger angle passes: up to 20 degrees is near-frontal, up to 50 is moderate, and more is harsh.
Each photo is described twice: plain pixels with `zscore`, and with the homomorphic filter.
We test only people 20 to 38, enrolled with near-frontal light. With harsh light, the filter lifts accuracy from 23.9 to 77.9 percent. This is the clearest gain in the whole project.
Section 5 uses the FEI database, with photos from frontal to full profile. `feiShots` lists the FEI photo numbers in that order, and `turn` gives the level: 0 for frontal, up to 5 for full profile.
For each level, we enroll the frontal photos and test that turn. Eigenfaces fall from 50 percent at a small turn to 3 percent at full profile, while VGG-Face stays at 91 percent until nearly profile.
Section 6 simulates a mask and strong backlight on 150 test photos, while the enrolled photos stay normal.
`spoilers` holds the two changes: `paintMask`, and a darkening formula that squares the brightness and halves it, which crushes the shadows.
A mask defeats Eigenfaces, at 13 percent, and VGG drops to 82. Backlight gives 45 percent for Eigenfaces, against 100 for VGG.
Section 7 is the liveness test, on 50 clips: 10 real faces, 10 printed photos, 10 cut prints, 10 laptop screens and 10 phone screens.
Each clip is cut into up to four windows of 45 frames, starting at frames 1, 46, 91 and 136. A short clip is one window.
For each window: read the frames, find the face in the middle frame, cut out 45 faces, and save one row: the kind, the clip number, the blink result, and the 256 numbers of the texture histogram.
The texture averages must not be learned from the clips we test. So we split the clips into odd and even numbers: learn on one half, test on the other, then swap. This is two-fold testing.
`passed` has three columns: texture, blink, and both. `accumarray` with any says if any window of a clip passed, like a visitor allowed to retry. The mean over 10 clips gives the pass rate of each kind.
Real faces pass 80 percent of the time. Every printed photo and cut print is stopped. Screens are the hardest: 70 percent of monitor clips and 50 percent of phone clips get through.
The blink alone is fooled by most attacks, so the texture does most of the work.
Finally, the averages over all clips go into `models.mat`, together with the face template. This is the file the kiosk loads.
Section 8 measures speed on one real three-second clip, 5 times. `tic` starts the clock, and after each step, `toc` is saved.
The difference between two readings is the time of one step. Finding the face is the slowest step, at about 0.2 seconds.
Recording and showing 45 frames took 4.71 seconds, so a face check-in takes about 5.1 seconds in total. The booking-code lookup takes a tiny fraction of a millisecond.

## 46:21  10 · The datasets

All five datasets are public, which the brief allows. Georgia Tech gives us 750 photos of 50 people with labelled face boxes. FEI gives head turns, from frontal to profile.
Cropped Yale B gives the same faces under light from many angles. Two public video sets give real faces and attacks: printed photos, cut prints, laptop screens and phone screens.
In the proposal we planned to use our own faces; the report says openly that we used public data instead.
The data sits in the Kiosk Data folder and is not submitted, and no dataset face appears in the report or the slides. For the live demo, two of us put our own photos in the today folder.

## 47:08  11 · The report

Now the report. It follows the IEEE conference template, as the rubric requires. Here are the title and the five authors.
The abstract sums up everything: the problem, our solution, and the main numbers. Face finding works 99.7 percent of the time. Eigenfaces reach 78.1 percent for 5 people and 45.8 percent for 50.
The filter lifts harsh light from 23.9 to 77.9 percent. Liveness stops every printed photo, while screens remain the hardest attack.
The introduction has the five parts the template asks for: the statement of the problem, the motivation, the solution, the results and conclusions, and our contributions, scope and ethics.
Our research question is simple: is a method simple enough to write from the equations good enough for this job?
Related work places us next to other work: Viola and Jones, YOLO and today's tools for detection; Eigenfaces,
Fisherfaces and deep embeddings for recognition; homomorphic filtering for light; and texture and blink methods for liveness.
Figure 1 is the system design, the same pipeline we saw earlier, with the booking code on the side.
Table I says where every step comes from in the course, which is exactly what the doctor wants to see.
Section 3 describes each method in words and equations, with no code listings, as the template asks: face localization,
and then the homomorphic filter, with its equation and the values sigma 8, gamma low 0.7 and gamma high 1.4.
Then Eigenfaces with the ratio test, the two liveness features, the ready-made competitor, and the kiosk application.
Figure 2 is the kiosk screen, because the template says a project with a GUI should show it. Table II lists the public data.
Section 4 starts with the setup: Octave 11.1 on a laptop processor, 5 enrolled photos per person, fixed random seeds, and 20 random lists.
Then face finding, the growing list, and visitors versus strangers.
Figure 3 is the most important graph: accuracy as the list grows. Figure 4 shows the filter under changing light.
Table III gives the list numbers, and Table IV the liveness pass rates for each attack.
The text explains each result in words, as the template asks: what the number means, and why. The speed section covers every step, and compares the face path with the booking code.
Failure cases cover everything our proposal promised: head turn, glasses, mask and backlight.
The discussion ties the results together: a method that can be explained on one page works only in a narrow range.
Page 5 holds the liveness chart, the speed table, the failure table and the head-turn graph.
The conclusion gives our main ideas, the limitations, and future work.
The meta-discussion, which the template asks for, says what was hardest, what was easiest, and how we differ from the proposal: Octave instead of MATLAB, and public data instead of our own faces.
The report ends with the tool-use disclosure that the course policy requires, and the references. Every dataset and paper we used is cited.

## 50:47  12 · The slides

The deck has 10 slides, for a talk of about 10 to 15 minutes. Slide 1 is the title, the course and the team.
Slide 2 says who did what: one part per person. The owners are now filled in, and we will come back to this at the end.
Slide 3 is the problem: slow, repetitive, and not private.
Slide 4 shows the gap in existing approaches, and what we do instead.
Slide 5 gives our four ideas: consent first, two equal paths, only today's list, and the doctor's additions.
Slide 6 is the pipeline.
Slide 7 shows the inside of each step, and where it comes from in the course.
Slide 8 has the main results: the list graph, the liveness chart, and three key numbers.
Slide 9 is the conclusion and future work.
Slide 10 is the live demo plan: a face check-in, a printed photo against liveness, the booking code, and the list updating.

## 51:50  13 · What we used from the class

Here is where each idea comes from. Camera capture is from Assignment 2. The edge-direction histograms come from SIFT in Feature Extraction Part 2, and from Assignment 2.
The pyramid, correlation and the sliding window come from Feature Extraction and Lecture 8.
The Gaussian filter and the N8 neighbors come from Chapter 3, and the doctor's comment added the homomorphic filter and LBP.
Eigenfaces come from the linear algebra review and Assignment 1, and the ratio test from Assignment 3.
SSD and NCC come from Feature Extraction Part 3, the deep learning ideas from Lectures 4 to 6, and precision, recall and F1 from Lecture 3.

## 52:37  14 · The code rubric, box by box

The code rubric has seven boxes. Readability counts twice: every file starts with what it does and who wrote it, and there is a comment on every function and on each step.
Modularity: five files and 29 functions, with calls five levels deep.
Efficiency counts twice: about 380 lines of real code, one action per line, no repeated code, and tools that work on the whole picture at once.
Usability and correctness count twice: the kiosk does the whole job, it has five from-scratch methods, and every number in the report was measured.
Robustness: stopIf and runSafely turn every problem into a message, and extra clicks are ignored.
GUI counts twice: one neat window, with the camera, the message, the consent text, both paths, and the receptionist's list.
And the biggest box, half of the code grade: runs without errors. We tested 13 click-through scenarios with a hidden window, and ran all the experiments with no errors and no warnings.

## 53:45  15 · What the doctor may ask

In the oral exam, the doctor may ask us to change something live. Here is a table of the most likely changes, with the function, the line, and the edit. Recording time is in recordFrames, line 59.
The face finder's bar is line 15 of detectFace, and the face sizes are line 17. The recognition ratio is line 24 of matchFace, and the number of eigenfaces is line 16 of trainEigenfaces.
The light filter weights are line 8 of homomorphicFilter. The blink threshold is line 23 of blinkSeen. One liveness check can be switched off with a percent sign in onAgree.
The window size is line 9 of kiosk. To show the time of day, add datestr of now to the status on line 51 of checkIn. For longer names, widen the column on line 88 of updateScreen.
Practise each change once, run the kiosk, then undo it.
Be ready for questions too. Why A transpose A? Because it is only as big as the number of photos. Why flip the template? Because convolution flips it, and flipping back gives correlation.
What is from scratch? The face finder, the filter, Eigenfaces, LBP and the blink.
What if there is no camera? runSafely shows a calm message, with no crash. Why only today's list? For privacy, and because fewer people means fewer mistakes. Where does VGG-Face run?
Only in the experiments. Why Octave? It was our choice, and the report explains what changed because of it.

## 55:24  16 · Who owns what

Finally, who owns what. Slide 2 gives one part of the code to each of us, so the work is shared equally, as the rubric asks.
Each owner explains and changes their part, but the doctor can ask anyone about anything, so all of us must understand the whole system.
Hadi Hassan Sleiman, the team leader, owns Part 1, kiosk dot M: the screen, both check-in paths, the camera and the error handling.
Hadi must explain the flow in onAgree, the booking-code path, stopIf and runSafely, and how guidata keeps the list.
As leader, Hadi also coordinates the team, joins the five parts into one kiosk, opens the talk, and runs the live demo.
Islam Alshiss owns Part 2, findFace dot M. Islam must explain the edge directions in cells, why each cell is normalized, the sliding template and the flip,
the ten scales, the bar of 9, and how cells become pixels, plus the face-finding test with IoU.
Hashir Khan owns Part 3, recognizeFace dot M. Hashir must explain the homomorphic filter, Eigenfaces with A transpose A, the weights, the distance,
the ratio test, and how the today folder becomes the list, plus the results for list size, strangers and light.
Fahad Al-Thani owns Part 4, checkLiveness dot M.
Fahad must explain LBP bits and the histogram, SSD to the real and fake averages, the blink bands and NCC, why both checks are needed, and the liveness results for each attack.
Abdulrahman Alsheikh owns Part 5, experiments dot M.
Abdulrahman must explain how the tests run, the five datasets, the VGG-Face competitor, why the comparison is fair, precision, recall and F1, the speed test, and how models dot mat is made.
And everyone must know the basics: the pipeline, the doctor's three suggestions and where they are in the code, the main numbers, and how to run the kiosk.

## 57:32  17 · Before we submit

Last, the checklist. Upload the report, the slides and the zipped source code folder by Tuesday, November 17. Check our names on the report and on slides 1 and 2.
Before the demo, two of us put our own photos in the today folder; these are not part of the submission. Rehearse the demo, and let each of us practise one live change.
That is the whole project, from A to Z. Watch any chapter again whenever you need it, and practise explaining your part out loud. Good luck with the presentation!
