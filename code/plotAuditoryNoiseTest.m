

dataDirOrig = getpref('BLNK_2023_Expt','dataDir');


dataDir = '/Users/aguirre/Aguirre-Brainard Lab Dropbox/Geoffrey Aguirre/BLNK_data/noise_cancellation';
setpref('BLNK_2023_Expt','dataDir',dataDir)



subjectIDs{1} = {...
    'BLNK_0034','BLNK_0035','BLNK_0038'};

sessionIDs{1} = {...
    '2023-10-24','2023-10-26','2023-10-31'};


psiLevels = [1 2 2 1 2 1];
ipsiOrContra = 'contra';
discardFirstTrialFlag = true;

psiColors = {'r','k'};

data = [];
for gg = 1:1
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
        patch(x,y,psiColors{pp},'EdgeColor','none','FaceAlpha',0.1);
        hold on
        pHandle(pp) = plot(temporalSupport,data{gg}(pp,:),['-' psiColors{pp}],'LineWidth',2);
    end
    ylim([0 2]);
    legend(pHandle,{'noisy','silent'},'Location','best');
    subplot(1,2,2)
    bar(ss,mean(palpWidthByAcq));
    hold on
    ylim([0 200]);

end


setpref('BLNK_2023_Expt','dataDir',dataDirOrig)
