% Clear the workspace
close all;
clear;
sca;

% add custom functions 
addpath('functions');

%----------------------------------------------------------------------
%                       Collect information
%----------------------------------------------------------------------
sj.subjectID=input('participantID: ','s');
sj.subjectAge=input('participant age: ','s');
sj.subjectGender=input('participant gender: ','s');

%----------------------------------------------------------------------
%                       Display settings
%----------------------------------------------------------------------

scr.subDist = 80;   % subject distance (cm)
scr.width   = 570;  % monitor width (mm)

%----------------------------------------------------------------------
%                       Task settings
%----------------------------------------------------------------------

iti = 1; % inter trial interval
n_trials = 150;
n_trials_practice = 5;
collect_confidence = [1, 1]; % if you want also self-report ratings after each decision [1, 2]

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
scr.screenNumber = max(Screen('Screens'));

% Define black, white and grey
visual.white =255;%WhiteIndex(screenNumber);
visual.grey = floor(255/2);%visual.white / 2;
visual.black = 0; %BlackIndex(screenNumber);
visual.bgColor = visual.grey;

% Open the screen
%[scr.window,  scr.windowRect] = PsychImaging('OpenWindow', scr.screenNumber, visual.grey/255, [0 0 1800 1200], 32, 2); % debug
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.screenNumber, visual.grey/255, [], 32, 2);

% Flip to clear
Screen('Flip',  scr.window);

% Query the frame duration
ifi = Screen('GetFlipInterval',  scr.window);

