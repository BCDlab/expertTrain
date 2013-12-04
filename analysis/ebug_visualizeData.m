% basic analysis script for expertTrain experiments

% TODO: plot individual subjects along with mean/SEM

% TODO: is there a better kind of plot to use, e.g., box and whisker?

%% set the subjects and other variables

expName = 'EBUG';

%serverDir = fullfile(filesep,'Volumes','curranlab','Data',expName,'Behavioral','Sessions');
% Use Path below when curranlab server is mounted on another username
serverDir = fullfile(filesep,'Volumes','curranlab','Data',expName,'Behavioral','Sessions');

%serverLocalDir = fullfile(filesep,'Volumes','RAID','curranlab','Data',expName,'Behavioral','Sessions');
% Use Path below when curranlab server is mounted on another username
serverLocalDir = fullfile(filesep,'Volumes','RAID','curranlab','Data',expName,'Behavioral','Sessions');
localDir = fullfile(getenv('HOME'),'data',expName,'Behavioral','Sessions');
if exist(serverDir,'dir')
  dataroot = serverDir;
elseif exist(serverLocalDir,'dir')
  dataroot = serverLocalDir;
elseif exist(localDir,'dir')
  dataroot = localDir;
else
  error('No data directory found.');
end

subjects = {
   'EBUG001';
   'EBUG002';
   'EBUG003';
   'EBUG004';
   'EBUG005';
   'EBUG006';
   'EBUG007';
   'EBUG008';
  };

saveFigs = true;
if saveFigs
  figsDir = fullfile(dataroot,'figs');
  if ~exist(figsDir,'dir')
    mkdir(figsDir);
  end
end

%% run the data processing script

% onlyCompleteSub = false;
% printResults = true;
% saveResults = true;

onlyCompleteSub = false;
printResults = true;
saveResults = true;

[results] = ebug_processData(dataroot,subjects,onlyCompleteSub,printResults,saveResults);

%% Plot basic and subordinate RTs across training days, all phases on one figure

nTrainSes = 6;
% phases = {'name_1','name_2','name_3','name_4'};
phases = {'name_1'};

data.overall = nan(length(subjects),(nTrainSes * length(phases) - 2));
data.basic = nan(length(subjects),(nTrainSes * length(phases) - 2));
data.subord = nan(length(subjects),(nTrainSes * length(phases) - 2));

% dataMeasure = 'rt';
% dataMeasure = 'rt_cor';
% dataMeasure = 'rt_inc';
dataMeasure = 'acc';
% dataMeasure = 'dp';

tpCounter = 0;
for t = 1:nTrainSes
  sesName = sprintf('train%d',t);
  for p = 1:length(phases)
    if isfield(results.(sesName),phases{p})
      tpCounter = tpCounter + 1;
      data.overall(:,tpCounter) = results.(sesName).(phases{p}).overall.(dataMeasure);
      data.basic(:,tpCounter) = results.(sesName).(phases{p}).basic.(dataMeasure);
      data.subord(:,tpCounter) = results.(sesName).(phases{p}).subord.(dataMeasure);
    end
  end
end

figure

basic_mean = nanmean(data.basic,1);
basic_sem = nanstd(data.basic,1) ./ sqrt(sum(~isnan(data.basic)));
errorbar(basic_mean,basic_sem,'d-','LineWidth',2,'Color',[0.5 0.5 0.5]);
hold on

subordData_mean = nanmean(data.subord,1);
subordData_sem = nanstd(data.subord,1) ./ sqrt(sum(~isnan(data.subord)));
errorbar(subordData_mean,subordData_sem,'ks-','LineWidth',2);

% overall_mean = nanmean(data.overall,1);
% overall_sem = nanstd(data.overall,1) ./ sqrt(sum(~isnan(data.overall)));
% errorbar(overall_mean,overall_sem,'ro-','LineWidth',2);
hold off

title(sprintf('Naming phase: %s',strrep(dataMeasure,'_','\_')));
xlabel('Training Day');
if strcmp(dataMeasure,'rt') || strcmp(dataMeasure,'rt_cor') || strcmp(dataMeasure,'rt_inc')
  ylabel('Response Time (ms)');
  
%   axis([0.5 (size(data.subord,2) + 0.5) 800 round(max(data.overall(:))/100)*100 + 200]);
  axis([0.5 (size(data.subord,2) + 0.5) 300 round(max(data.overall(:))/100)*100 + 600]);
  
  
  %if ~strcmp(dataMeasure,'rt_inc')
  %  axis([0.5 (size(data.subord,2) + 0.5) 0 600]);
  %else
  %  axis([0.5 (size(data.subord,2) + 0.5) 0 1500]);
  %end
  
  legendLoc = 'NorthEast';
