% Set the filename identifiers
identifiers = {'AAzst1avir.N02.*.HEAD', 'AAzst1avir.N05.*.HEAD'};
[err, errMsg, fileList] = zglobb(identifiers);

% Loop across all bricks found
numFiles = length(fileList);
for i = 1:numFiles
    inputName = fileList(i).name;
    fprintf('Now processing: %s ...\n', inputName);
    
    % Get prefix status
    [~, inputPrefix, ~] = PrefixStatus(inputName);
    
    % Set the new prefix
    newPrefix = sprintf('%s_reord', inputPrefix);
    
    % Set up for the function m3dReorder
    mapFile = 'map.1D';
    options.Verbose = 1;
    options.Detrend = 2;
    options.Dup = 'Col';
    options.NoCheck = 0;
    
    % Call the m3dReorder function
    [err] = m3dReorder(inputName, newPrefix, mapFile, options);
end