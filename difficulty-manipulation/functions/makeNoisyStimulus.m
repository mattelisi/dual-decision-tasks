function[texture] = makeNoisyStimulus(visual, tiltInDegrees, spatialFreq, contrast, widthOfGrid, noiseSD, sigma, radius2, phase)
%
% Prepare a Gabor in noise in a circular aperture with linear 'soft' edges
% 
% NB. tilt in degrees is intended clockwise from vertical
% 
% Matteo Lisi, 2022


% random phase
if nargin < 9
    phase = rand(1,1) * 2*pi;
end

tiltInRadians = (-tiltInDegrees) * pi / 180; % The tilt of the grating in radians.
radiansPerPixel = spatialFreq * (2 * pi); % = (periods per pixel) * (2 pi radians per period)
halfWidthOfGrid = widthOfGrid / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

black = visual.black;
white = visual.white;
gray = visual.bgColor; % (black + white) / 2;
% if round(gray)==white
% 	gray=black;
% end

% mesh
absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
[x, y] = meshgrid(widthArray, widthArray);

% grating
a=cos(tiltInRadians)*radiansPerPixel;
b=sin(tiltInRadians)*radiansPerPixel; 
gratingMatrix = sin(a*x + b*y + phase);

% Gaussian envelope
circularGaussianMaskMatrix = exp(-((x .^ 2) + (y .^ 2)) / (sigma ^ 2));

% circular window
noiseBG = randn(size(x,1),size(x,2)) * noiseSD;
radial_distance = sqrt(x.^2 + y.^2);
circular_aperture = linearDisc(radial_distance, radius2, halfWidthOfGrid/5);

%
noiseBG = gray + noiseBG.*circular_aperture;
imageMatrix = (gratingMatrix.*circularGaussianMaskMatrix).*circular_aperture;
grayscaleImageMatrix = uint8(noiseBG  +  contrast*(absoluteDifferenceBetweenWhiteAndGray * imageMatrix));
texture = grayscaleImageMatrix;
end

function[Yt] = linearDisc(Y,radius2, W)
Yt = zeros(size(Y,1),size(Y,2));
Yt(Y>=(radius2+W/2)) = 0;
Yt(Y<(radius2+W/2)) = 1;
Yt(Y>=(radius2-W/2) & Y<(radius2+W/2)) = 1 - ((Y(Y>=(radius2-W/2) & Y<(radius2+W/2)) - (radius2-W/2))/((radius2+W/2)-(radius2-W/2))).^2;
end


