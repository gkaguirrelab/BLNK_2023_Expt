function [blinkVector,blinkVectorSEM,temporalSupport,palpWidthByAcq,blinkVectorRaw,palpebralWidthsByTrial] = ...
    returnLFileTimeSeries( subjectID,sessionID,scanIndicies,ipsiOrContra,discardFirstTrialFlag,nBootResamples,nSamplesBeforeStim,nSamplesAfterStim,deltaT )
% Loads L-Files and conducts an analysis of time series data
%
% Syntax:
%   [blinkVector,temporalSupport] = returnBlinkTimeSeries( subjectID, targetPSI )
%
% Description:
%   Briana: Describe how the iFiles are structured and how we load them
%
%   The videos are recorded with a 300 Hz camera, implying a deltaT of 3.33
%   msecs. This is supported by observing that the first 31 observations
%   correspond to 0-100 msecs, thus 100 msecs / 30 intervals = 3.33 msecs.
%
% Inputs:
%   subjectID             - Scalar. 5 digit integer that identifies the
%                           subject.
%   targetPSI             - Scalar. One of the valid PSI targets:
%                               {3.5, 7.5, 15, 30, 60}
%                           If set empty, all PSI levels are used
%   sessionID             - Scalar. Valid values are:
%                               {1, 2}
%                           If set empty, both sessions are used
%
% Outputs:
%   blinkVector           - Vector
%   temporalSupport       - Vector
%   nTrials               - Scalar
%   blinkVectorRaw        - nTrials x time matrix of raw responses
%
%{
    % Bootstrap resample across all acquisitions at one PSI
    stimLevels = [1  4  3  5  2  2  5  3  1  4  4  2  5  1  3  3  2  4  1  5  5  4  3  2  1];
    subjectID = 'BLNK_0009';
    sessionID = '2023-09-26';
    ipsiOrContra = 'contra';
    discardFirstTrialFlag = true;
    figure
    for ss = 1:5
        scanIndicies = find(stimLevels == ss);
        [blinkVector,blinkVectorSEM,temporalSupport,palpWidthByAcq] = ...
            returnLFileTimeSeries(subjectID,sessionID,scanIndicies,ipsiOrContra,discardFirstTrialFlag);
        subplot(1,2,1)
        plot(temporalSupport,blinkVector,'-');
        hold on
        subplot(1,2,2)
        plot(ss,mean(palpWidthByAcq),'o');
        hold on
        palpWidthCI = [mean(palpWidthByAcq) - std(palpWidthByAcq)/sqrt(length(palpWidthByAcq)), 
            mean(palpWidthByAcq) + std(palpWidthByAcq)/sqrt(length(palpWidthByAcq))];
        plot([ss ss],palpWidthCI,'-');
    end
    subplot(1,2,1)
    legend({'0','5','10','20','40'},'Location','southeast');
    subplot(1,2,2)
    ylim([0 300]);
%}


arguments
    subjectID
    sessionID
    scanIndicies
    ipsiOrContra = 'ipsi';
    discardFirstTrialFlag = false;
    nBootResamples (1,1) {mustBeNumeric} = 0;
    nSamplesBeforeStim = 10;
    nSamplesAfterStim = 250;
    deltaT = 3.333;
end


% Set a counter to return
nTrials = 0;

% Initialize vectors for return
blinkVectorRaw = [];
trialIndices = [];
blinkVectorBoots = [];

% Define the location of the L-files
dataDirPath = fullfile( ...
    getpref('BLNK_2023_Expt','dataDir'), ...
    subjectID, sessionID,'BlinkCNS Improved L-Files' );

% Get the list of acquisitions in the directory
dirList = dir(fullfile(dataDirPath,'l-file*'));

% Throw a warning if the number of directories is something other than 25
if length(dirList) ~= 25
warning('Something other than 25 acquisition directories in here');
end

% Turn off a warning during readtable
warnState = warning();
warning('off','MATLAB:table:ModifiedAndSavedVarnames');

