function SitNWait(keyName)
% Matteo Lisi, 2012
% wait for a particular key to be pressed
% if keyName is not provided, any key will do

while KbCheck(-1); end
FlushEvents('KeyDown');

if nargin == 1
    specificKey = KbName(keyName);
    anyFlag = 0;
else
    anyFlag = 1;
end

sitFlag = 1;
while sitFlag
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if keyIsDown
        response = find(keyCode);
        response = response(1);
        if anyFlag || response == specificKey
            sitFlag = 0;
        end
    end
end

% now wait for the key to come up again
while KbCheck(-1); end
if response == KbName('delete')
    error('Program execution terminated, by your command');
end