% Set the text size
Screen('TextSize', scr.window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority( scr.window);

% Get the centre coordinate of the window
[scr.xCenter, scr.yCenter] = RectCenter(scr.windowRect);

% Get the heigth and width of screen [pix]
[scr.xres, scr.yres] = Screen('WindowSize',  scr.window); 

% Set the blend funciton for the screen
Screen('BlendFunction',  scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%----------------------------------------------------------------------
%                       Stimuli
%----------------------------------------------------------------------
ppd = va2pix(1,scr); % pixel per degree
visual.ppd  = ppd;

visual.textSize = round(0.5*ppd);

% stimulus size and ececntricity
% img origina lsize 2560 x 1536
% height is 0.6 times width
visual.stim_size = 4*ppd;
visual.stim_ecc = 4*ppd;
visual.stim_rects = [CenterRectOnPoint([0,0, visual.stim_size, round(0.6667*visual.stim_size)], scr.xCenter-visual.stim_ecc, scr.yCenter)', ...
    CenterRectOnPoint([0,0, visual.stim_size, round(0.6667*visual.stim_size)], scr.xCenter+visual.stim_ecc, scr.yCenter)'];

% placeholder locations
visual.dots_dy = (visual.stim_size/2)*1.05;
visual.dots_xy = [scr.xCenter-visual.stim_ecc, scr.xCenter+visual.stim_ecc; ...
    scr.yCenter-visual.dots_dy, scr.yCenter-visual.dots_dy];

visual.dots_col_1 =(visual.white/255)/3;
visual.dots_col_2 = ([246, 14,0; 0 160 0]'/255);
visual.dots_size = 1*ppd;

visual.names_locations = [scr.xCenter-visual.stim_ecc, scr.yCenter+round(visual.stim_size/2);...
    scr.xCenter+visual.stim_ecc, scr.yCenter+round(visual.stim_size/2)];

% load list of countries
parent_dir = pwd;
if IsWin 
    list_countries = load([parent_dir '\country_data/list_countries_complete_updated.mat']);
    flags_path = [parent_dir '\country_data\Flags\'];
else
    list_countries = load([parent_dir '/country_data/list_countries_complete_updated.mat']);
    flags_path = [parent_dir '/country_data/Flags/'];
end

% % Convert the cell array to a table
% % Replace 'Column1', 'Column2', etc., with appropriate column names
% columnNames = {'country', 'flag_filename', 'Column3', 'GSP', 'Column5'};
% list_countries_table = cell2table(list_countries.list_countries_complete, 'VariableNames', columnNames);
% 
% % Write the table to a CSV file
% filename = 'list_countries_complete.csv';
% writetable(list_countries_table, filename);

% choose(195,2) = 18915
% list_countries.numList
% list_countries.wordLists
% list_countries.list_countries_complete

numCountries = length(list_countries.wordLists);
% Preallocate memory for country_pairs
% Total pairs = n*(n-1)/2 (since we are avoiding duplicate pairs)
totalPairs = numCountries * (numCountries - 1) / 2;
country_pairs = cell(totalPairs, 7);

pairCounter = 1;
for i = 1:numCountries
    for j = i+1:numCountries  % Start j from i+1 to avoid duplicates
        country1 = list_countries.wordLists{i, 1};
        flag1 = list_countries.wordLists{i, 2};
        gdp1 = list_countries.numList(i);

        country2 = list_countries.wordLists{j, 1};
        flag2 = list_countries.wordLists{j, 2};
        gdp2 = list_countries.numList(j);

        % Store the details in the preallocated array
        country_pairs{pairCounter, 1} = country1;
        country_pairs{pairCounter, 2} = flag1;
        country_pairs{pairCounter, 3} = log(gdp1);
        country_pairs{pairCounter, 4} = country2;
        country_pairs{pairCounter, 5} = flag2;
        country_pairs{pairCounter, 6} = log(gdp2);
        country_pairs{pairCounter, 7} = abs(log(gdp1) - log(gdp2));
        
        pairCounter = pairCounter + 1;
    end
end

% histogram(([country_pairs{:,7}]))
% scatter([country_pairs{:,3}], [country_pairs{:,6}])
% hold on
% plot([1 10],[1 10],'-b')
% hold off

% all([country_pairs{:,3}]>[country_pairs{:,6}])% OK

% Sort the country_pairs array based on the 7th column (absolute log difference)
% in ascending order
country_pairs = sortrows(country_pairs, 7);

% staircase settings
gdp_step = 0.5; % initial stepsize, get halved twice after 10 trials
gdp_diff = 1 + randn(1)*0.125; % randomized initial value

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
if IsWin
    resultsDir = [pwd '\data\'];
    if exist(resultsDir, 'dir') < 1
        mkdir(resultsDir);
    end
else
    resultsDir = [pwd '/data/'];
    if exist(resultsDir, 'dir') < 1
        mkdir(resultsDir);
    end
end

% prep data header
datFid = fopen([resultsDir sj.subjectID], 'w');
fprintf(datFid, 'date\tid\tage\tgender\ttrial\tdecision\tcountry_1\tlog_gdp_1\tcountry_2\tlog_gdp_2\trr\taccuracy\tRT\tconf\tconf_RT\n');

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
    
    % -----
    % select stimuli
    [pair1, ~] = selectByDifficulty(country_pairs, 4 + randn(1)*0.5);
    [pair2, ~] = selectByDifficulty(country_pairs, 4 + randn(1)*0.5);
    
    % run trials
    [~, ~, first_correct, second_correct] = runSingleTrial(scr, visual, pair1, pair2, flags_path, leftKey, rightKey, collect_confidence);
    
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

all_answers = [];

% Animation loop: we loop for the total number of trials
for t = 1:n_trials
    
    % -----
    % select stimuli
    [pair1, country_pairs] = selectByDifficulty(country_pairs, gdp_diff);
    [pair2, country_pairs] = selectByDifficulty(country_pairs, gdp_diff + randn(1)*0.125);
    
    % run trials
    [dataline1, dataline2, first_correct, second_correct] = runSingleTrial(scr, visual, pair1, pair2, flags_path, leftKey, rightKey, collect_confidence);
    
    % UPDATE STAIRCASE SETTING %-------------------------------------
    gdp_range = [min([country_pairs{:,7}]), max([country_pairs{:,7}])];
    if  first_correct==1
        gdp_diff = gdp_diff-gdp_step;
        if gdp_diff < gdp_range(1)
            gdp_diff=gdp_range(1);
        end
    elseif first_correct==0
        gdp_diff = gdp_diff+3*gdp_step;
        if gdp_diff > gdp_range(2)
            gdp_diff=gdp_range(2);
        end
    end
    
    % adjust step
    if(gdp_step==0.5 && t>=10)
        gdp_step = gdp_step/2;
    elseif(gdp_step==0.5/2 && t>=20)
        gdp_step = gdp_step/2;
    end
    
    % write data to file
    dataline1 = sprintf('%s\t%s\t%s\t%s\t%i\t%s', date, sj.subjectID, sj.subjectAge, sj.subjectGender, t, dataline1);
    fprintf(datFid, dataline1);
    
    dataline2 = sprintf('%s\t%s\t%s\t%s\t%i\t%s', date, sj.subjectID, sj.subjectAge, sj.subjectGender, t, dataline2);
    fprintf(datFid, dataline2);
    
    % keep track of accuracy for final feedback
    all_answers = [all_answers, first_correct, second_correct];
    
    if mod(t,25)==0
        DrawFormattedText(scr.window, 'Need a break? \n\n Press any key to continue','center', 'center', visual.black);
        Screen('Flip', scr.window);
        KbStrokeWait;
    else
        Screen('Flip', scr.window);
        WaitSecs(iti);
    end
        
end

% close data file
fclose(datFid);

% End of experiment screen. We clear the screen once they have made their
% response
message_string = ['Experiment Finished! \n\n Your final score is ', num2str(sum(all_answers)), ' out of ', num2str(length(all_answers)), '. \n\n Press Any Key To Exit'];
DrawFormattedText(scr.window, message_string,...
    'center', 'center', visual.black);
Screen('Flip', scr.window);
KbStrokeWait;
sca;
