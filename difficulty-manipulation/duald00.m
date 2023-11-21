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
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, visual.grey/255, [0 0 1800 1200], 32, 2); % debug
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, visual.grey/255, [1920 0 3840 1080], 32, 2); % debug
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, visual.grey/255, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[scr.xCenter, scr.yCenter] = RectCenter(windowRect);

% Get the heigth and width of screen [pix]
[scr.xres, scr.yres] = Screen('WindowSize', window); 

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%----------------------------------------------------------------------
%                       Stimuli
%----------------------------------------------------------------------
ppd = va2pix(1,scr); % pixel per degree

% fixation
fix_size = 0.3*ppd;

% stimulus size and ececntricity
stim_size = 4*ppd;
stim_ecc = 2.5*ppd;
stim_rects = [CenterRectOnPoint([0,0, stim_size, stim_size], scr.xCenter-stim_ecc, scr.yCenter)', ...
    CenterRectOnPoint([0,0, stim_size, stim_size], scr.xCenter+stim_ecc, scr.yCenter)'];

% contrast levels
n_contrast_lvls = 10;
contrast_lvls = exp(linspace(log(0.05), log(0.8), n_contrast_lvls));

%other parameters
noiseSD = 50;
spatialFreq = 2.5/ppd;
widthOfGrid = ceil(stim_size);
tiltInDegrees = 90;
radius2 = ceil(stim_size*2/5);
sigma = stim_size/5;

% stimulus duration
stim_dur = 0.2;

% placeholder locations
dots_dy = (stim_size/2)*1.05;
dots_xy = [scr.xCenter-stim_ecc, scr.xCenter-stim_ecc, scr.xCenter+stim_ecc, scr.xCenter+stim_ecc; ...
    scr.yCenter-dots_dy, scr.yCenter+dots_dy, scr.yCenter-dots_dy, scr.yCenter+dots_dy];

dots_col_1 =(visual.white/255)/3;
dots_col_2 = ([164, 14,0;164, 14,0; 0 103 0; 0 103 0]'/255) * 1.5;
dots_size = 0.2*ppd;

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

DrawFormattedText(window, 'Welcome to our experiment \n\n < add instructions here > \n\n Press Any Key To Start',...
    'center', 'center', visual.black);
Screen('Flip', window);
KbStrokeWait;

HideCursor; % hide mouse cursor

% Staircase settings
contrast_index = n_contrast_lvls;
constrast_value = contrast_lvls(contrast_index);

% Animation loop: we loop for the total number of trials
for t = 1:n_trials
    
    % DECISION 1 % --------------------------------------------------------
    
    % --------------------------------------------------------
    % trial settings
    soa = soa_range(1)+rand(1)*(soa_range(2)-soa_range(1));
    soa2 = soa_range(1)+rand(1)*(soa_range(2)-soa_range(1));
    side = round(rand(1,1)) + 1;
    
    % --------------------------------------------------------
    % fixation spot
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_1, [], 2);
    fix_on = Screen('Flip', window);
    
    
    % --------------------------------------------------------
    % make images 
    
    % 2 pre-mask
    im_01 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    im_02 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    pre_mask(1) = Screen('MakeTexture', window, im_01);
    pre_mask(2) = Screen('MakeTexture', window, im_02);
    
    % target & 1 noise
    im_01 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, constrast_value, widthOfGrid, noiseSD, sigma , radius2); %signal
    im_02 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    SN(side) = Screen('MakeTexture', window, im_01); 
    SN(2-side+1) = Screen('MakeTexture', window, im_02);
    
     % 2 post-mask
    im_01 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    im_02 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    post_mask(1) = Screen('MakeTexture', window, im_01);
    post_mask(2) = Screen('MakeTexture', window, im_02);
    
    
    % --------------------------------------------------------
    % stimulus sequence
    Screen('DrawTextures', window, pre_mask, [], stim_rects);
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_1, [], 2);
    t_pre = Screen('Flip', window, fix_on + soa);
    
    Screen('DrawTextures', window, SN, [], stim_rects);
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_1, [], 2);
    t_sn = Screen('Flip', window, t_pre + stim_dur);
    
    Screen('DrawTextures', window, post_mask, [], stim_rects);
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_1, [], 2);
    t_post = Screen('Flip', window, t_sn + stim_dur);
    
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_1, [], 2);
    t_off = Screen('Flip', window, t_post + stim_dur);
        
    % --------------------------------------------------------
    % wait for response 
    resp_right = NaN;
   while isnan(resp_right)
        [keyisdown, secs, keycode] = KbCheck(-1);
        if keyisdown && (keycode(leftKey) || keycode(rightKey))
            tResp = secs - t_sn;
            if keycode(rightKey)
                resp_right = 1;
            elseif keycode(leftKey)
                 resp_right = 0;
            end
        end
   end
    
   if side==2
       if resp_right==1
           accuracy = 1;
       else
           accuracy = 0;
       end
   else
       if resp_right==0
           accuracy = 1;
       else
           accuracy = 0;
       end
   end
   
   if accuracy == 1
       side2 = 2;
   else
       side2 = 1;
   end
   
   first_correct = accuracy;
   
    % write data line to file
    dataline = sprintf('%s\t%s\t%s\t%i\t%i\t%2f\t%i\t%i\t%2f\n', subjectID, subjectAge, subjectGender, t, 1, constrast_value, resp_right, accuracy, tResp);
    fprintf(datFid, dataline);
    
    % DECISION 2 % --------------------------------------------------------
    
    % --------------------------------------------------------
    % fixation spot
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_2, [], 2);
    fix_on = Screen('Flip', window);
    
    
    % --------------------------------------------------------
    % make images 
    
    % 2 pre-mask
    im_01 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    im_02 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    pre_mask(1) = Screen('MakeTexture', window, im_01);
    pre_mask(2) = Screen('MakeTexture', window, im_02);
    
    % target & 1 noise
    im_01 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, constrast_value, widthOfGrid, noiseSD, sigma , radius2); %signal
    im_02 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    SN(side2) = Screen('MakeTexture', window, im_01); 
    SN(2-side2+1) = Screen('MakeTexture', window, im_02);
    
     % 2 post-mask
    im_01 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    im_02 = makeNoisyStimulus(visual,tiltInDegrees,spatialFreq, 0, widthOfGrid, noiseSD, sigma , radius2);
    post_mask(1) = Screen('MakeTexture', window, im_01);
    post_mask(2) = Screen('MakeTexture', window, im_02);
    
    
    % --------------------------------------------------------
    % stimulus sequence
    Screen('DrawTextures', window, pre_mask, [], stim_rects);
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_2, [], 2);
    t_pre = Screen('Flip', window, fix_on + soa2);
    
    Screen('DrawTextures', window, SN, [], stim_rects);
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_2, [], 2);
    t_sn = Screen('Flip', window, t_pre + stim_dur);
    
    Screen('DrawTextures', window, post_mask, [], stim_rects);
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_2, [], 2);
    t_post = Screen('Flip', window, t_sn + stim_dur);
    
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', window, dots_xy, dots_size, dots_col_2, [], 2);
    t_off = Screen('Flip', window, t_post + stim_dur);
        
    % --------------------------------------------------------
    % wait for response 
    resp_right = NaN;
   while isnan(resp_right)
        [keyisdown, secs, keycode] = KbCheck(-1);
        if keyisdown && (keycode(leftKey) || keycode(rightKey))
            tResp = secs - t_sn;
            if keycode(rightKey)
                resp_right = 1;
            elseif keycode(leftKey)
                resp_right = 0;
            end
        end
   end
    
   if side==2
       if resp_right==1
           accuracy = 1;
       else
           accuracy = 0;
       end
   else
       if resp_right==0
           accuracy = 1;
       else
           accuracy = 0;
       end
   end
   
   if accuracy == 1
       side2 = 2;
   else
       side2 = 1;
   end
   
   
    % write data line to file
    dataline = sprintf('%s\t%s\t%s\t%i\t%i\t%2f\t%i\t%i\t%2f\n', subjectID, subjectAge, subjectGender, t, 2, constrast_value, resp_right, accuracy, tResp);
    fprintf(datFid, dataline);
    
    
    % UPDATE STAIRCASE SETTING %-------------------------------------
    if  first_correct==1
        contrast_index = contrast_index-1;
        if contrast_index<1
            contrast_index=1;
        end
    elseif first_correct==0
        contrast_index = contrast_index+3;
        if contrast_index > n_contrast_lvls
            contrast_index = n_contrast_lvls;
        end
    end
    constrast_value = contrast_lvls(contrast_index);
    
    
    Screen('FillOval', window, visual.black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], scr.xCenter, scr.yCenter));
    Screen('Flip', window);
    WaitSecs(iti)
        
end

% close data file
fclose(datFid);

% End of experiment screen. We clear the screen once they have made their
% response
DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', visual.black);
Screen('Flip', window);
KbStrokeWait;
sca;
