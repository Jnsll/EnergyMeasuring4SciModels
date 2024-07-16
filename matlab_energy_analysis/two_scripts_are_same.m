%call with the root_path of the whole repository, where the scripts reside
%
%output is 1/True IFF both scripts output the same on the console and the
%repository directory is identical after script execution
function [same_outputs, runTime, runTimeAI] = two_scripts_are_same(root_path, rel_script_path, script_name, content, contentAI)
    max_time = 600;

    try
        fprintf('Testing original version of %s\n', script_name)
        [hashbefore, console_output, hashafter, runTime] = capture_outputs(root_path, rel_script_path, script_name, content, max_time);
        fprintf('Testing AI version of %s\n', script_name)
        [hashbeforeAI, console_outputAI, hashafterAI, runTimeAI] = capture_outputs(root_path, rel_script_path, script_name, contentAI, max_time);
    
        if ~strcmp(hashbefore, hashbeforeAI)
            error("Error occured during copying temporary copies of the directories.")
        end

        same_outputs = strcmp(console_output, console_outputAI) && strcmp(hashafter, hashafterAI);
    catch ME
         disp(ME)
        try
            %cleanup if one script produced errors
            rmdir([root_path '_copy'], 's');
        catch
        end
    end
    %produce human readable console output
    if same_outputs
        disp("Both scripts produced the SAME console outputs and output files.")
    else
        if ~strcmp(console_output, console_outputAI)
            if strcmp(hashafter, hashafterAI)
                disp("The scripts DIVERGE in console outputs!")
            else
                disp("The scripts DIVERGE in console outputs and output files!")
            end
        else
            disp("The scripts DIVERGE in output files!")
        end
    end
end

function [hash1, console_output, hash2, runTime] = capture_outputs(root_path, rel_script_path, script_name, content, max_time)

    % Create a temporary directory for the copy
    temp_dir = [root_path '_copy'];
    if exist(temp_dir, 'file')
        rmdir(temp_dir, 's');
    end
    mkdir(temp_dir);

    % Copy the root_path directory to temp_dir
    copyfile(root_path, temp_dir, 'f');

    % Compute the initial hash of the directory
    hash1 = hash_directory(temp_dir);

    %copy the content into the script file
    script_file_path = [temp_dir filesep rel_script_path filesep script_name '.m'];
    fid = fopen(script_file_path, 'w');
    if fid == -1
        error('File could not be opened for writing.');
    end
    fprintf(fid, '%s', ['%TMP SCRIPT FOR TESTING OUTPUTS' newline newline content]);
    fclose(fid);

    % Capture the output of the script
    execution_path = [temp_dir filesep rel_script_path];
    [console_output, runTime] = start_and_monitor(max_time, execution_path, script_name);

    % Compute the final hash of the directory
    delete(script_file_path);
    hash2 = hash_directory(temp_dir);

    % Clean up: remove the temporary directory
    try
        rmdir(temp_dir, 's');
    catch
        pause(3)
        rmdir(temp_dir, 's');
    end
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
