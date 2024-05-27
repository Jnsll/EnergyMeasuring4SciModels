function [env, versionString] = getEnvironment()
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    if isOctave
        env = 'Octave';
        versionString = OCTAVE_VERSION;
    else
        env = 'MATLAB';
        versionString = version;
    end
end