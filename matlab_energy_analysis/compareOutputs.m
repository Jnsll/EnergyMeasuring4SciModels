function compareOutputs
    %csvFiles = {'TmpScripts.csv','OptimizedMatlabScripts_gpt3.csv' 'OptimizedMatlabScripts_gpt4.csv' 'OptimizedMatlabScripts_llama.csv' 'OptimizedMatlabScripts_mixtral.csv'};
    csvFiles = {'OptimizedMatlabScripts_gpt3.csv' 'OptimizedMatlabScripts_gpt4.csv' 'OptimizedMatlabScripts_llama.csv' 'OptimizedMatlabScripts_mixtral.csv'};
    resultCsvFile = 'compareOutput.csv';
    resultCsv = readtable(resultCsvFile);

    for c = 1:length(csvFiles)
        csvFile = csvFiles{c};
        csvData = readtable(csvFile);
        for r = 1:height(csvData)
            %skip if we tested thialready tested
            if any(strcmp(resultCsv.csvFile, csvFile) & (resultCsv.rowNumber == r))
                continue
            end

            fprintf("Coming up: %s, row %i\n", csvFile, r)

            row = struct;
            row.Original_code = char(table2cell(csvData(r,3)));
            row.AI_code = char(table2cell(csvData(r,4)));

            repo_path = char(table2cell(csvData(r, 1)));
            repo_path = split(repo_path, '/');
            repo_path = ['..' filesep repo_path{4} filesep repo_path{5} filesep repo_path{6}];
            row.RepoPath = repo_path;

            rel_script_path = char(table2cell(csvData(r, 1)));
            rel_script_path = rel_script_path(13+length(repo_path):end);
            rel_script_path = strsplit(rel_script_path, '/');
            row.Rel_script_path = strjoin(rel_script_path(1:end-1), '/');
            row.Script_name = rel_script_path{end};
            row.Script_name = row.Script_name(1:end-2);


            [same_outputs, runTime, runTimeAI] = two_scripts_are_same(row.RepoPath, row.Rel_script_path, row.Script_name, row.Original_code, row.AI_code);


            new_data = cell2table({csvFile, r, same_outputs, runTime, runTimeAI}, 'VariableNames', resultCsv.Properties.VariableNames);
            resultCsv = [resultCsv; new_data];
            writetable(resultCsv, resultCsvFile);
        end
    end
end