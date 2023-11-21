
clear all

%% settings

% conversion factors
scr.cmPerPix = 1/10;%scr.width / scr.xres;
scr.pixPerCm = 10;%scr.xres / scr.width;

visual.black = 0;
visual.white = 255;
visual.bgColor = (visual.black + visual.white) / 2;


%% stimulus parameters
noiseSD = 50;

sigma = 4 * scr.pixPerCm;
spatialFreq = 1/40;

widthOfGrid = ceil(50* scr.pixPerCm);
tiltInDegrees = 90;
radius2 = ceil(20* scr.pixPerCm);
sigma = 10*scr.pixPerCm;

 
contrast = 0.5;
im_i = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, contrast, widthOfGrid, noiseSD, sigma , radius2);
imshow(im_i)

n_contrast_lvls = 10;
contrast_lvls = exp(linspace(log(0.05), log(0.8), n_contrast_lvls));


noiseSD = 50;
im_all = [];
im_all2 = [];
for i = 1:n_contrast_lvls
    if i<=5
        im_all = [im_all, makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, contrast_lvls(i), widthOfGrid, noiseSD, sigma , radius2)];
    else
        im_all2 = [im_all2, makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, contrast_lvls(i), widthOfGrid, noiseSD, sigma , radius2)];
    end
end
im_all = [im_all;im_all2];
imshow(im_all)