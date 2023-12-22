function graphLFileTimeSeries(subjectID, sessionID)
% Graphs time series data at all PSI levels. Uses returnLFileTimeSeries()
% function to do this. Make sure all improved L-Files have been "Made available
% offline", otherwise Matlab won't be able to access the files (Error
% message: Variable index exceeds table dimensions.). Make sure setpref()
% has the desired experiment folder name, otherwise Matlab will have the
% incorrect path to the files (Error message: Index exceeds the number of
% array elements. Index must not exceed 0.).
%
% Syntax:
%   graphLFileTimeSeries(subjectID, sessionID)
%
% Inputs:
%   subjectID          - String that identifies the subject. Format is
%                        'BLNK_****' where the *s are numbers.
%   sessionID          - String date of the session. Format is 'YYYY-MM-DD'.
%
% Example:
%{
    subjectID = 'BLNK_0005';
    sessionID = '2023-09-12';
    graphLFileTimeSeries(subjectID, sessionID);
%}

    % Change the data directory preference to point to the pilot experiment
    origDataDir = getpref('BLNK_2023_Expt','dataDir');
    newDataDir = strrep(origDataDir,'light_level_pilot','expt01_summer2023');
    newDataDir = strrep(origDataDir,'noise_cancellation','expt01_summer2023');
    setpref('BLNK_2023_Expt','dataDir',newDataDir);
    
    % Pressure levels to plot
    scanNumbers(1,:) = [1, 9, 14, 19, 25]; % 0 PSI
    scanNumbers(2,:) = [5, 6, 12, 17, 24]; % 5 PSI
    scanNumbers(3,:) = [3, 8, 15, 16, 23]; % 10 PSI
    scanNumbers(4,:) = [2, 10, 11, 18, 22]; % 20 PSI
    scanNumbers(5,:) = [4, 7, 13, 20, 21]; % 40 PSI
    
    % Set up graph figure
    figure('Name',sprintf('%s Improved Time Series', subjectID));
    xlabel('Time (msecs)');
    ylabel('Lid Position (pixels)');
    title(sprintf('%s Time Series', subjectID), 'Interpreter', 'none');
    
    % Make graph easier to visualize
    colors = ['m', 'k', 'g', 'b', 'r'];
    legendNames = ["0 PSI", "5 PSI", "10 PSI", "20 PSI", "40 PSI"];
    
    % Iterate through the rows in scanNumbers (the different PSI levels)
    for ii = 1:size(scanNumbers,1)
        [blinkVector,blinkVectorSEM,temporalSupport] = returnLFileTimeSeries(subjectID, sessionID, scanNumbers(ii,:), 'ipsi' );
        
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
    savefig(sprintf('/Users/gerdinfalconi/Aguirre-Brainard Lab Dropbox/Gerdin Falconi/BLNK_analysis/expt01_summer2023/%s/%s/BlinkCNS Improved L-Files/%s Improved Time Series', subjectID, sessionID, subjectID));

end