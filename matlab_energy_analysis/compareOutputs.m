function compareOutputs
    clear all;
    %csvFiles = {'TmpScripts.csv'};
    csvFiles = {'OptimizedMatlabScripts_gpt3.csv' 'OptimizedMatlabScripts_gpt4.csv' 'OptimizedMatlabScripts_llama.csv' 'OptimizedMatlabScripts_mixtral.csv', 'OptimizedMatlabScripts_human.csv', 'OptimizedMatlabScripts_original.csv'};
    resultCsvFile = 'compareOutput.csv';
    resultCsv = readtable(resultCsvFile);
    
    for c = 1:length(csvFiles)
        csvFile = csvFiles{c};
        csvData = readtable(csvFile);

        shortCSVFile = split(csvFile, '_');
        shortCSVFile = shortCSVFile{2};
        shortCSVFile = shortCSVFile(1:end-4);

        for r = 1:height(csvData)

            %skip if we tested the script already
            if any(strcmp(resultCsv.csvFile, shortCSVFile) & (resultCsv.rowNumber == r))
                continue
            end

            fprintf("Coming up: %s, row %i\n", shortCSVFile, r)

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
            short_rel_path = csvData{r, 1}{1}(60:end);
            row.Rel_script_path = strjoin(rel_script_path(1:end-1), '/');
            row.Script_name = rel_script_path{end};
            row.Script_name = row.Script_name(1:end-2);


            [same_outputs, same_data, same_results, runTime, runTimeAI] = two_scripts_are_same(row.RepoPath, row.Rel_script_path, row.Script_name, row.Original_code, row.AI_code);


            new_data = cell2table({shortCSVFile, r, same_outputs, same_data, same_results, runTime, runTimeAI, short_rel_path}, 'VariableNames', resultCsv.Properties.VariableNames);
            resultCsv = [resultCsv; new_data];
            writetable(resultCsv, resultCsvFile);
        end
    end
end