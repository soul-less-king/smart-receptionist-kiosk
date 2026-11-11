# Consent-Based Smart Receptionist Kiosk

CMAI 480 Computer Vision course project, Qatar University, Fall 2026 (Dr. Khalil), written in GNU Octave.
Team: Abdulrahman Alsheikh, Fahad Al-Thani, Hadi Sleiman (team leader), Islam Alshiss, Hashir Khan.

A visitor either agrees to a face scan or uses a booking code. With consent, the kiosk records 3 seconds of webcam video, finds the face with our own gradient-histogram template, checks that it is a live person (Local Binary Pattern texture plus an eye blink), corrects the light with a homomorphic filter and recognizes the visitor with our own Eigenfaces, comparing only with today's visitors. A ready-made VGG-Face model is used only in the experiments, as a competitor.

## The two folders

| Folder | Submit it? | What is inside |
|---|---|---|
| [`1_SUBMIT_TO_PROFESSOR/`](1_SUBMIT_TO_PROFESSOR) | **Yes: this is the whole submission** | the report, the slides and the source code |
| [`2_NOT_SUBMITTED/`](2_NOT_SUBMITTED) | **No: never submit anything from here** | working copy, datasets, test files, report source, course material, proposal, study video |

### `1_SUBMIT_TO_PROFESSOR/`: what we hand in (due Tuesday, November 17, 2026)

| File | What it is |
|---|---|
| `report.pdf` | the report, in the IEEE conference template |
| `presentation.pptx` | the slides (10 slides; slide 2 says who owns which part) |
| `source_code/kiosk.m` | Part 1: the screen, consent, both check-in paths, the receptionist's list |
| `source_code/findFace.m` | Part 2: finds the face and cuts it out |
| `source_code/recognizeFace.m` | Part 3: light correction (homomorphic filter) and Eigenfaces |
| `source_code/checkLiveness.m` | Part 4: the texture (LBP) and blink liveness checks |
| `source_code/experiments.m` | Part 5: every test in the report; also makes `models.mat` |
| `source_code/models.mat` | the face template and the texture averages that the kiosk loads |
| `source_code/today/` | empty; today's visitor photos go here as `today/Name_Code/*.jpg` |

Upload `report.pdf`, `presentation.pptx` and the zipped `source_code` folder. The copies in this public repository have the student IDs removed; the copies with IDs, ready to upload, are on the team leader's laptop (`projectCV/submission/` and `projectCV/CMAI480_Smart_Receptionist_Kiosk_Submission.zip`).

### `2_NOT_SUBMITTED/`: for the team only

| Folder | What it is | Why it is not submitted |
|---|---|---|
| `Kiosk/` | the same five `.m` files and `models.mat`, plus `vgg_conv.mat` (the competitor's weights) | working copy for running `experiments.m` with the datasets |
| `Kiosk_Data/` | the public datasets, and our work files in `cache/`: result logs, the no-webcam GUI test, report and slide build scripts, code backups | about 1.5 GB of public data and internal files |
| `Report_source/` | `report.tex` and the screen picture used in the report | we submit the PDF |
| `Course_Material/` | lecture slides, assignments, the project brief and the rubric | course reference only |
| `Proposal_and_feedback/` | the one-page summary we sent and Dr. Khalil's reply | phase 1 documents |
| `Study_Video/` | a narrated walkthrough of the whole project (every function, line by line), with a chapter list and a transcript | for the team to study before the oral exam |

## Run the kiosk
Needs GNU Octave with the `image` and `image-acquisition` packages, and a webcam at `/dev/video0` (Linux).
1. Put photos of today's visitors in `source_code/today/Name_Code/`, for example `today/Hadi_1234/1.jpg`, for at least two people.
2. In Octave: `cd source_code`, then `kiosk`.

## Re-run the experiments
In Octave: `cd 2_NOT_SUBMITTED/Kiosk`, then `experiments` (about 50 minutes). It reads the datasets in `2_NOT_SUBMITTED/Kiosk_Data/`, prints every number in the report and rebuilds `models.mat`. Without the datasets (as in the submitted folder) it prints a short message and stops.

## Who owns which part (slide 2)

| Part | File | Owner |
|---|---|---|
| 1 | `kiosk.m` | Hadi Sleiman (team leader) |
| 2 | `findFace.m` | Islam Alshiss |
| 3 | `recognizeFace.m` | Hashir Khan |
| 4 | `checkLiveness.m` | Fahad Al-Thani |
| 5 | `experiments.m` | Abdulrahman Alsheikh |

Every member must still be able to explain and change any part of the code in the oral exam.

## Main results (from the report)
- Face found (IoU of at least 0.5): 99.7%, mean IoU 0.82.
- Top-1 accuracy as today's list grows from 5 to 50 people: Eigenfaces 78.1% to 45.8%, VGG-Face 99.7% to 99.5%.
- Harsh side light: 23.9% without and 77.9% with the homomorphic filter.
- Liveness (both checks): real faces 80% pass; printed photos and cut prints 0%; laptop monitor 70%; phone 50%.
- A face check-in takes about 5.1 s, most of it recording the 3-second video.

## Not included in this repository
- `Kiosk_Data/model/vgg-face.mat` (1 GB) and `Kiosk_Data/gt/gt_db.zip` (127 MB): GitHub refuses files over 100 MB. The model is available from the VGG Face page (https://www.robots.ox.ac.uk/~vgg/software/vgg_face/); the archive's photos are already in `Kiosk_Data/gt/images/`.
- `vgg_conv.mat` here has exactly the same weights as the team's copy, without the unused training field `momentum`, so that it fits under the limit.
- Tool environments and temporary previews from `Kiosk_Data/cache/`.
- Student IDs were removed from the documents in this repository.

## Data sources
- Georgia Tech face database, A. V. Nefian: http://www.anefian.com/research/face_reco.htm
- FEI face database, C. E. Thomaz and G. A. Giraldi
- Cropped Extended Yale B, A. S. Georghiades, P. N. Belhumeur and D. J. Kriegman
- Web camera face liveness detection, UniqueData: https://huggingface.co/datasets/UniqueData/web-camera-face-liveness-detection
- Face anti-spoofing dataset, AxonData: https://huggingface.co/datasets/AxonData/face-anti-spoofing-dataset
- VGG-Face, O. M. Parkhi, A. Vedaldi and A. Zisserman