% Loop over the acquisitions
for ii = 1:length(scanIndicies)

    % Load the iFile in this for this scan
    fullFilePath = fullfile(dirList(scanIndicies(ii)).folder,dirList(scanIndicies(ii)).name);

    % Load the iFile into a table
    T = readtable(fullFilePath);

    % find stimulus arrivals
    stimVarName = T.Properties.VariableNames{2};
    rights = find(strcmp('MC-OD',T.(stimVarName)(:,1)));
    lefts = find(strcmp('MC-OS',T.(stimVarName)(:,1)));
    all = sort(cat(1,rights,lefts));

    % get times
    starts = all - nSamplesBeforeStim;
    ends = all + nSamplesAfterStim;

    % Issue a warning if there are fewer than 8 trials
    if length(starts)<8
        fprintf(['Only %d trials: ' fullfile(num2str(subjectID),iFileName) '\n'],length(starts));
    end

    % get means across trials
    pos = nan(length(starts),nSamplesBeforeStim+nSamplesAfterStim+1);

    for jj = 1:length(starts)

        % Handle the edge case of the time-series starting after the
        % desired "numBefore" window
        offset = max([1 -starts(jj)+2]);

        % Handle the laterality of the stimulus and the choice of returning
        % the ipsi or contra response
        if ismember(all(jj),rights)
            switch ipsiOrContra
                case 'ipsi'
                    columnUpperIdx = 3;
                    columnLowerIdx = 5;
                case 'contra'
                    columnUpperIdx = 4;
                    columnLowerIdx = 6;
            end
        else
            switch ipsiOrContra
                case 'ipsi'
                    columnUpperIdx = 4;
                    columnLowerIdx = 6;
                case 'contra'
                    columnUpperIdx = 3;
                    columnLowerIdx = 5;
            end
        end

        % Get this timeseries
        tempUpper = table2array(T(max([1 starts(jj)]):ends(jj),columnUpperIdx));
        tempLower = table2array(T(max([1 starts(jj)]):ends(jj),columnLowerIdx));

        % Convert to % closure
        palpWidth(jj) = mean(tempUpper(1:nSamplesBeforeStim)) - mean(tempLower(1:nSamplesBeforeStim));
        temp = (tempUpper - tempLower) / palpWidth(jj);

        % Add it to the matrix
        pos(jj,offset:end) = temp';

        % Store the trial index
        trialIndices = [trialIndices jj];

        % Increment the trial count
        nTrials = nTrials + 1;

    end

    % Discard the first trial if requested
    if discardFirstTrialFlag
        pos = pos(2:end,:);
        palpWidth = palpWidth(2:end);
    end

    % Take the average across trials
    posAvg = mean(pos,1,"omitnan");

% center pre-stimulus around zero    
%    posAvgPreStim = mean(posAvg(1:nSamplesBeforeStim));
%    posAvg = posAvg - posAvgPreStim;

    % Store the response
    respByAcq(ii,:) = posAvg;

    % Store the mean palpebral width
    palpWidthByAcq(ii) = mean(palpWidth);

    % Create a concatenated, raw vector of responses
    blinkVectorRaw = [blinkVectorRaw; pos-mean(pos(:,1:nSamplesBeforeStim),2)];

end

% Restore the warning state
warning(warnState);

% Get the mean deltaT and assemble the temporal support
temporalSupport = -nSamplesBeforeStim*deltaT:deltaT:nSamplesAfterStim*deltaT;

% Conduct a resampling with replacement of the vector if requested. We
% create an anonymous function for the mean to force action over the first
% dimension in case there is just one acquisition. We also reset the random
% seed every time we reach this point so that we use the same bootSam every
% time, thus linking the resampling across acquisitions and sides (ipsi /
% contra)
if nBootResamples>0
    rng default;
    meanFunc = @(x) mean(x,1);
    [blinkVectorBoots, bootSam] = bootstrp(nBootResamples,meanFunc,respByAcq);
end

% Return the blinkVector
blinkVector = mean(respByAcq,1);
blinkVectorSEM = std(respByAcq,1)./sqrt(size(respByAcq,1));


end
