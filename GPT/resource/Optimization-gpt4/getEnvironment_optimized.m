function [env, versionString] = getEnvironment()
    % Determine environment (Octave, MATLAB) and version string
    % TODO: Unify private `getEnvironment` functions
    persistent cacheEnv cacheVersionString

    if isempty(cacheEnv) || isempty(cacheVersionString)
        if isOctave()
            env = 'Octave';
            versionString = OCTAVE_VERSION;
        else
            env = 'MATLAB';
            versionString = version('-release');
        end

        % store in cache
        cacheEnv = env;
        cacheVersionString = versionString;
    else
        env = cacheEnv;
        versionString = cacheVersionString;
    end
end

function flag = isOctave()
    % Helper function to check if the environment is Octave
    persistent octaveFlag
    if isempty(octaveFlag)
        octaveFlag = (exist('OCTAVE_VERSION', 'builtin') ~= 0);
    end
    flag = octaveFlag;
end