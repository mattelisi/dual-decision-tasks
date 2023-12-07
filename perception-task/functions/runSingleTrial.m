function [dataline1, dataline2, first_correct, second_correct] = runSingleTrial(scr, visual, leftKey, rightKey, soa_range, constrast_value, collect_confidence)

% note that here contrast_value is a vector with 2 levels [decision1, decision2]

% --------------------------------------------------------
% trial settings
soa = soa_range(1)+rand(1)*(soa_range(2)-soa_range(1));
soa2 = soa_range(1)+rand(1)*(soa_range(2)-soa_range(1));

side = binornd(1,0.5,1,1) + 1;

phase1 = rand(1,1) * 2*pi;
phase2 = rand(1,1) * 2*pi;

% signed_contrast = sign((side-1.5))*constrast_value(1);

%% DECISION 1 % --------------------------------------------------------

% --------------------------------------------------------
% fixation spot
Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
fix_on = Screen('Flip', scr.window);
t_flip = fix_on;

WaitSecs(soa - 2/3*scr.ifi);

% --------------------------------------------------------
% stimulus sequence

% pre-mask
for i=1:visual.stim_n_frames
    im_01 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    im_02 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    tx(1) = Screen('MakeTexture', scr.window, im_01);
    tx(2) = Screen('MakeTexture', scr.window, im_02);
    Screen('DrawTextures', scr.window, tx, [], visual.stim_rects);
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    t_flip = Screen('Flip', scr.window, t_flip + visual.noise_interval);
end

% target
for i=1:visual.stim_n_frames
    im_01 = makeNoisyStimulus(visual, visual.tiltInDegrees,visual.spatialFreq, constrast_value(1), visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2, phase1); %signal
    im_02 = makeNoisyStimulus(visual,visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    tx(side) = Screen('MakeTexture', scr.window, im_01);
    tx(2-side+1) = Screen('MakeTexture', scr.window, im_02);
    Screen('DrawTextures', scr.window, tx, [], visual.stim_rects);
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    t_flip = Screen('Flip', scr.window, t_flip + visual.noise_interval);
    if i ==1
        t_sn = t_flip;
    end
end

% post-mask
for i=1:visual.stim_n_frames
    im_01 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    im_02 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    tx(1) = Screen('MakeTexture', scr.window, im_01);
    tx(2) = Screen('MakeTexture', scr.window, im_02);
    Screen('DrawTextures', scr.window, tx, [], visual.stim_rects);
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    t_flip = Screen('Flip', scr.window, t_flip + visual.noise_interval);
end

% offset

Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
t_off = Screen('Flip', scr.window, t_flip + visual.noise_interval);

% --------------------------------------------------------
% wait for response
resp_right = NaN;
while isnan(resp_right)
    [keyisdown, secs, keycode] = KbCheck(-1);
    if keyisdown && (keycode(leftKey) || keycode(rightKey))
        tResp = secs - t_off;
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

if collect_confidence(1)==1
    [conf, conf_RT]=collect_confidence_rating(scr, visual, 1);
else
    conf= NaN;
    conf_RT= NaN;
end

% write data line to file
dataline1 = sprintf('%i\t%2f\t%i\t%i\t%i\t%2f\t%.2f\t%.2f', 1, constrast_value(1), side, resp_right, accuracy, tResp,conf,conf_RT);


%% DECISION 2 % --------------------------------------------------------

% --------------------------------------------------------
% fixation spot
Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_2, [], 2);
drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
fix_on = Screen('Flip', scr.window);
t_flip = fix_on;

WaitSecs(soa2 - 2/3*scr.ifi);

% --------------------------------------------------------
% stimulus sequence

% pre-mask
for i=1:visual.stim_n_frames
    im_01 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    im_02 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    tx(1) = Screen('MakeTexture', scr.window, im_01);
    tx(2) = Screen('MakeTexture', scr.window, im_02);
    Screen('DrawTextures', scr.window, tx, [], visual.stim_rects);
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    t_flip = Screen('Flip', scr.window, t_flip + visual.noise_interval);
end

% target
for i=1:visual.stim_n_frames
    im_01 = makeNoisyStimulus(visual, visual.tiltInDegrees,visual.spatialFreq, constrast_value(2), visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2, phase2); %signal
    im_02 = makeNoisyStimulus(visual,visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    tx(side2) = Screen('MakeTexture', scr.window, im_01);
    tx(2-side2+1) = Screen('MakeTexture', scr.window, im_02);
    Screen('DrawTextures', scr.window, tx, [], visual.stim_rects);
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    t_flip = Screen('Flip', scr.window, t_flip + visual.noise_interval);
    if i ==1
        t_sn = t_flip;
    end
end

% post-mask
for i=1:visual.stim_n_frames
    im_01 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    im_02 = makeNoisyStimulus(visual, visual.tiltInDegrees, visual.spatialFreq, 0, visual.widthOfGrid, visual.noiseSD, visual.sigma , visual.radius2);
    tx(1) = Screen('MakeTexture', scr.window, im_01);
    tx(2) = Screen('MakeTexture', scr.window, im_02);
    Screen('DrawTextures', scr.window, tx, [], visual.stim_rects);
    Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
    Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
    drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    t_flip = Screen('Flip', scr.window, t_flip + visual.noise_interval);
end

% offset

Screen('FillOval', scr.window, visual.black, CenterRectOnPoint([0,0, round(visual.fix_size), round(visual.fix_size)], scr.xCenter, scr.yCenter));
Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
t_off = Screen('Flip', scr.window, t_flip + visual.noise_interval);

% --------------------------------------------------------
% wait for response
resp_right = NaN;
while isnan(resp_right)
    [keyisdown, secs, keycode] = KbCheck(-1);
    if keyisdown && (keycode(leftKey) || keycode(rightKey))
        tResp = secs - t_off;
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

if collect_confidence(1)==1
    [conf, conf_RT]=collect_confidence_rating(scr, visual, 1);
else
    conf= NaN;
    conf_RT= NaN;
end

% write data line to file
dataline2 = sprintf('%i\t%2f\t%i\t%i\t%i\t%2f\t%.2f\t%.2f', 2, constrast_value(2), side, resp_right, accuracy, tResp,conf,conf_RT);



