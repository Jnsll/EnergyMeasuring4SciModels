function download_and_extract_proposals()
    % Save the current directory
    cur_dir = pwd;
    
    % Change to the script's directory
    script_dir = fileparts(mfilename('fullpath'));
    cd(script_dir);
    
    try
        fprintf('Downloading region proposals...\n');
        
        % Define the URL and the local file name
        url = 'https://onedrive.live.com/download?resid=F371D9563727B96F!91965&authkey=!AErVqYD6NhjxAfw';
        local_zip = 'proposals.zip';
        
        % Download the file
        websave(local_zip, url);
        
        fprintf('Unzipping...\n');
        
        % Unzip the file to the parent directory
        unzip(local_zip, '..');
        
        fprintf('Done.\n');
        
        % Delete the zip file after extraction
        delete(local_zip);
    catch ME
        fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN\n');
        fprintf('Error message: %s\n', ME.message);
    end
    
    % Return to the original directory
    cd(cur_dir);
end