function drawCenteredText(window, textString, xCenter, yCenter, textColor, textSize)
    if nargin < 5
        textColor = [255 255 255]; % Default to white color if not specified
    end
    
    % Set text size (optional, can be adjusted or set as another parameter)
    Screen('TextSize', window, textSize);

    % Get the bounds of the text
    textBounds = Screen('TextBounds', window, textString);

    % Calculate the position to start the text so it's centered on xCenter and yCenter
    xPosition = xCenter - textBounds(3) / 2;
    yPosition = yCenter - textBounds(4) / 2;

    % Draw the text at the calculated position
    Screen('DrawText', window, textString, xPosition, yPosition, textColor);

    % Note: The screen is not flipped here, allowing multiple drawing commands
    % to be executed. You need to call Screen('Flip') after calling this function
    % to display the text.
end