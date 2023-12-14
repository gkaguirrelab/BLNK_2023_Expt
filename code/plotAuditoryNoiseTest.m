
clear

dataDirOrig = getpref('BLNK_2023_Expt','dataDir');


dataDir = '/Users/aguirre/Aguirre-Brainard Lab Dropbox/Geoffrey Aguirre/BLNK_data/noise_cancellation';
setpref('BLNK_2023_Expt','dataDir',dataDir)



subjectIDs{1} = {...
    'BLNK_0003','BLNK_0034','BLNK_0035','BLNK_0038','BLNK_0044','BLNK_0045','BLNK_0046','BLNK_0047','BLNK_0048'};

sessionIDs{1} = {...
    '2023-11-30','2023-10-24','2023-10-26','2023-10-31','2023-12-07','2023-12-01','2023-12-06','2023-12-07','2023-12-08'};


psiLevels = [1 2 2 1 2 1];
ipsiOrContra = {'ipsi','contra'};
discardFirstTrialFlag = true;

psiColors = {'r','k'};

data = [];
gg=1;


figure
for side = 1:2
    thisData = [];
    for ss = 1:length(subjectIDs{gg})
        subjectID = subjectIDs{gg}{ss};
        sessionID = sessionIDs{gg}{ss};
        for pp = 1:max(psiLevels)
            scanIndicies = find(psiLevels == pp);
            [blinkVector,blinkVectorSEM,temporalSupport,palpWidthByAcq] = ...
                returnLFileTimeSeries(subjectID,sessionID,scanIndicies,ipsiOrContra{side},discardFirstTrialFlag);
            thisData(ss,pp,:)=blinkVector;
            thisDataSEM(ss,pp,:)=blinkVectorSEM;
        end
    end
    data{gg} = squeeze(mean(thisData,1));
    dataSEM{gg} = squeeze(std(thisData,[],1))./sqrt(length(subjectIDs{gg}));
    subplot(1,2,side)
    plot(temporalSupport,ones(size(temporalSupport)),':k');
    hold on
    for pp = 1:size(data{gg},1)
        x = [temporalSupport, fliplr(temporalSupport)];
        y = [(data{gg}(pp,:)+dataSEM{gg}(pp,:)), fliplr((data{gg}(pp,:)-dataSEM{gg}(pp,:))) ];
        patch(x,y,psiColors{pp},'EdgeColor','none','FaceAlpha',0.1);
        pHandle(pp) = plot(temporalSupport,data{gg}(pp,:),['-' psiColors{pp}],'LineWidth',2);
    end    
    ylim([0 1.5]);
    legend(pHandle,{'noisy','silent'},'Location','best');
    title(ipsiOrContra{side});

end


setpref('BLNK_2023_Expt','dataDir',dataDirOrig)
