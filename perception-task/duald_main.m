% Clear the workspace
close all;
clear;
sca;

% add custom functions 
addpath('functions');

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));

%----------------------------------------------------------------------
%                       Collect information
%----------------------------------------------------------------------
FileFound = 0;

while ~FileFound
    subjectID=input('participantID: ','s');
    subjectAge=input('participant age: ','s');
    subjectGender=input('participant gender: ','s');
    
    if IsWin
        resdir=[pwd '\data\' subjectID '\']; %sprintf('data\%s',subjectID);
    else
        resdir=[pwd '/data/' subjectID '/']; %sprintf('data/%s',subjectID);
    end
    datfile_info = [resdir subjectID '_th.mat'];
    
    if exist(resdir,'file')==7 && exist(datfile_info,'file')==2
        load(datfile_info);
        disp('              OK, files found!');
        FileFound = 1;
    else
        disp('              I cannot find the files: please double check the "participanID" and the content of the "data" folder.');
    end
end

% select session type and set name accordingly
% note: current_session_type==1 -> mixed difficulties
if isfield(th, 'session')
    th.session = th.session+1;
    if th.session_type(th.session-1)==0
        current_session_type = 1;
    elseif th.session_type(th.session-1)==1
        current_session_type = 0;
    end  
    th.session_type = [th.session_type, current_session_type];
else
    th.session = 1;
    current_session_type = binornd(1,0.5,1,1);
    th.session_type = current_session_type;
end

datfile = [resdir subjectID '_part' num2str(th.session)];

%----------------------------------------------------------------------
%                 Prepare for saving data
%----------------------------------------------------------------------

% prep data header
datFid = fopen( datfile, 'w');
fprintf(datFid, 'id\tage\tgender\ttrial\tdecision\tcontrast\tside\tresponse\taccuracy\tRT\tconf\tconf_RT\tcondition\n');
    
%----------------------------------------------------------------------
%                       Display settings
%----------------------------------------------------------------------

scr.subDist = 80;   % subject distance (cm)
scr.width   = 570;  % monitor width (mm)

%----------------------------------------------------------------------
%                       Task settings
%----------------------------------------------------------------------

soa_range = [0.4, 0.6];
iti = 0.5; % inter trial interval
n_trials = 150; % it should be divisible by 5
n_trials_practice = 10;

% simulus selection (based on session type)
if current_session_type==1
    stim_tab = createTrialMatrix(th, n_trials);
else
    stim_tab = repmat(th.single_index, n_trials, 2);
end
disp(['launching condition: ',num2str(current_session_type)]);

% if you want also self-report ratings after each decision [1, 2]
collect_confidence = [1, 1]; 

%----------------------------------------------------------------------
%                       Initialize PTB
%----------------------------------------------------------------------

% Setup PTB with some default values
PsychDefaultSetup(2);

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

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
scr.ifi = ifi;

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

visual.textSize = round(0.5*ppd);

% fixation
visual.fix_size = 0.1*ppd;

% stimulus size and ececntricity
visual.stim_size = 4*ppd;
visual.stim_ecc = 2.25*ppd;
visual.stim_rects = [CenterRectOnPoint([0,0, visual.stim_size, visual.stim_size], scr.xCenter-visual.stim_ecc, scr.yCenter)', ...
    CenterRectOnPoint([0,0, visual.stim_size, visual.stim_size], scr.xCenter+visual.stim_ecc, scr.yCenter)'];

% contrast levels
visual.n_contrast_lvls = 20;
visual.contrast_lvls = exp(linspace(log(0.025), log(0.8), visual.n_contrast_lvls));

% % sanity check contrast levels in RGB
% black = visual.black;
% white = visual.white;
% gray = visual.bgColor; % (black + white) / 2;
% absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
% uint8(visual.contrast_lvls*absoluteDifferenceBetweenWhiteAndGray)

%other parameters
visual.noiseSD = 50;
visual.spatialFreq = 2.5/ppd;
visual.widthOfGrid = ceil(visual.stim_size);
visual.tiltInDegrees = 90;
visual.radius2 = ceil(visual.stim_size*2/5);
visual.sigma = visual.stim_size/5;

% stimulus duration
visual.stim_dur = 0.1;

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
%                       Practice trials
%----------------------------------------------------------------------

DrawFormattedText(scr.window, 'Welcome to our experiment \n\n \n\n Press any key to start the practice',...
    'center', 'center', visual.black);
Screen('Flip', scr.window);
WaitSecs(0.2);
KbStrokeWait;

HideCursor; % hide mouse cursor


for t = 1:n_trials_practice
    
    % run trials
    [~, ~, first_correct, second_correct] = runSingleTrial(scr, visual, leftKey, rightKey, soa_range,visual.contrast_lvls(stim_tab(Sample(1:n_trials),:)), collect_confidence);
    
    Screen('Flip', scr.window);
    
    % feedback
    if first_correct==1 && second_correct==1
        DrawFormattedText(scr.window, 'Well done! both answers were correct. \n Press a key to continue',...
            'center', 'center', visual.black);
        Screen('Flip', scr.window);
        KbStrokeWait;
        
    elseif first_correct==1 && second_correct==0
        
        DrawFormattedText(scr.window, 'The 1st answer was correct, but you made an error in the 2nd. \n Press a key to continue',...
            'center', 'center', visual.black);
        Screen('Flip', scr.window);
        KbStrokeWait;
        
    elseif first_correct==0 && second_correct==1
        
        DrawFormattedText(scr.window, 'The 2nd answer was correct, but you made an error in the 1st. \n Press a key to continue',...
            'center', 'center', visual.black);
        Screen('Flip', scr.window);
        KbStrokeWait;
    
    elseif first_correct==0 && second_correct==0
        
        DrawFormattedText(scr.window, 'Both answers were wrong... \n Press a key to continue',...
            'center', 'center', visual.black);
        Screen('Flip', scr.window);
        KbStrokeWait;
        
    end
        
end

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

DrawFormattedText(scr.window, 'Practice finished! \n\n Press any key to begin the experiment \n\n From now on giving correct answers will increase your chance of winning the prize.',...
    'center', 'center', visual.black);
Screen('Flip', scr.window);
KbStrokeWait;

HideCursor; % hide mouse cursor


% Animation loop: we loop for the total number of trials
for t = 1:n_trials
    
    [dataline1, dataline2, first_correct, second_correct] = runSingleTrial(scr, visual, leftKey, rightKey, soa_range,visual.contrast_lvls(stim_tab(t,:)), collect_confidence);

    % save data
    dataline1 = sprintf('%s\t%s\t%s\t%i\t%s\t%i\n', subjectID, subjectAge, subjectGender, t, dataline1, current_session_type);
    fprintf(datFid, dataline1);
    
    dataline2 = sprintf('%s\t%s\t%s\t%i\t%s\t%i\n', subjectID, subjectAge, subjectGender, t, dataline2, current_session_type);
    fprintf(datFid, dataline2);
    
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    Screen('Flip', scr.window);
    WaitSecs(iti);
        
end

% close data file
fclose(datFid);


% End of experiment screen. We clear the screen once they have made their
% response
message_string = ['Experiment Finished! \n\n Your score for this part is ', num2str(sum(ACC )), ' out of ', num2str(length(ACC )), '. \n\n Press Any Key To Exit'];
DrawFormattedText(scr.window, message_string,...
    'center', 'center', visual.black);
Screen('Flip', scr.window);

% -------------------------------------------------------------------------
% goodbye
KbStrokeWait;
sca;

