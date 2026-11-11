% settings.m - every value the team may tune, all in one place.
% Consent-Based Smart Receptionist Kiosk, CMAI 480, Qatar University.
% Team: Alsheikh, Al-Thani, Sleiman, Alshiss, Khan.
function S = settings()
    S.faceSize = [80 60];        % face size given to Eigenfaces (rows, columns)
    S.textureSize = [120 90];    % face size given to LBP and blink
    S.eigenfaces = 100;          % how many eigenfaces we keep
    S.sigma = 8;                 % Gaussian width of the homomorphic filter
    S.gammaLow = 0.7;            % weight of slow light changes
    S.gammaHigh = 1.4;           % weight of face detail
    S.faceLevel = 0.4;           % blob threshold, as a fraction of the peak response
    S.minFaceResponse = 800;     % a weaker peak means nobody is in front of the camera
    S.eyeBand = [0.26 0.56];     % eye rows, as fractions of the face height
    S.restBand = [0.62 0.95];    % lower-face rows, used to compare with the eyes
    S.blinkLimit = 0.08;         % eyes must change this much more than the lower face
    S.textureLimit = 0;          % above this, the skin looks more real than fake
    S.matchRatio = 0.85;         % nearest person / next person; smaller is more sure
    S.captureFrames = 45;        % three seconds at 15 frames per second
    S.enrollFrames = 8;          % pictures saved when enrolling a visitor
end
