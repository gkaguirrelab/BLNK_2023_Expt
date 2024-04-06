function BLNK_2023_ExptLocalHook
%  BLNK_2023_ExptLocalHook
%
% For use with the ToolboxToolbox.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/BLNK_2023_ExptLocalHook.m
%
% Each time you run tbUseProject('BLNK_2023_Expt'), ToolboxToolbox will
% execute your local copy of this file to do setup for BLNK_2023_Expt.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


projectName = 'BLNK_2023_Expt';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

% Get user name
if ismac
    [~, userName] = system('whoami');
    userName = strtrim(userName);
elseif isunix
    userName = getenv('USER');
elseif ispc
    userName = getenv('username');
else
    disp('What are you using?')
end

% Get the DropBox path
if ismac
    dbJsonConfigFile = '~/.dropbox/info.json';
    fid = fopen(dbJsonConfigFile);
    raw = fread(fid,inf);
    str = char(raw');
    fclose(fid);
    val = jsondecode(str);
    dropboxBaseDir = val.business.path;
else
    error('Need to set up DropBox path finding for non-Mac machine')
end

% Path to data and analysis directories
switch userName
    case 'aguirre'
        analysisDir = fullfile(dropboxBaseDir,'BLNK_analysis','expt01_summer2023');
        dataDir = fullfile(dropboxBaseDir,'BLNK_data','expt01_summer2023');
    otherwise
        analysisDir = fullfile(dropboxBaseDir,'BLNK_analysis','expt01_summer2023');
        dataDir = fullfile(dropboxBaseDir,'BLNK_data','expt01_summer2023');
end

% Set the prefs
setpref(projectName,'analysisDir',analysisDir);
setpref(projectName,'dataDir',dataDir);


