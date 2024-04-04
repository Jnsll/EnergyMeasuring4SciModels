function entryPoints(basePath)
    originalDirectory = pwd;
    entrCSV = 'entrypoints.csv';
    if nargin < 1
        basePath = "../sampling/repos_projects_filtered_top100stars";
    end
    if ~exist(basePath, 'dir')
        fprintf("The given directory %s does not exist on your file system. Stopping script.", basePath)
        return
    end
    projectsPaths = dir(basePath);
    projectsPaths = projectsPaths([projectsPaths.isdir]);
    projectsPaths = projectsPaths(~ismember({projectsPaths.name}, {'.', '..'}));
    timeCrashResults = struct('scriptName', {}, 'time', {}, 'crash', {}, 'errorMessage', {});
    for i = 1:length(projectsPaths)
        if i == 81
            continue
        end
        fprintf("Currently, %i entry Points were found\n", sum([timeCrashResults.crash] == 0))
        fullPath = [projectsPaths(i).folder filesep projectsPaths(i).name];
        thisEntrCSV = [fullPath filesep entrCSV];
        if init(fullPath, thisEntrCSV)%we already did visit this repository (i.e. there is a .csv file)
            timeCrashResults = [timeCrashResults table2struct(readtable(thisEntrCSV, 'Delimiter', ',', 'PreserveVariableNames', true))'];
            continue
        end
        basicEntryPoints = findBasicEntrypoints(projectsPaths(i));
        timeCrashResults = [timeCrashResults findGoodEntrypoints(basicEntryPoints, thisEntrCSV)];
    end
    cleanUpAndWriteOutput(originalDirectory, timeCrashResults, entrCSV)
end

%return to original directory
%replace substrings for UNIX users:
%remove backslashes
%remove common prefixes
function cleanUpAndWriteOutput(originalDirectory, timeCrashResults, entrCSV)
    cd(originalDirectory)
    commonPrefixLength = commonprefixlength(timeCrashResults(1).scriptName, timeCrashResults(end).scriptName);
    for i = 1:length(timeCrashResults)
        timeCrashResults(i).scriptName = regexprep(timeCrashResults(i).scriptName(commonPrefixLength:end), '\\', '/');
    end
    writetable(struct2table(timeCrashResults), entrCSV)
    fprintf("%i entry Points were found\n", sum([timeCrashResults.crash] == 0))
end

function length = commonprefixlength(a, b)
    for length = 1:min(strlength(a), strlength(b))
        if a(length) == b(length)
            continue
        else
            return
        end
    end
end

function alreadyVisited = init(path, csvFile)
    cd(path);
    %!git reset --hard
    alreadyVisited = exist(csvFile);
end

%dynamically identify entry points into .m scripts
%statically found scripts are run and tested, whether they run
%logging errors and run time until script finished or crashed
function timeCrashResults = findGoodEntrypoints(entrypoints, csvFile)
    timeCrashResults = struct('scriptName', {}, 'time', {}, 'crash', {}, 'errorMessage', {});
    writetable(struct2table(timeCrashResults), csvFile)
    for i = 1:length(entrypoints)
        timeCrashResults(end + 1) = runEntryPoint(entrypoints{i});
    end
    writetable(struct2table(timeCrashResults), csvFile)
end

function timeCrashResult = runEntryPoint(entrypoint)
    timeCrashResult = struct;
    tic
    try
        timeCrashResult.scriptName = entrypoint;
        run(entrypoint);
        timeCrashResult.time = toc;
        timeCrashResult.crash = 0;
        timeCrashResult.errorMessage = "";
        fprintf("###################################\nFound a good Entry Point: %s\n###################################\n", entrypoint)
    catch ME
        timeCrashResult.time = toc;
        timeCrashResult.crash = 1;
        timeCrashResult.errorMessage = ME.message;
    end
end

%statically identify entry points into .m scripts
%using things like excluding called scripts
%instead finding calling scripts
function basicEntryPoints = findBasicEntrypoints(projectPath)
    shortPath = projectPath.name;
    fullPath = [projectPath.folder filesep projectPath.name];
    fprintf('Searching entry point for project: %s\n', shortPath);
    depPoints = dependencyPoints(fullPath);
    mfiles = vertcat(dir(fullfile(fullPath, strcat('**',filesep,'*.m'))));
    entryPoints = {};
    for j = 1:length(mfiles)
        fullPathM = [mfiles(j).folder filesep mfiles(j).name];
        mfiles(j).executable = determineExecutability(fullPathM);
        if determineExecutability(fullPathM) && ismember({fullPathM}, depPoints)
            entryPoints{end + 1} = fullPathM;
        end
    end
    readmeEntryPoints = parseReadmes(fullPath);
    if ~isempty(entryPoints) && ~isempty(readmeEntryPoints)
        entryPoints = filterReadmeEntryPoints(entryPoints, readmeEntryPoints);
    end
    basicEntryPoints = entryPoints;
end

%build a dependency graph (forest) of .m files, choose roots of forest
function depPoints = dependencyPoints(projectFolder)
    prjFiles = vertcat(dir(fullfile(projectFolder, strcat('**',filesep,'*.prj'))));
    try
        if isempty(prjFiles)
            prj = matlab.project.createProject("Folder", projectFolder, "Name", "NewProject");
            mfiles = vertcat(dir(fullfile(projectFolder, strcat('**',filesep,'*.m'))));
        
            for idx = 1:length(mfiles)
                mfile = mfiles(idx).name;
                if length(mfiles(idx).folder) > length(projectFolder) + 1%the mfile is in a subdirectory
                    mfile = [mfiles(idx).folder(length(projectFolder) + 2:end) filesep mfile];
                end
                prj.addFile(mfile);
            end
        else
            prj = openProject(projectFolder);
        end
    catch ME
        fprintf("An error occured, analyzing %s: %s\n", projectFolder, ME.message)
        depPoints = {};
        return
    end

    
        
    % update dependencies
    prj.updateDependencies
    
    % get dependency digraph
    dependencyGraph = prj.Dependencies;
    
    % get edges of dependency graph
    edges = dependencyGraph.Edges;
    
    % files that call other files
    callingFiles = unique(edges.EndNodes(:,1));
    % files that are called by other files
    calledFiles = unique(edges.EndNodes(:,2));
    
    % files that are either entry points or unused files
    depPoints = setdiff(callingFiles,calledFiles);
end

function executability = determineExecutability(fileName)
    if ~exist(fileName, 'file')
        error('File does not exist: %s', fileName);
    end
    fileContent = fileread(fileName);
    fileContentNoComments = removeComments(fileContent);

    %if a .m-file is a class file, it is not executable
    %it should be a script file (no outer function) or a parameter-less
    %function file
    executability = ~isClassFile(fileContentNoComments) && (isScriptFile(fileContentNoComments) || zeroParameters(fileContentNoComments));
end

function isScriptFile = isScriptFile(fileContentNoComments)
    functionPattern = '^\s*function\s+';
    isScriptFile = isempty(regexp(fileContentNoComments, functionPattern, 'once'));
end


function isClass = isClassFile(fileContentNoComments)
    classPattern = '^\s*classdef\s+';
    isClass = ~isempty(regexp(fileContentNoComments, classPattern, 'once'));
end

function zeroParameters = zeroParameters(fileContentNoComments)
    zeroParameters = false;
    
    pattern = '^\s*function\s+(?:[\[\w\s,\]]+\s*=\s*)?(\w+)\s*\(([^)]*)\)';
    [tokens, match] = regexp(fileContentNoComments, pattern, 'tokens', 'match', 'once');
    
    if ~isempty(match)
        % If a match is found, extract the input argument list
        inputArgs = tokens{2};
        zeroParameters = isempty(strtrim(inputArgs));
    end
end

function content = removeComments(content)
    singleLineCommentsRemoved = regexprep(content, '(?m)^\s*%.*?(\r?\n|$)', '');
    commentPattern = '(?m)^\s*%{.*?%}\s*$';
    multiLineCommentsRemoved = regexprep(singleLineCommentsRemoved, commentPattern, '', 'dotexceptnewline');
    whiteSpaceRemoved = regexprep(multiLineCommentsRemoved, '(?m)^\s*$[\r\n]*', '');
    continuationsRemoved = regexprep(whiteSpaceRemoved, '\.\.\.\s*[\r\n]+', '');
    content = continuationsRemoved;
end

function readmeEntryPoints = parseReadmes(projectFolder)
    mdTXTfile = vertcat(dir(fullfile(projectFolder, ['**' filesep '*.md'])), dir(fullfile(projectFolder, ['**' filesep '*.txt'])));
    targetName = "readme";
    readmeFiles = {};
    for i = 1:length(mdTXTfile)
        [~, name, ext] = fileparts(mdTXTfile(i).name);
        currentFilename = [name ext];
        if strcmpi(name, targetName)
            readmeFiles{end+1} = fullfile(mdTXTfile(i).folder, currentFilename);
        end
    end
    readmeEntryPoints = cell(1, 0);
    for i = 1:length(readmeFiles)
        nextEntries = findAndOrderMatches(fileread(readmeFiles{i}));
        if ~isempty(nextEntries)
            readmeEntryPoints = [readmeEntryPoints nextEntries];
        end
    end
end


function orderedMatches = findAndOrderMatches(content)
    % find 'run script.m' or similar patterns
    pattern = '(launch|start|invoke|run|execute|call|initiate|trigger|use)(?:s|ing|ed)?\s+(?:\w\s+)?[''"`]?(\w+\.m)[''"`]?\W';
    [startIdx, endIdx, extents, matches] = regexp(content, pattern, 'start', 'end', 'tokenExtents', 'match');
    orderedMatches = {};
    for i = 1:length(matches)
        % Extracting the filename from the match
        filename = regexp(matches{i}, '\w+\.m', 'match', 'once');
        orderedMatches{end+1} = filename;
    end
end


%filter out entry points, that are not mentioned in the readme files
function matchedEntryPoints = filterReadmeEntryPoints(entryPoints, readmeEntryPoints)
    entryPointsStr = string(entryPoints);
    readmeEntryPointsStr = string(readmeEntryPoints);
    matchesMatrix = endsWith(entryPointsStr, readmeEntryPointsStr');
    matches = any(matchesMatrix, 2);
    matchedEntryPoints = entryPoints(matches);
end