elseif strcmp(dataMeasure,'acc')
  ylabel('Accuracy');
  
%   axis([0.5 (size(data.subord,2) + 0.5) 0.5 round(max(data.overall(:))*100)/100]);
  axis([0.5 (size(data.subord,2) + 0.5) 0.3 1]);
  
  legendLoc = 'SouthEast';
elseif strcmp(dataMeasure,'dp')
  ylabel('d''');
  
%   axis([0.5 (size(data.subord,2) + 0.5) 0 ceil(max(data.overall(:)))]);
%   axis([0.5 (size(data.subord,2) + 0.5) 0 5]);
   axis([0.5 (size(data.subord,2) + 0.5) -1 6]);
  
  legendLoc = 'SouthEast';
end
% new_xlabel = [ones(1,length(phases)/2) ones(1,length(phases))*2 ones(1,length(phases))*3 ones(1,length(phases))*4 ones(1,length(phases))*5 ones(1,length(phases))*6];
% set(gca,'XTick',1:length(new_xlabel));
% set(gca,'XTickLabel',new_xlabel);

legend({'Basic','Subordinate'},'Location',legendLoc);
%legend({'Basic','Subordinate','Overall'},'Location',legendLoc);

%publishfig(gcf,0);

if saveFigs
  print(gcf,'-dpng',fullfile(figsDir,sprintf('training_name_%s',dataMeasure)));
end

%% Matching accuracy for pretest, posttest, posttest_delay

% plot basic and subordinate data for pretest, posttest, posttest_delay

dataMeasure = 'dp';
dataLabel = 'd''';
ylimits = [0 4];

% dataMeasure = 'acc';
% dataLabel = 'Accuracy';
% ylimits = [0 1];

sessions = {'pretest', 'train1', 'posttest', 'posttest_delay'};
phases = {'match_1'};
training = {'trained','untrained'};
naming = {'basic','subord'};

data.(dataMeasure) = struct;
for n = 1:length(naming)
  data.(dataMeasure).(naming{n}) = nan(length(subjects),length(sessions),length(phases),length(training));
end

for s = 1:length(sessions)
  sesName = sessions{s};
  for p = 1:length(phases)
    for t = 1:length(training)
      for n = 1:length(naming)
        data.(dataMeasure).(naming{n})(:,s,p,t) = results.(sesName).(phases{p}).(training{t}).(naming{n}).(dataMeasure);
      end
    end
  end
end

for p = 1:length(phases)
  for n = 1:length(naming)
    figure
    data_mean = nan(length(sessions),length(training));
    data_sem = nan(length(sessions),length(training));
    
    for t = 1:length(training)
      for s = 1:length(sessions)
        data_mean(s,t) = nanmean(data.(dataMeasure).(naming{n})(:,s,p,t),1);
        data_sem(s,t) = nanstd(data.(dataMeasure).(naming{n})(:,s,p,t),1) ./ sqrt(sum(~isnan(data.(dataMeasure).(naming{n})(:,s,p,t))));
      end
    end
    
    bw_title = sprintf('%s%s: %s',upper(naming{n}(1)),naming{n}(2:end),strrep(phases{p},'_','\_'));
    bw_groupnames = {'Pretest', 'Train 1', 'Posttest', 'One week later'};
    bw_legend = {'Trained','Untrained'};
    %bw_xlabel = 'Test day';
    bw_xlabel = [];
    bw_ylabel = dataLabel;
    bw_colormap = 'gray';
    bw_data = data_mean;
    bw_errors = data_sem;
    h = barweb(bw_data,bw_errors,[],bw_groupnames,bw_title,bw_xlabel,bw_ylabel,bw_colormap,[],bw_legend,[],'plot');
    set(h.legend,'Location','NorthWest');
    axis([0.5 (length(sessions)+0.5) ylimits(1) ylimits(2)]);
    publishfig(gcf,0);
    
    if saveFigs
      print(gcf,'-dpng',fullfile(figsDir,sprintf('prepost_trainUn_%s_%s_%s',phases{p},dataMeasure,naming{n})));
    end
  end
end

%% Match accuracy for training days - bar graph

% plot basic and subordinate data for training days

dataMeasure = 'dp';
dataLabel = 'd''';
ylimits = [0 4];

% dataMeasure = 'acc';
% dataLabel = 'Accuracy';
% ylimits = [0.5 1];

sessions = {'train2', 'train3', 'train4', 'train5', 'train6'};
phases = {'match_1','match_2'};
training = {'trained','untrained'};
naming = {'basic','subord'};

