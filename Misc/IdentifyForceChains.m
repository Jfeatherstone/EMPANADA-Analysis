function editedImageArr = IdentifyForceChains(blackAndWhiteImageArr, kwargs)
%IDENTIFYFORCECHAINS Highlight force chains in a black and white image

% Parse args provided to the function
% Idea from: https://stackoverflow.com/questions/2775263/how-to-deal-with-name-value-pairs-of-function-arguments-in-matlab

% All of the default options
funcOptions = struct('correctlightgradient', 0, ...
    'brightdiscardthreshhold', 1.35, ...
    'darkdiscardthreshhold', 1.25, ...
    'darkoffset', 15, ...
    'brightoffset', 0, ...
    'darkwienerkernelsize', 12, ...
    'darkdownscalefactor', 1.3, ...
    'brightdownscalefactor', 1.0, ...
    'finalwienerkernelsize', 20);

if exist('kwargs', 'var')
    % List the keys
    possibleOptionNames = fieldnames(funcOptions);

    % Make sure that vargin has an even number of entries
    numArgs = length(kwargs);
    if round(numArgs/2) ~= numArgs/2
       error('Improper amount of kwargs (%i) passed to function IdentifyForceChains', numArgs);
    end

    % Reshape kwargs to be in pairs
    for pair = reshape(kwargs, 2, [])
        
        if any(strcmpi(pair{1}, possibleOptionNames))
            funcOptions.(lower(pair{1})) = str2double(pair{2});
        else
            error('Invalid kwarg passed to function IdentifyForceChains: %s', pair{1});
        end
    end
end

imageSize = size(blackAndWhiteImageArr);

% Default to zero, so nothing happens unless the parameter is specified
correction = 0;

% Apply a corrective gradient if specified
if funcOptions.correctlightgradient > 0
   correction = repmat(linspace(0, funcOptions.correctlightgradient, imageSize(1))', 1, imageSize(2));
elseif funcOptions.correctlightgradient < 0
   correction = repmat(linspace(-funcOptions.correctlightgradient, 0, imageSize(1))', 1, imageSize(2));
end

blackAndWhiteImageArr = blackAndWhiteImageArr + uint8(correction);
blackAndWhiteImageArr(blackAndWhiteImageArr > 255) = 255;
blackAndWhiteImageArr(blackAndWhiteImageArr < 0) = 0;

% editedImageArr = blackAndWhiteImageArr;
% return

inverseImageArr = 255 - blackAndWhiteImageArr;

brightChains = exp(-double(inverseImageArr)/127.) * 255;
brightChains(brightChains < funcOptions.brightdiscardthreshhold*mean(brightChains)) = 0;
%brightChains = brightChains > brightDiscardThreshhold*mean(brightChains);
brightChains = uint8(double(min(blackAndWhiteImageArr + funcOptions.brightoffset, 255)) .* brightChains / (funcOptions.brightdownscalefactor*255));

darkChains = exp(-double(wiener2(blackAndWhiteImageArr, [funcOptions.darkwienerkernelsize,funcOptions.darkwienerkernelsize]))/127.) * 255;
darkChains(darkChains < funcOptions.darkdiscardthreshhold*mean(darkChains)) = 0;
%darkChains = darkChains > darkDiscardThreshhold*mean(darkChains);
darkChains = uint8(double(max(inverseImageArr - funcOptions.darkoffset, 0)) .* darkChains / (funcOptions.darkdownscalefactor*255));

editedImageArr = wiener2(brightChains + darkChains, [funcOptions.finalwienerkernelsize, funcOptions.finalwienerkernelsize]);

end

