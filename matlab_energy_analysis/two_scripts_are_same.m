%call with the root_path of the whole repository, where the scripts reside
%
%output is 1/True IFF both scripts output the same on the console and the
%repository directory is identical after script execution
function same_outputs = two_scripts_are_same(root_path, rel_script_path1, rel_script_path2)
    try
        [hashbefore1, console_output1, hashafter1] = capture_outputs(root_path, rel_script_path1);
        [hashbefore2, console_output2, hashafter2] = capture_outputs(root_path, rel_script_path2);
    
        if ~strcmp(hashbefore1, hashbefore2)
            error("Error occured during copying temporary copies of the directories.")
        end

        same_outputs = strcmp(console_output1, console_output2) && strcmp(hashafter1, hashafter2);
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
        if ~strcmp(console_output1, console_output2)
            if strcmp(hashafter1, hashafter2)
                disp("The scripts DIVERGE in console outputs!")
            else
                disp("The scripts DIVERGE in console outputs and output files!")
            end
        else
            disp("The scripts DIVERGE in output files!")
        end
    end
end

function [hash1, console_output, hash2] = capture_outputs(root_path, rel_script_path)

    % Create a temporary directory for the copy
    temp_dir = [root_path '_copy'];
    mkdir(temp_dir);

    % Copy the root_path directory to temp_dir
    copyfile(root_path, temp_dir, 'f');

    % Compute the initial hash of the directory
    hash1 = hash_directory(temp_dir);

    % Capture the output of the script
    console_output = evalc(['run(''' root_path filesep rel_script_path ''')']);

    % Compute the final hash of the directory
    hash2 = hash_directory(temp_dir);

    % Clean up: remove the temporary directory
    rmdir(temp_dir, 's');
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