data.(dataMeasure) = struct;
for n = 1:length(naming)
  data.(dataMeasure).(naming{n}) = nan(length(subjects),length(sessions),length(phases),length(training));
end

for s = 1:length(sessions)
  sesName = sessions{s};
  for p = 1:length(phases)
    for t = 1:length(training)
      for n = 1:length(naming)
        data.(dataMeasure).(naming{n})(:,s,p,t) = results.(sesName).(phases{p}).(training{t}).(naming{n}).(dataMeasure);
      end
    end
  end
end

for p = 1:length(phases)
  for n = 1:length(naming)
    figure
    data_mean = nan(length(sessions),length(training));
    data_sem = nan(length(sessions),length(training));
    
    for t = 1:length(training)
      for s = 1:length(sessions)
        data_mean(s,t) = nanmean(data.(dataMeasure).(naming{n})(:,s,p,t),1);
        data_sem(s,t) = nanstd(data.(dataMeasure).(naming{n})(:,s,p,t),1) ./ sqrt(sum(~isnan(data.(dataMeasure).(naming{n})(:,s,p,t))));
      end
    end
    
    bw_title = sprintf('%s%s: %s',upper(naming{n}(1)),naming{n}(2:end),strrep(phases{p},'_','\_'));
    bw_groupnames = {'train2', 'train3', 'train4', 'train5', 'train6'};
    bw_legend = {'Trained','Untrained'};
    %bw_xlabel = 'Test day';
    bw_xlabel = [];
    bw_ylabel = dataLabel;
    bw_colormap = 'gray';
    bw_data = data_mean;
    bw_errors = data_sem;
    h = barweb(bw_data,bw_errors,[],bw_groupnames,bw_title,bw_xlabel,bw_ylabel,bw_colormap,[],bw_legend,[],'plot');
    set(h.legend,'Location','NorthWest');
    axis([0.5 (length(sessions)+0.5) ylimits(1) ylimits(2)]);
    publishfig(gcf,0);
    
    if saveFigs
      print(gcf,'-dpng',fullfile(figsDir,sprintf('trainDays_trainUn_%s_%s_%s',phases{p},dataMeasure,naming{n})));
    end
  end
end

%% recognition accuracy for pretest, posttest, posttest_delay

dataMeasure = 'dp';
dataLabel = 'd''';
ylimits = [0 3];

% dataMeasure = 'acc';
% dataLabel = 'Accuracy';
% ylimits = [0.5 1];

sessions = {'pretest', 'posttest', 'posttest_delay'};
phases = {'recog_1'};
recogField = {'basic','subord'};

data.(dataMeasure) = struct;
data.(dataMeasure) = nan(length(subjects),length(sessions),length(phases),length(recogField));
% for n = 1:length(naming)
%   data.(dataMeasure).(naming{n}) = nan(length(subjects),length(sessions),length(phases),length(recogField));
% end

for s = 1:length(sessions)
    sesName = sessions{s};
    for p = 1:length(phases)
        for t = 1:length(recogField)
            data.(dataMeasure)(:,s,p,t) = results.(sesName).(phases{p}).(recogField{t}).(dataMeasure);
        end
    end
end

for p = 1:length(phases)
    figure
    data_mean = nan(length(sessions),length(recogField));
    data_sem = nan(length(sessions),length(recogField));
    
    for t = 1:length(recogField)
        for s = 1:length(sessions)
            data_mean(s,t) = nanmean(data.(dataMeasure)(:,s,p,t),1);
            data_sem(s,t) = nanstd(data.(dataMeasure)(:,s,p,t),1) ./ sqrt(sum(~isnan(data.(dataMeasure)(:,s,p,t))));
        end
        
        bw_title = sprintf('%s',strrep(phases{p},'_','\_'));
        bw_groupnames = {'pretest', 'posttest', 'One week later'};
        %bw_legend = {'Recognition'};
        bw_legend = {'Basic','Subord'};
        %bw_xlabel = 'Test day';
        bw_xlabel = [];
        bw_ylabel = dataLabel;
        bw_colormap = 'gray';
        bw_data = data_mean;
        bw_errors = data_sem;
        bw_width = 0.5;
        h = barweb(bw_data,bw_errors,bw_width,bw_groupnames,bw_title,bw_xlabel,bw_ylabel,bw_colormap,[],bw_legend,[],'plot');
        set(h.legend,'Location','NorthWest');
        axis([0.5 (length(sessions)+0.5) ylimits(1) ylimits(2)]);
        publishfig(gcf,0);
        
        if saveFigs
            print(gcf,'-dpng',fullfile(figsDir,sprintf('prepost_recog_%s_%s_%s',phases{p},dataMeasure,recogField{t})));
        end
    end
end


