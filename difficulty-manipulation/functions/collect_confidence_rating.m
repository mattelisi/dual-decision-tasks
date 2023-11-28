function [conf, RT]=collect_confidence_rating(scr, visual, decision)
% Modified from: https://github.com/embodied-computation-group/dg-metacognition/blob/main/tasks/metacognition_battery/functions/collectConfidenceDiscrete.m
% Matteo Lisi, 2023

center = [scr.xCenter, scr.yCenter];
keys = [KbName('LeftArrow') KbName('RightArrow') KbName('Space')];

%% Initialise VAS scale
VASwidth = round(8 * visual.ppd);
% VASheight = round(0.5, visual.ppd);
%VASoffset=visual.stim_size/2;
VASoffset=0 ;
arrowwidth= round(1 * visual.ppd);
arrowheight=arrowwidth;
l = VASwidth/2;
deadline = 0;
vas_points = 7;

% Collect rating
start_time = GetSecs;
secs = start_time;
max_x = center(1) + l;
min_x = center(1) - l;
steps_x = linspace(-l, l, vas_points);
range_x = max_x - min_x;
index = ceil(rand*vas_points);
xpos = center(1) + steps_x(index);
while (secs - start_time) < 10
    WaitSecs(.07);
    [keyIsDown,~,keyCode] = KbCheck(-1);
    % secs = GetSecs;
    if keyIsDown
        direction = find(keyCode(keys));
        
        if direction == 1
            xpos = xpos - (range_x./(length(steps_x)-1));
        elseif direction == 2
            xpos = xpos + (range_x./(length(steps_x)-1));
        elseif direction == 3
            deadline = 1;
            break
        end
        
        if xpos > max_x
            xpos = max_x;
        elseif xpos < min_x
            xpos = min_x;
        end
    end
    
     % Draw line
    Screen('DrawLine',scr.window,[255 255 255],center(1)-VASwidth/2,center(2)+VASoffset,center(1)+VASwidth/2,center(2)+VASoffset);
    % Draw left major tick
    Screen('DrawLine',scr.window,[255 255 255],center(1)-VASwidth/2,center(2)+VASoffset+20,center(1)-VASwidth/2,center(2)+VASoffset);
    % Draw right major tick
    Screen('DrawLine',scr.window,[255 255 255],center(1)+VASwidth/2,center(2)+VASoffset+20,center(1)+VASwidth/2,center(2)+VASoffset);
    
    if decision ==1
        Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
        drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    else
        Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_2, [], 2);
        drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    end
    
    % % Draw minor ticks
    tickMark = center(1) + linspace(-VASwidth/2,VASwidth/2,vas_points);
    Screen('TextSize', scr.window, 24);
    tickLabels = {'1','2','3','4','5','6', '7'};
    for tick = 1:length(tickLabels)
        Screen('DrawLine',scr.window,[255 255 255],tickMark(tick),center(2)+VASoffset+10,tickMark(tick),center(2)+VASoffset);
        DrawFormattedText(scr.window,tickLabels{tick},tickMark(tick)-10,center(2)+VASoffset-30,[255 255 255]);
    end
    DrawFormattedText(scr.window,'Confidence?','center',center(2)+VASoffset+75,[255 255 255]);

    % Update arrow
    arrowPoints = [([-0.5 0 0.5]'.*arrowwidth)+xpos ([1 0 1]'.*arrowheight)+center(2)+VASoffset];
    Screen('FillPoly',scr.window,[255 255 255],arrowPoints);
    Screen('Flip', scr.window);
end

if deadline == 0
    conf = NaN;
    RT = NaN;
    % Draw confidence text
    DrawFormattedText(scr.window,'Too late!','center',center(2)+VASoffset+75,[255 255 255]);
    if decision ==1
        Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
        drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    else
        Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_2, [], 2);
        drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    end
    Screen('Flip', scr.window);
    WaitSecs(0.1);

elseif deadline == 1
    conf = ((xpos-(center(1)-l))./range_x);
    RT = secs - start_time;
    
    %% Show confirmation arrow
    
     % Draw line
    Screen('DrawLine',scr.window,[255 255 255],center(1)-VASwidth/2,center(2)+VASoffset,center(1)+VASwidth/2,center(2)+VASoffset);
    % Draw left major tick
    Screen('DrawLine',scr.window,[255 255 255],center(1)-VASwidth/2,center(2)+VASoffset+20,center(1)-VASwidth/2,center(2)+VASoffset);
    % Draw right major tick
    Screen('DrawLine',scr.window,[255 255 255],center(1)+VASwidth/2,center(2)+VASoffset+20,center(1)+VASwidth/2,center(2)+VASoffset);
    
    % % Draw minor ticks
    tickMark = center(1) + linspace(-VASwidth/2,VASwidth/2,vas_points);
    Screen('TextSize', scr.window, 24);
    tickLabels = {'1','2','3','4','5','6', '7'};
    for tick = 1:length(tickLabels)
        Screen('DrawLine',scr.window,[255 255 255],tickMark(tick),center(2)+VASoffset+10,tickMark(tick),center(2)+VASoffset);
        DrawFormattedText(scr.window,tickLabels{tick},tickMark(tick)-10,center(2)+VASoffset-30,[255 255 255]);
    end
    DrawFormattedText(scr.window,'Confidence?','center',center(2)+VASoffset+75,[255 255 255]);
    
    if decision ==1
        Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_1, [], 2);
        drawCenteredText(scr.window, '1', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    else
        Screen('DrawDots', scr.window, visual.dots_xy, visual.dots_size, visual.dots_col_2, [], 2);
        drawCenteredText(scr.window, '2', scr.xCenter, visual.dots_xy(2,1), visual.black, visual.textSize);
    end

    % Show arrow
    arrowPoints = [([-0.5 0 0.5]'.*arrowwidth)+xpos ([1 0 1]'.*arrowheight)+center(2)+VASoffset];
    Screen('FillPoly',scr.window,[255 0 0],arrowPoints);
    Screen('Flip', scr.window);
    
    while KbCheck(-1); end
    FlushEvents('KeyDown');
    WaitSecs(0.1);
    
end
