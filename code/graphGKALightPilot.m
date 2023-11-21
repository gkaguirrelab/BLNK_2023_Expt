function graphGKALightPilot(subjectID, sessionID)
% Graphs time series data at all PSI levels. Uses returnBlinkTimeSeries()
% function to do this. Make sure all I-Files have been "Made available
% offline", otherwise Matlab won't be able to access the files (Error
% message: Variable index exceeds table dimensions.). Make sure setpref()
% has the desired experiment folder name, otherwise Matlab will have the
% incorrect path to the files (Error message: Index exceeds the number of
% array elements. Index must not exceed 0.).
%
% Syntax:
%   graphGKALightPilot(subjectID, sessionID)
%
% Inputs:
%   subjectID          - String that identifies the subject. Format is
%                        'BLNK_****' where the *s are numbers.
%   sessionID          - String date of the session. Format is 'YYYY-MM-DD'.
%
% Example:
%{
    subjectID = 'GKA_HERO';
    sessionID = '2023-08-11_light';
    graphGKALightPilot(subjectID, sessionID);
%}

    % Change the data directory preference to point to the pilot experiment
    origDataDir = getpref('BLNK_2023_Expt','dataDir');
    newDataDir = strrep(origDataDir,'expt01_summer2023','light_level_pilot');
    newDataDir = strrep(origDataDir,'noise_cancellation','light_level_pilot');
    setpref('BLNK_2023_Expt','dataDir',newDataDir);

    % Pressure levels to plot (8/11/2023)
    %scanNumbers(1,:) = [1, 6, 7]; % 10 PSI
    %scanNumbers(2,:) = [2, 5, 8]; % 20 PSI
    %scanNumbers(3,:) = [3, 4, 9]; % 40 PSI

    % Pressure levels to plot (10/11/2023)
    %scanNumbers(1,:) = [1, 3, 5]; % 5 PSI
    %scanNumbers(2,:) = [2, 4, 6]; % 20 PSI
    
    % Pressure levels to plot (11/13/2023)
    scanNumbers(1,:) = [1, 3, 5, 7]; % 15 PSI
    scanNumbers(2,:) = [2, 4, 6, 8]; % 30 PSI
    
    % Set up graph figure
    figure('Name',sprintf('%s Time Series', subjectID));
    xlabel('Time (msecs)');
    ylabel('Lid Position (pixels)');
    title(sprintf('%s Time Series', subjectID), 'Interpreter', 'none');
    
    % Make graph easier to visualize (8/11/2023)
    %colors = ['g', 'b', 'r'];
    %legendNames = ["10 PSI", "20 PSI", "40 PSI"];
    
    % Make graph easier to visualize (10/11/2023)
    %colors = ['k', 'b'];
    %legendNames = ["5 PSI", "20 PSI"];
    
    % Make graph easier to visualize (11/13/2023)
    colors = ['k', 'b'];
    legendNames = ["15 PSI", "30 PSI"];
    
    % Iterate through the rows in scanNumbers (the different PSI levels)
    for ii = 1:size(scanNumbers,1)
        [blinkVector,blinkVectorSEM,temporalSupport] = returnBlinkTimeSeries(subjectID, sessionID, scanNumbers(ii,:), 'ipsi' );
        
        % Graph
        pHandle = patch([temporalSupport,fliplr(temporalSupport)],[blinkVector+blinkVectorSEM,fliplr(blinkVector-blinkVectorSEM)],colors(ii), 'HandleVisibility','off');
        pHandle.FaceAlpha = 0.1; pHandle.LineStyle = 'none';
        hold on;
        plot(temporalSupport,blinkVector,colors(ii),'LineWidth',2, 'DisplayName',legendNames(ii));
    end

    legend('Location','west')

    % Restore the original dataDir pref
    setpref('BLNK_2023_Expt','dataDir',origDataDir);

    % Automatically saves figure to Gerdin's Dropbox directory
    %savefig(sprintf('/Users/gerdinfalconi/Aguirre-Brainard Lab Dropbox/Gerdin Falconi/BLNK_analysis/light_level_pilot/%s/%s/%s Time Series', subjectID, sessionID, subjectID));

end