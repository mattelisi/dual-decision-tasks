function [dataline1, dataline2, first_correct, second_correct] = runSingleTrial(scr, visual, pair1, pair2, flags_path, leftKey, rightKey, collect_confidence)

% DECISION 1 % --------------------------------------------------------

% select side of correct answer
side = round(rand(1,1)) + 1;

% --------------------------------------------------------
% make texture
if side ==2
    
    fl2 = imread([flags_path, pair1{2}]);
    name2 =  pair1{1};
    loggdp2 = pair1{3};
    
    fl1 = imread([flags_path, pair1{5}]);
    name1 =  pair1{4};
    loggdp1 = pair1{6};
    
    flags_d1(1) = Screen('MakeTexture', scr.window, fl1);
    flags_d1(2) = Screen('MakeTexture', scr.window, fl2);
    
else
    
    fl1 = imread([flags_path, pair1{2}]);
    name1 =  pair1{1};
    loggdp1 = pair1{3};
    
    fl2 = imread([flags_path, pair1{5}]);
    name2 =  pair1{4};
    loggdp2 = pair1{6};
    
    flags_d1(1) = Screen('MakeTexture', scr.window, fl1);
    flags_d1(2) = Screen('MakeTexture', scr.window, fl2);
    
end


% --------------------------------------------------------
% present stimuli
Screen('DrawTextures', scr.window, flags_d1, [], visual.stim_rects);
drawCenteredText(scr.window, name1, visual.names_locations(1,1), visual.names_locations(1,2), visual.black, visual.textSize);
drawCenteredText(scr.window, name2, visual.names_locations(2,1), visual.names_locations(2,2), visual.black, visual.textSize);
Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
t_on = Screen('Flip', scr.window);

% --------------------------------------------------------
% wait for response
resp_right = NaN;
while isnan(resp_right)
    [keyisdown, secs, keycode] = KbCheck(-1);
    if keyisdown && (keycode(leftKey) || keycode(rightKey))
        tResp = secs - t_on;
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

Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
Screen('Flip', scr.window);

Screen('Close', flags_d1(1));
Screen('Close', flags_d1(2));

if collect_confidence(1)==1
    [conf, conf_RT]=collect_confidence_rating(scr, visual, 1);
else
    conf= NaN;
    conf_RT= NaN;
end
    
% write data line to file
dataline1 = sprintf('%i\t%s\t%.6f\t%s\t%.6f\t%i\t%i\t%.2f\t%.2f\t%.2f\n', 1, name1, loggdp1, name2,loggdp2, resp_right, accuracy, tResp, conf, conf_RT);

% DECISION 2 % --------------------------------------------------------

% make texture
if side2 ==2
    
    fl2 = imread([flags_path, pair2{2}]);
    name2 =  pair2{1};
    loggdp2 = pair2{3};
    
    fl1 = imread([flags_path, pair2{5}]);
    name1 =  pair2{4};
    loggdp2 = pair2{6};
    
    flags_d2(1) = Screen('MakeTexture', scr.window, fl1);
    flags_d2(2) = Screen('MakeTexture', scr.window, fl2);
    
else
    
    fl1 = imread([flags_path, pair2{2}]);
    name1 =  pair2{1};
    loggdp2 = pair2{3};
    
    fl2 = imread([flags_path, pair2{5}]);
    name2 =  pair2{4};
    loggdp2 = pair2{6};
    
    flags_d2(1) = Screen('MakeTexture', scr.window, fl1);
    flags_d2(2) = Screen('MakeTexture', scr.window, fl2);
    
end

% --------------------------------------------------------
% present stimuli
Screen('DrawTextures', scr.window, flags_d2, [], visual.stim_rects);
drawCenteredText(scr.window, name1, visual.names_locations(1,1), visual.names_locations(1,2), visual.black, visual.textSize);
drawCenteredText(scr.window, name2, visual.names_locations(2,1), visual.names_locations(2,2), visual.black, visual.textSize);
Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_2, [], 2);
drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
t_on2 = Screen('Flip', scr.window);

%
while KbCheck(-1); end
FlushEvents('KeyDown');

% --------------------------------------------------------
% wait for response
resp_right = NaN;
while isnan(resp_right)
    [keyisdown, secs, keycode] = KbCheck(-1);
    if keyisdown && (keycode(leftKey) || keycode(rightKey))
        tResp = secs - t_on2;
        if keycode(rightKey)
            resp_right = 1;
        elseif keycode(leftKey)
            resp_right = 0;
        end
    end
end

if side2==2
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
second_correct = accuracy;

if collect_confidence(2)==1
    [conf, conf_RT]=collect_confidence_rating(scr, visual, 2);
else
    conf= NaN;
    conf_RT= NaN;
end

% write data line to file
dataline2 = sprintf('%i\t%s\t%.6f\t%s\t%.6f\t%i\t%i\t%.2f\t%.2f\t%.2f\n', 1, name1, loggdp1, name2,loggdp2, resp_right, accuracy, tResp, conf, conf_RT);

Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_2, [], 2);
drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
Screen('Flip', scr.window);
Screen('Close', flags_d2(1));
Screen('Close', flags_d2(2));


