% Store current directory
cur_dir = pwd;

% Change directory to the script's location
script_dir = fileparts(mfilename('fullpath'));
cd(script_dir);

try
    % Download region proposals
    fprintf('Downloading region proposals...\n');
    url = 'https://onedrive.live.com/download?resid=F371D9563727B96F!91965&authkey=!AErVqYD6NhjxAfw';
    [~,status] = urlwrite(url, 'proposals.zip');

    if status
        % Unzip the downloaded file
        fprintf('Unzipping...\n');
        unzip('proposals.zip', '..');

        fprintf('Done.\n');
        % Delete the downloaded zip file
        delete('proposals.zip');
    else
        error('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN');
    end
catch
    fprintf('Error occurred during download and extraction.\n');
end

% Change back to the original directory
cd(cur_dir);