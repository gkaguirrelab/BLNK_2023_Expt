function graphNoiseCancellation(subjectID, sessionID)
% Graphs time series data without and with headphones (plus brown noise and
% noise cancellation). Uses returnBlinkTimeSeries() function to do this.
% Make sure all I-Files have been "Made available offline", otherwise
% Matlab won't be able to access the files (Error message: Variable index
% exceeds table dimensions.). Make sure setpref() has the desired
% experiment folder name, otherwise Matlab will have the incorrect path to
% the files (Error message: Index exceeds the number of array elements.
% Index must not exceed 0.).
%
% Syntax:
%   graphNoiseCancellation(subjectID, sessionID)
%
% Inputs:
%   subjectID          - String that identifies the subject. Format is
%                        'BLNK_****' where the *s are numbers.
%   sessionID          - String date of the session. Format is 'YYYY-MM-DD'.
%
% Example:
%{
    subjectID = 'BLNK_0034';
    sessionID = '2023-10-24';
    graphNoiseCancellation(subjectID, sessionID);
%}

    % Change the data directory preference to point to the noise cancellation experiment
    origDataDir = getpref('BLNK_2023_Expt','dataDir');
    newDataDir = strrep(origDataDir,'expt01_summer2023','noise_cancellation');
    newDataDir = strrep(origDataDir,'light_level_pilot','noise_cancellation');
    setpref('BLNK_2023_Expt','dataDir',newDataDir);

    % Groups to plot
    scanNumbers(1,:) = [1, 4, 6]; % Headphones off
    scanNumbers(2,:) = [2, 3, 5]; % Headphones on (plus brown noise and noise cancellation)
    
    % Set up graph figure
    figure('Name',sprintf('%s Time Series', subjectID));
    xlabel('Time (msecs)');
    ylabel('Lid Position (pixels)');
    title(sprintf('%s Time Series', subjectID), 'Interpreter', 'none');
    
    % Make graph easier to visualize
    colors = ['k', 'b'];
    legendNames = ["Headphones off", "Headphones on"];
    
    % Iterate through the rows in scanNumbers (the different groups)
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
    %savefig(sprintf('/Users/gerdinfalconi/Aguirre-Brainard Lab Dropbox/Gerdin Falconi/BLNK_analysis/noise_cancellation/%s/%s/%s Time Series', subjectID, sessionID, subjectID));

end