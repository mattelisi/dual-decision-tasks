% Clear the workspace
close all;
clear;
sca;

% add custom functions 
addpath('./functions');

%----------------------------------------------------------------------
%                       Collect information
%----------------------------------------------------------------------
subjectID=input('participantID: ','s');
subjectAge=input('participant age: ','s');
subjectGender=input('participant gender: ','s');


%----------------------------------------------------------------------
%                       Display settings
%----------------------------------------------------------------------

scr.subDist = 80;   % subject distance (cm)
scr.width   = 570;  % monitor width (mm)

%----------------------------------------------------------------------
%                       Task settings
%----------------------------------------------------------------------

soa_range = [0.2, 0.6];
iti = 1; % inter trial interval
n_trials = 150;
n_trials_practice = 10;

%----------------------------------------------------------------------
%                       Initialize PTB
%----------------------------------------------------------------------

% Setup PTB with some default values
PsychDefaultSetup(2);

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
visual.white =255;%WhiteIndex(screenNumber);
visual.grey = floor(255/2);%visual.white / 2;
visual.black = 0; %BlackIndex(screenNumber);
visual.bgColor = visual.grey;

% Open the screen
%[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, visual.grey/255, [0 0 1800 1200], 32, 2); % debug
%[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, visual.grey/255, [1920 0 3840 1080], 32, 2); % debug
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, visual.grey/255, [], 32, 2);

% Flip to clear
Screen('Flip', scr.window);

% Query the frame duration
ifi = Screen('GetFlipInterval', scr.window);

% Set the text size
Screen('TextSize', scr.window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(scr.window);

% Get the centre coordinate of the scr.window
[scr.xCenter, scr.yCenter] = RectCenter(scr.windowRect);

% Get the heigth and width of screen [pix]
[scr.xres, scr.yres] = Screen('WindowSize', scr.window); 

% Set the blend funciton for the screen
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%----------------------------------------------------------------------
%                       Stimuli
%----------------------------------------------------------------------
ppd = va2pix(1,scr); % pixel per degree
visual.ppd  = ppd;

% fixation
visual.fix_size = 0.3*ppd;

% stimulus size and ececntricity
visual.stim_size = 4*ppd;
visual.stim_ecc = 2.5*ppd;
visual.stim_rects = [CenterRectOnPoint([0,0, visual.stim_size, visual.stim_size], scr.xCenter-visual.stim_ecc, scr.yCenter)', ...
    CenterRectOnPoint([0,0, visual.stim_size, visual.stim_size], scr.xCenter+visual.stim_ecc, scr.yCenter)'];

% contrast levels
visual.n_contrast_lvls = 10;
visual.contrast_lvls = exp(linspace(log(0.05), log(0.8), visual.n_contrast_lvls));

%other parameters
visual.noiseSD = 50;
visual.spatialFreq = 2.5/ppd;
visual.widthOfGrid = ceil(visual.stim_size);
visual.tiltInDegrees = 90;
visual.radius2 = ceil(visual.stim_size*2/5);
visual.sigma = visual.stim_size/5;

% stimulus duration
visual.stim_dur = 0.2;

% noise refresh frequency
visual.noise_temp_freq = 30; % Hz
visual.noise_interval = 1/visual.noise_temp_freq; % sec
visual.stim_n_frames = round(visual.stim_dur / visual.noise_interval);

% placeholder locations
visual.dots_dy = (visual.stim_size/2)*1.5;
visual.dots_xy = [scr.xCenter-visual.stim_ecc, scr.xCenter+visual.stim_ecc; ...
    scr.yCenter-visual.dots_dy, scr.yCenter-visual.dots_dy];

visual.dots_col_1 =(visual.white/255)/3;
visual.dots_col_2 = ([246, 14,0; 0 160 0]'/255);
visual.dots_size = 1*ppd;

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames')
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

%----------------------------------------------------------------------
%                 Prepare for saving data
%----------------------------------------------------------------------

% Make a directory for the results
resultsDir = [pwd '/data/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end

% prep data header
datFid = fopen([resultsDir subjectID], 'w');
fprintf(datFid, 'id\tage\tgender\ttrial\tdecision\tcontrast\tresponse\taccuracy\tRT\n');

%----------------------------------------------------------------------
%                       Practice trials
%----------------------------------------------------------------------



%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

DrawFormattedText(scr.window, 'Welcome to our experiment \n\n < add instructions here > \n\n Press Any Key To Start',...
    'center', 'center', visual.black);
Screen('Flip', scr.window);
KbStrokeWait;

HideCursor; % hide mouse cursor

% Staircase settings
contrast_index = visual.n_contrast_lvls;
constrast_value = visual.contrast_lvls(contrast_index);

% Animation loop: we loop for the total number of trials
for t = 1:n_trials
    
    [dataline1, first_correct] = runSingleTrialPreTest(scr, visual, leftKey, rightKey, soa_range, constrast_value);
    
    % UPDATE STAIRCASE SETTING %-------------------------------------
    if  first_correct==1
        contrast_index = contrast_index-1;
        if contrast_index<1
            contrast_index=1;
        end
    elseif first_correct==0
        contrast_index = contrast_index+3;
        if contrast_index > visual.n_contrast_lvls
            contrast_index = visual.n_contrast_lvls;
        end
    end
    constrast_value = visual.contrast_lvls(contrast_index);

    % save data
    dataline1 = sprintf('%s\t%s\t%s\t%i\t%s', subjectID, subjectAge, subjectGender, t, dataline1);
    fprintf(datFid, dataline1);
    
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    Screen('Flip', scr.window);
    WaitSecs(iti)
        
end

% close data file
fclose(datFid);

% End of experiment screen. We clear the screen once they have made their
% response
DrawFormattedText(scr.window, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', visual.black);
Screen('Flip', scr.window);
KbStrokeWait;
sca;
