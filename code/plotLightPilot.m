

dataDirOrig = getpref('BLNK_2023_Expt','dataDir')


dataDir = '/Users/aguirre/Aguirre-Brainard Lab Dropbox/Geoffrey Aguirre/BLNK_data/light_level_pilot';
setpref('BLNK_2023_Expt','dataDir',dataDir)



subjectIDs{1} = {...
    'BLNK_0034'};

sessionIDs{1} = {...
    '2023-11-13_dark'};

subjectIDs{2} = {...
    'BLNK_0034'};

sessionIDs{2} = {...
    '2023-11-13_light'};

psiLevels = [1 2 1 2 1 2 1 2];
ipsiOrContra = 'ipsi';
discardFirstTrialFlag = true;


data = [];
for gg = 1:2
    thisData = [];
    for ss = 1:length(subjectIDs{gg})
        subjectID = subjectIDs{gg}{ss};
        sessionID = sessionIDs{gg}{ss};
        for pp = 1:max(psiLevels)
            scanIndicies = find(psiLevels == pp);
            [blinkVector,blinkVectorSEM,temporalSupport,palpWidthByAcq] = ...
                returnLFileTimeSeries(subjectID,sessionID,scanIndicies,ipsiOrContra,discardFirstTrialFlag);
            thisData(ss,pp,:)=blinkVector;
            thisDataSEM(ss,pp,:)=blinkVectorSEM;
        end
    end
    data{gg} = squeeze(mean(thisData,1));
    dataSEM{gg} = squeeze(mean(thisDataSEM,1));
    figure
    subplot(1,2,1)
    for pp = 1:size(data{gg},1)
        x = [temporalSupport, fliplr(temporalSupport)];
        y = [(data{gg}(pp,:)+dataSEM{gg}(pp,:)), fliplr((data{gg}(pp,:)-dataSEM{gg}(pp,:))) ];
        patch(x,y,'r','EdgeColor','none','FaceAlpha',0.1);
        hold on
        plot(temporalSupport,data{gg}(pp,:),'-k','LineWidth',2);
    end
    ylim([0 1.25]);
    subplot(1,2,2)
    bar(ss,mean(palpWidthByAcq));
    hold on
    ylim([0 200]);

end


setpref('BLNK_2023_Expt','dataDir',dataDirOrig)
