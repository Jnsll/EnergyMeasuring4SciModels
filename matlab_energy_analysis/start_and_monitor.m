function [output, process_runTime] = start_and_monitor(max_time, path, script_name)
    tmp_logfile = 'log.txt';
    tmp_batfile = 'batbat.sh';

    
    old_pids = get_matlab_PIDs;
    old_wd = pwd;
    cd(path)
    create_sh_file(tmp_batfile, script_name)
    [success, cmdout] = system(['sh ' tmp_batfile]);
    new_pids = get_matlab_PIDs;
    processID = setdiff(new_pids, old_pids);

    %wait till process is done or time runs out
    process_runTime = 0;
    process_finished = 0;
    while process_runTime <= max_time && ~process_finished
        pause(1)
        process_runTime = process_runTime + 1;
        process_finished = is_process_finished(processID);
    end

    
    if process_runTime >= max_time
        %process did not finish in time, kill it!!
        [~, ~] = system(['taskkill /PID ', num2str(setdiff(new_pids, old_pids))]);
    end
    output = fileread(tmp_logfile);
    delete(tmp_logfile)
    delete(tmp_batfile)
    cd(old_wd)
return

function create_sh_file(tmp_batfile, command)
    whos_string = char("; variables=whos; for i = 1:length(variables); varName = variables(i).name; varValue = eval(varName); fprintf('Variable: %s\n', varName); disp(varValue); fprintf('\n'); end;");
    sh_text = ['matlab -batch "disp(111); ' command whos_string ' disp(111);" > log.txt &'];
    fid = fopen(tmp_batfile, 'w');
    if fid == -1
        error('File could not be opened for writing.');
    end
    fprintf(fid, '%s\n', sh_text);
    fclose(fid);
return

function is_finished = is_process_finished(ID)
    [~, process_finished] = system(['tasklist /FI "PID eq ', num2str(ID), '"']);
    is_finished = strcmp(process_finished, ['INFO: No tasks are running which match the specified criteria.' newline]);
return

function PIDs = get_matlab_PIDs()
    matlabPIDs_command = 'wmic process where "name=''matlab.exe''" get processid /format:list';
    [~, matlabPIDs] = system(matlabPIDs_command);
    PIDs = regexp(matlabPIDs, '\d+', 'match');
    PIDs = str2double(PIDs);
return



function xx()
    % Monitor the process every second
    for t = 1:5
        % Check if the process is running
        [~, result] = system(['tasklist /FI "PID eq ', num2str(pid), '"']);
        
        % Capture the output
        [~, currentOutput] = system(['tasklist /FI "PID eq ', num2str(pid), '" /FO CSV']);
        output = [output, currentOutput];
        
        % If the process is not found, break the loop
        if contains(result, 'No tasks are running')
            disp('Process terminated before 5 seconds.');
            break;
        end
        
        % Pause for 1 second
        pause(1);
    end
return