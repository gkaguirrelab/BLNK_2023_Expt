function graphBlinkTimeSeries(subjectID, sessionID)
% Graphs time series data at all PSI levels. Uses returnBlinkTimeSeries()
% function to do this. Make sure all I-Files have been "Made available
% offline", otherwise Matlab won't be able to access the files (Error
% message: Variable index exceeds table dimensions.).
%
% Syntax:
%   graphBlinkTimeSeries(subjectID, sessionID)
%
% Inputs:
%   subjectID          - String that identifies the subject. Format is
%                        'BLNK_****' where the *s are numbers.
%   sessionID          - String date of the session. Format is 'YYYY-MM-DD'.
%
% Example:
%{
    subjectID = 'BLNK_0001';
    sessionID = '2023-07-19';
    graphBlinkTimeSeries(subjectID, sessionID);
%}
    
    % Pressure levels to plot
    scanNumbers(1,:) = [4, 7, 13, 20, 21]; % 40 PSI
    scanNumbers(2,:) = [2, 10, 11, 18, 22]; % 20 PSI
    scanNumbers(3,:) = [3, 8, 15, 16, 23]; % 10 PSI
    scanNumbers(4,:) = [5, 6, 12, 17, 24]; % 5 PSI
    scanNumbers(5,:) = [1, 9, 14, 19, 25]; % 0 PSI
    
    colors = ['r', 'b', 'g', 'k', 'm'];
    figure('Name',sprintf('%s Time Series', subjectID));
    
    for ii = 1:size(scanNumbers,1)
        [blinkVector,blinkVectorSEM,temporalSupport] = returnBlinkTimeSeries(subjectID, sessionID, scanNumbers(ii,:), 'ipsi' );
        
        % Graph
        pHandle = patch([temporalSupport,fliplr(temporalSupport)],[blinkVector+blinkVectorSEM,fliplr(blinkVector-blinkVectorSEM)],colors(ii));
        pHandle.FaceAlpha = 0.1; pHandle.LineStyle = 'none';
        hold on;
        plot(temporalSupport,blinkVector,colors(ii),'LineWidth',2);
        xlabel('Time (msecs)');
        ylabel('Lid Position (pixels)');
        title(sprintf('%s Time Series', subjectID), 'Interpreter', 'none');
    end
    
    % Automatically saves figure to Gerdin's Dropbox directory
    %savefig(sprintf('/Users/gerdinfalconi/Aguirre-Brainard Lab Dropbox/Gerdin Falconi/BLNK_analysis/expt01_summer2023/%s/%s/%s Time Series', subjectID, sessionID, subjectID));

end