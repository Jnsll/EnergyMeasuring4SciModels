%call with the root_path of the whole repository, where the scripts reside
%
%output is 1/True IFF both scripts output the same on the console and the
%repository directory is identical after script execution
function [same_outputs, same_data, same_results, runTime, runTimeAI] = two_scripts_are_same(root_path, rel_script_path, script_name, content, contentAI)

    try
        fprintf('Testing original version of %s\n', script_name)
        [res, output, hashafter, runTime] = capture_outputs(root_path, rel_script_path, script_name, content);
        
        if strcmp(output, 'evalcERROR')
            [same_outputs, same_data, same_results, runTime, runTimeAI] = outputOrigCrashed(res, runTime);
            return
        end


        fprintf('Testing AI version of %s\n', script_name)
        [resAI, outputAI, hashafterAI, runTimeAI] = capture_outputs(root_path, rel_script_path, script_name, contentAI);



        %same_outputs = isequal(output, outputAI) && strcmp(hashafter, hashafterAI) && isequal(res, resAI);
        same_outputs = isequal(output, outputAI);
        same_data = strcmp(hashafter, hashafterAI);
        same_results = isequal(res, resAI);
    catch ME
        disp(ME)
        [same_outputs, runTime, runTimeAI] = outputERROR(ME);
        try
            %cleanup if one script produced errors
            rmdir([root_path '_copy'], 's');
        catch
        end
        return
    end
end

function [same_outputs, same_data, same_results, runTime, runTimeAI] = outputOrigCrashed(res, runTime)
    same_outputs = -1;
    same_data = -1;
    same_results = -1;
    runTimeAI = -1;
end

function [same_outputs, same_data, same_results, runTime, runTimeAI] = outputERROR(ME)
    same_outputs = -2;
    same_data = -2;
    same_results = -2;
    runTime = -2;
    runTimeAI = -2;
end

function [res, out, hash_after, runTime] = capture_outputs(root_path, rel_script_path, script_name, content)

    % Create a temporary directory for the copy
    temp_dir = [root_path '_copy'];
    if exist(temp_dir, 'file')
        rmdir(temp_dir, 's');
    end
    mkdir(temp_dir);

    % Copy the root_path directory to temp_dir
    copyfile(root_path, temp_dir, 'f');

    %copy the content into the script file
    script_file_path = [temp_dir filesep rel_script_path filesep script_name '.m'];
    fid = fopen(script_file_path, 'w');
    if fid == -1
        error('File could not be opened for writing.');
    end
    fprintf(fid, '%s', ['%TMP SCRIPT FOR TESTING OUTPUTS' newline newline content]);
    
    fclose(fid);

    % Capture the output of the script
    tic
    [res, out] = my_eval([temp_dir filesep rel_script_path], script_name);
    runTime = toc;

    if strcmp(res, 'MATLAB:scriptNotAFunction')
        disp("Functionifying ...")
        functionify(script_file_path, script_name, content)
        tic
        [res, out] = my_eval([temp_dir filesep rel_script_path], script_name);
        runTime = toc;
    end


    % Compute the final hash of the directory
    delete(script_file_path);
    hash_after = hash_directory(temp_dir);

    % Clean up: remove the temporary directory
    opened = openedFiles();
    for i=1:length(opened)
        fclose(opened(i))
    end
    rmdir(temp_dir, 's');
end

function functionify(script_file_path, script_name, content)
    fid = fopen(script_file_path, 'w');
    if fid == -1
        error('File could not be opened for writing.');
    end
    fprintf(fid, '%s', ['%TMP SCRIPT FOR TESTING OUTPUTS' newline 'function out = ' script_name '()' newline content newline 'out = '''';' newline 'variables=whos; for i = 1:length(variables); varName = variables(i).name; varValue = eval(varName); fprintf(''Variable: %s\n'', varName); disp(varValue); fprintf(''\n'');' newline 'end']);
    fclose(fid);
end



function [res, out] = my_eval(script_path, script_name)
    save('preScriptWorkspace.mat');
    cd(script_path)
    try
        [res, out] = evalc(script_name);
        disp("eval c completed")
    catch ME
        res = ME.identifier;
        out = 'evalcERROR';
        try
            %try again without expecting an output
            res = evalc(script_name);
            out = 'empty_output';
        catch ME
            res = ME.identifier;
            out = 'evalcERROR';
        end
    end
    close all;
    cd('C:\work\EnergyMeasuring4SciModels\matlab_energy_analysis')
    load('preScriptWorkspace.mat');
    save('preScriptWorkspace.mat');
    clear all;
    load('preScriptWorkspace.mat');
end

function hash = hash_directory(directory)
    
    % Get a list of all files in the directory
    files = dir(fullfile(directory, '**', '*'));
    files = files(~[files.isdir]); % Exclude directories
    
    
    % Read and update the hash for each file
    hash = '';
    for i = 1:length(files)
        hash = [hash Simulink.getFileChecksum([files(i).folder filesep files(i).name])];
    end
end
