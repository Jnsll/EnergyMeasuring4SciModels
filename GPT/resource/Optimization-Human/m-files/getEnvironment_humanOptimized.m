function [env, versionString] = getEnvironment
% Determine environment (Octave, MATLAB) and version string
% TODO: Unify private `getEnvironment` functions
    persistent cache

    if isempty(cache)
        isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
        if isOctave
            env = 'Octave';
            versionString = OCTAVE_VERSION;
        else
            env = 'MATLAB';
            vData = char(matlabRelease.Release);
            versionString = [vData(end-2:end-1),'.',num2str(vData(end) - 96)];
        end

        % store in cache
        cache.env = env;
        cache.versionString = versionString;

    else
        env = cache.env;
        versionString = cache.versionString;
    end
end
