


subjectIDs{1} = {...
    'BLNK_0007', 'BLNK_0009', 'BLNK_0017', 'BLNK_0018', 'BLNK_0032',...
    };
%   'BLNK_0036', 'BLNK_0040'};

sessionIDs{1} = {...
    '2023-09-07','2023-09-26','2023-09-21','2023-09-20','2023-10-30',...
    };
%    '2023-11-01','2023-11-15'};

subjectIDs{2} = {...
    'BLNK_0005', 'BLNK_0012', 'BLNK_0014', 'BLNK_0019', 'BLNK_0021',...
    'BLNK_0023', 'BLNK_0025', 'BLNK_0027' };

sessionIDs{2} = {...
    '2023-09-12','2023-10-04','2023-09-18','2023-09-25','2023-09-27',...
    '2023-09-29','2023-10-20','2023-10-23' };

psiLevels = [1  4  3  5  2  2  5  3  1  4  4  2  5  1  3  3  2  4  1  5  5  4  3  2  1];
ipsiOrContra = 'ipsi';
discardFirstTrialFlag = true;

data = [];
for gg = 1:2
    thisData = [];
    for ss = 1:length(subjectIDs{gg})
        subjectID = subjectIDs{gg}{ss};
        sessionID = sessionIDs{gg}{ss};
        for pp = 1:5
            scanIndicies = find(psiLevels == pp);
            [blinkVector,blinkVectorSEM,temporalSupport,palpWidthByAcq] = ...
                returnLFileTimeSeries(subjectID,sessionID,scanIndicies,ipsiOrContra,discardFirstTrialFlag);
            thisData(ss,pp,:)=blinkVector;
        end
    end
    data{gg} = squeeze(mean(thisData,1));
    figure
    plot(data{gg}');
end

