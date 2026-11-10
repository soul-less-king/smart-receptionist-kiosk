# Consent-Based Smart Receptionist Kiosk

CMAI 480 Computer Vision course project, Qatar University, Fall 2026, written in GNU Octave.
Team: Abdulrahman Alsheikh, Fahad Al-Thani, Hadi Sleiman, Islam Alshiss, Hashir Khan.

A visitor either agrees to a face scan or uses a booking code. With consent, the kiosk records 3 seconds of webcam video, finds the face with our own gradient-histogram template, checks that it is a live person (Local Binary Pattern texture plus an eye blink), corrects the light with a homomorphic filter and recognizes the visitor with our own Eigenfaces, comparing only with today's visitors. A ready-made VGG-Face model is used only in the experiments, as a competitor.

## Run the kiosk
Needs GNU Octave with the `image` and `image-acquisition` packages, and a webcam at `/dev/video0`.
1. Put photos of today's visitors in `Kiosk/today/Name_Code/`, for example `Kiosk/today/Hadi_1234/1.jpg` (at least two people).
2. In Octave: `cd Kiosk`, then `kiosk`.

## Re-run the experiments
In Octave: `cd Kiosk`, then `experiments` (about 50 minutes). It reads the public datasets in `Kiosk_Data/`, prints every number in the report and rebuilds `Kiosk/models.mat`.

## Folders
- `Kiosk/` - the code: `kiosk.m` (Part 1, the screen), `findFace.m` (Part 2), `recognizeFace.m` (Part 3), `checkLiveness.m` (Part 4), `experiments.m` (Part 5), plus `models.mat` and `vgg_conv.mat`.
- `Report/` - the IEEE report (LaTeX and PDF) and the slides.
- `submission/` - the files handed in.
- `Kiosk_Data/` - the public datasets used in the experiments, and cached work files.
- `Course_Material/` - course slides, assignments and the project brief.

## Not included
- `Kiosk_Data/model/vgg-face.mat` (1 GB) and `Kiosk_Data/gt/gt_db.zip` (127 MB): GitHub refuses files over 100 MB. The model is available from the VGG Face page (https://www.robots.ox.ac.uk/~vgg/software/vgg_face/); the archive's photos are already in `Kiosk_Data/gt/images/`.
- `vgg_conv.mat` here has exactly the same weights as the team's copy, without the unused training field `momentum`, so that it fits under the limit.
- Python and Node tool environments and temporary previews from `Kiosk_Data/cache/`.
- Student IDs were removed from the documents in this repository.

## Data sources
- Georgia Tech face database, A. V. Nefian: http://www.anefian.com/research/face_reco.htm
- FEI face database, C. E. Thomaz and G. A. Giraldi
- Cropped Extended Yale B, A. S. Georghiades, P. N. Belhumeur and D. J. Kriegman
- Web camera face liveness detection, UniqueData: https://huggingface.co/datasets/UniqueData/web-camera-face-liveness-detection
- Face anti-spoofing dataset, AxonData: https://huggingface.co/datasets/AxonData/face-anti-spoofing-dataset
- VGG-Face, O. M. Parkhi, A. Vedaldi and A. Zisserman
