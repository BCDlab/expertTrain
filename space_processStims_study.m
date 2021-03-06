function [cfg,expParam,imgStimStruct,wordStimStruct] = space_processStims_study(cfg,expParam,sesName,phaseName,phaseCount,imgStimStruct,wordStimStruct)
% function [cfg,expParam,imgStimStruct,wordStimStruct] = space_processStims_study(cfg,expParam,sesName,phaseName,phaseCount,imgStimStruct,wordStimStruct)

fprintf('Configuring %s %s (%d)...\n',sesName,phaseName,phaseCount);

phaseCfg = cfg.stim.(sesName).(phaseName)(phaseCount);

if ~isfield(phaseCfg,'categoryNames')
  if ~phaseCfg.isExp
    phaseCfg.categoryNames = cfg.stim.practice.categoryNames;
  else
    phaseCfg.categoryNames = cfg.stim.categoryNames;
  end
end

% initialize to hold the study stimuli
studyStims_img.p1 = [];
studyStims_word.p1 = [];

studyStims_img.onePres = [];
studyStims_word.onePres = [];

studyStims_img.buff_start = [];
studyStims_word.buff_start = [];
studyStims_img.buff_end = [];
studyStims_word.buff_end = [];

if ~phaseCfg.isExp
  % for the practice
  
  % spaced
  
  % put all the image stimuli together, across categories
  for cn = 1:length(cfg.stim.practice.categoryNames)
    if ismember(cfg.stim.practice.categoryNames{cn},phaseCfg.categoryNames)
      [studyStims_img.p1,imgStimStruct(cn).catStims] = space_divvyStims(...
        imgStimStruct(cn).catStims,studyStims_img.p1,...
        cfg.stim.practice.nPairs_study_targ_spaced,...
        cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,true,[],1,[],[]});
    end
  end
  
  % do the word stimuli
  [studyStims_word.p1,wordStimStruct.wordStims] = space_divvyStims(...
    wordStimStruct.wordStims,studyStims_word.p1,...
    cfg.stim.practice.nPairs_study_targ_spaced * length(phaseCfg.categoryNames),...
    cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,true,[],1,[],[]});
  
  % massed
  
  % put all the image stimuli together, across categories
  for cn = 1:length(cfg.stim.practice.categoryNames)
    if ismember(cfg.stim.practice.categoryNames{cn},phaseCfg.categoryNames)
      [studyStims_img.p1,imgStimStruct(cn).catStims] = space_divvyStims(...
        imgStimStruct(cn).catStims,studyStims_img.p1,...
        cfg.stim.practice.nPairs_study_targ_massed,...
        cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,false,0,1,[],[]});
    end
  end
  
  % do the word stimuli
  [studyStims_word.p1,wordStimStruct.wordStims] = space_divvyStims(...
    wordStimStruct.wordStims,studyStims_word.p1,...
    cfg.stim.practice.nPairs_study_targ_massed * length(phaseCfg.categoryNames),...
    cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,false,0,1,[],[]});
  
  % single presentation
  
%     if cfg.stim.practice.nPairs_study_targ_onePres > 0
%       % put all the image stimuli together, across categories
%       for cn = 1:length(cfg.stim.practice.categoryNames)
%         if ismember(cfg.stim.practice.categoryNames{cn},phaseCfg.categoryNames)
%           [studyStims_img.p1,imgStimStruct(cn).catStims] = space_divvyStims(...
%             imgStimStruct(cn).catStims,studyStims_img.p1,...
%             cfg.stim.practice.nPairs_study_targ_onePres,...
%             cfg.stim.practice.rmStims_init,cfg.stim.practice.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,false,-1,1,[],[]});
%         end
%       end
%   
%       % do the word stimuli
%       [studyStims_word.p1,wordStimStruct.wordStims] = space_divvyStims(...
%         wordStimStruct.wordStims,studyStims_word.p1,...
%         cfg.stim.practice.nPairs_study_targ_onePres * length(phaseCfg.categoryNames),...
%         cfg.stim.practice.rmStims_init,cfg.stim.practice.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,false,-1,1,[],[]});
%     end
  
  if cfg.stim.practice.nPairs_study_targ_onePres > 0
    % put all the image stimuli together, across categories
    for cn = 1:length(cfg.stim.practice.categoryNames)
      if ismember(cfg.stim.practice.categoryNames{cn},phaseCfg.categoryNames)
        [studyStims_img.onePres,imgStimStruct(cn).catStims] = space_divvyStims(...
          imgStimStruct(cn).catStims,studyStims_img.onePres,...
          cfg.stim.practice.nPairs_study_targ_onePres,...
          cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,false,-1,1,[],[]});
      end
    end
    
    % do the word stimuli
    [studyStims_word.onePres,wordStimStruct.wordStims] = space_divvyStims(...
      wordStimStruct.wordStims,studyStims_word.onePres,...
      cfg.stim.practice.nPairs_study_targ_onePres * length(phaseCfg.categoryNames),...
      cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{true,true,false,-1,1,[],[]});
  end
  
  % study buffers - start
  
  if cfg.stim.practice.nPairs_study_buff_start > 0
    % put all the image stimuli together, across categories
    for cn = 1:length(cfg.stim.practice.categoryNames)
      if ismember(cfg.stim.practice.categoryNames{cn},phaseCfg.categoryNames)
        [studyStims_img.buff_start,imgStimStruct(cn).catStims] = space_divvyStims(...
          imgStimStruct(cn).catStims,studyStims_img.buff_start,...
          cfg.stim.practice.nPairs_study_buff_start,...
          cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
      end
    end
    
    % do the word stimuli
    [studyStims_word.buff_start,wordStimStruct.wordStims] = space_divvyStims(...
      wordStimStruct.wordStims,studyStims_word.buff_start,...
      cfg.stim.practice.nPairs_study_buff_start * length(phaseCfg.categoryNames),...
      cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
  end
  
  % study buffers - end
  
  if cfg.stim.practice.nPairs_study_buff_end > 0
    % put all the image stimuli together, across categories
    for cn = 1:length(cfg.stim.practice.categoryNames)
      if ismember(cfg.stim.practice.categoryNames{cn},phaseCfg.categoryNames)
        [studyStims_img.buff_end,imgStimStruct(cn).catStims] = space_divvyStims(...
          imgStimStruct(cn).catStims,studyStims_img.buff_end,...
          cfg.stim.practice.nPairs_study_buff_end,...
          cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
      end
    end
    
    % do the word stimuli
    [studyStims_word.buff_end,wordStimStruct.wordStims] = space_divvyStims(...
      wordStimStruct.wordStims,studyStims_word.buff_end,...
      cfg.stim.practice.nPairs_study_buff_end * length(phaseCfg.categoryNames),...
      cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
  end
  
  distributeAtLags = cfg.stim.practice.lags;
else
  % for the real experiment
  
  % spaced
  
  % put all the image stimuli together, across categories
  for cn = 1:length(cfg.stim.categoryNames)
    if ismember(cfg.stim.categoryNames{cn},phaseCfg.categoryNames)
      [studyStims_img.p1,imgStimStruct(cn).catStims] = space_divvyStims(...
        imgStimStruct(cn).catStims,studyStims_img.p1,...
        cfg.stim.nPairs_study_targ_spaced,...
        cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,true,[],1,[],[]});
    end
  end
  
  % do the word stimuli
  [studyStims_word.p1,wordStimStruct.wordStims] = space_divvyStims(...
    wordStimStruct.wordStims,studyStims_word.p1,...
    cfg.stim.nPairs_study_targ_spaced * length(phaseCfg.categoryNames),...
    cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,true,[],1,[],[]});
  
  % massed
  
  % put all the image stimuli together, across categories
  for cn = 1:length(cfg.stim.categoryNames)
    if ismember(cfg.stim.categoryNames{cn},phaseCfg.categoryNames)
      [studyStims_img.p1,imgStimStruct(cn).catStims] = space_divvyStims(...
        imgStimStruct(cn).catStims,studyStims_img.p1,...
        cfg.stim.nPairs_study_targ_massed,...
        cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,false,0,1,[],[]});
    end
  end
  
  % do the word stimuli
  [studyStims_word.p1,wordStimStruct.wordStims] = space_divvyStims(...
    wordStimStruct.wordStims,studyStims_word.p1,...
    cfg.stim.nPairs_study_targ_massed * length(phaseCfg.categoryNames),...
    cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,false,0,1,[],[]});
  
  % single presentation
  
%     if cfg.stim.nPairs_study_targ_onePres > 0
%       % put all the image stimuli together, across categories
%       for cn = 1:length(cfg.stim.categoryNames)
%         if ismember(cfg.stim.categoryNames{cn},phaseCfg.categoryNames)
%           [studyStims_img.p1,imgStimStruct(cn).catStims] = space_divvyStims(...
%             imgStimStruct(cn).catStims,studyStims_img.p1,...
%             cfg.stim.nPairs_study_targ_onePres,...
%             cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,false,-1,1,[],[]});
%         end
%       end
%   
%       % do the word stimuli
%       [studyStims_word.p1,wordStimStruct.wordStims] = space_divvyStims(...
%         wordStimStruct.wordStims,studyStims_word.p1,...
%         cfg.stim.nPairs_study_targ_onePres * length(phaseCfg.categoryNames),...
%         cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,false,-1,1,[],[]});
%     end
  
  if cfg.stim.nPairs_study_targ_onePres > 0
    % put all the image stimuli together, across categories
    for cn = 1:length(cfg.stim.categoryNames)
      if ismember(cfg.stim.categoryNames{cn},phaseCfg.categoryNames)
        [studyStims_img.onePres,imgStimStruct(cn).catStims] = space_divvyStims(...
          imgStimStruct(cn).catStims,studyStims_img.onePres,...
          cfg.stim.nPairs_study_targ_onePres,...
          cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,false,-1,1,[],[]});
      end
    end
    
    % do the word stimuli
    [studyStims_word.onePres,wordStimStruct.wordStims] = space_divvyStims(...
      wordStimStruct.wordStims,studyStims_word.onePres,...
      cfg.stim.nPairs_study_targ_onePres * length(phaseCfg.categoryNames),...
      cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,true,false,-1,1,[],[]});
  end
  
  % study buffers - start
  
  if cfg.stim.nPairs_study_buff_start > 0
    % put all the image stimuli together, across categories
    for cn = 1:length(cfg.stim.categoryNames)
      if ismember(cfg.stim.categoryNames{cn},phaseCfg.categoryNames)
        [studyStims_img.buff_start,imgStimStruct(cn).catStims] = space_divvyStims(...
          imgStimStruct(cn).catStims,studyStims_img.buff_start,...
          cfg.stim.nPairs_study_buff_start,...
          cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
      end
    end
    
    % do the word stimuli
    [studyStims_word.buff_start,wordStimStruct.wordStims] = space_divvyStims(...
      wordStimStruct.wordStims,studyStims_word.buff_start,...
      cfg.stim.nPairs_study_buff_start * length(phaseCfg.categoryNames),...
      cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
  end
  
  % study buffers - end
  
  if cfg.stim.nPairs_study_buff_end > 0
    % put all the image stimuli together, across categories
    for cn = 1:length(cfg.stim.categoryNames)
      if ismember(cfg.stim.categoryNames{cn},phaseCfg.categoryNames)
        [studyStims_img.buff_end,imgStimStruct(cn).catStims] = space_divvyStims(...
          imgStimStruct(cn).catStims,studyStims_img.buff_end,...
          cfg.stim.nPairs_study_buff_end,...
          cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
      end
    end
    
    % do the word stimuli
    [studyStims_word.buff_end,wordStimStruct.wordStims] = space_divvyStims(...
      wordStimStruct.wordStims,studyStims_word.buff_end,...
      cfg.stim.nPairs_study_buff_end * length(phaseCfg.categoryNames),...
      cfg.stim.rmStims_init,cfg.stim.shuffleFirst_init,{'practice','targ','spaced','lag','presNum','pairNum','pairOrd'},{false,false,false,-1,1,[],[]});
  end
  
  distributeAtLags = cfg.stim.lags;
end

lagCounter = 1;
for i = 1:length(studyStims_img.p1)
  if isempty(studyStims_img.p1(i).lag)
    studyStims_img.p1(i).lag = distributeAtLags(lagCounter);
    studyStims_word.p1(i).lag = distributeAtLags(lagCounter);
    
    if lagCounter == length(distributeAtLags)
      lagCounter = 1;
    else
      lagCounter = lagCounter + 1;
    end
  end
end

% % this applies to when onePres is included in p1
% % putting them in ascending order seems to work better
% [~,ascendInd] = sort([studyStims_img.p1.lag],2,'ascend');
% studyStims_img.p1 = studyStims_img.p1(ascendInd);

% Reshuffle images for the experiment. No more than X conecutive stimuli
% with the same lag
fprintf('Shuffling %s study (%d) task stimuli.\n',sesName,phaseCount);
[studyStims_img.p1,randind] = et_shuffleStims(...
  studyStims_img.p1,'lag',phaseCfg.studyMaxConsecLag);
%   studyStims_img.p1,'categoryStr',phaseCfg.studyMaxConsecCategory);
%   studyStims_img.p1,'categoryNum',phaseCfg.studyMaxConsecCategory);
% put the words in the same order
studyStims_word.p1 = studyStims_word.p1(randind);

pairNumCounter = 0;

% give them metadata: presentation number, pair numbers, and pair order
pn = 1;
presNum = sprintf('p%d',pn);
for i = 1:length(studyStims_img.(presNum))
  % this is already set
  % % set the presentation number because p1 and p2 will get combined
  % studyStims_img.(presNum)(i).presNum = pn;
  % studyStims_word.(presNum)(i).presNum = pn;
  
  % set a pair number to keep image and word stimuli linked
  pairNumCounter = pairNumCounter + 1;
  studyStims_img.(presNum)(i).pairNum = pairNumCounter;
  studyStims_word.(presNum)(i).pairNum = pairNumCounter;
  
  % set the pair order, which comes first and which comes second
  if strcmp(phaseCfg.study_order{pn}{1},'image') && strcmp(phaseCfg.study_order{pn}{2},'word')
    studyStims_img.(presNum)(i).pairOrd = 1;
    studyStims_word.(presNum)(i).pairOrd = 2;
  elseif strcmp(phaseCfg.study_order{pn}{1},'word') && strcmp(phaseCfg.study_order{pn}{2},'image')
    studyStims_img.(presNum)(i).pairOrd = 2;
    studyStims_word.(presNum)(i).pairOrd = 1;
  end
end

% set up the second presentation
studyStims_img.p2 = studyStims_img.p1([studyStims_img.p1.lag] ~= -1);
studyStims_word.p2 = studyStims_word.p1([studyStims_word.p1.lag] ~= -1);

% give them metadata: presentation number, pair numbers, and pair order
pn = 2;
presNum = sprintf('p%d',pn);
for i = 1:length(studyStims_img.(presNum))
  % set the presentation number because p1 and p2 will get combined
  studyStims_img.(presNum)(i).presNum = pn;
  studyStims_word.(presNum)(i).presNum = pn;
  
  % this is already set
  % % set a pair number to keep image and word stimuli linked
  % pairNumCounter = pairNumCounter + 1;
  % studyStims_img.(presNum)(i).pairNum = pairNumCounter;
  % studyStims_word.(presNum)(i).pairNum = pairNumCounter;
  
  % set the pair order, which comes first and which comes second
  if strcmp(phaseCfg.study_order{pn}{1},'image') && strcmp(phaseCfg.study_order{pn}{2},'word')
    studyStims_img.(presNum)(i).pairOrd = 1;
    studyStims_word.(presNum)(i).pairOrd = 2;
  elseif strcmp(phaseCfg.study_order{pn}{1},'word') && strcmp(phaseCfg.study_order{pn}{2},'image')
    studyStims_img.(presNum)(i).pairOrd = 2;
    studyStims_word.(presNum)(i).pairOrd = 1;
  end
  
end

% set up the single presentation items
if ~phaseCfg.isExp
  nPairs_study_targ_onePres = cfg.stim.practice.nPairs_study_targ_onePres;
else
  nPairs_study_targ_onePres = cfg.stim.nPairs_study_targ_onePres;
end
if nPairs_study_targ_onePres > 0
  for i = 1:length(studyStims_img.onePres)
    % set the presentation number
    studyStims_img.onePres(i).presNum = 1;
    studyStims_word.onePres(i).presNum = 1;
    
    % set a pair number to keep image and word stimuli linked
    pairNumCounter = pairNumCounter + 1;
    studyStims_img.onePres(i).pairNum = pairNumCounter;
    studyStims_word.onePres(i).pairNum = pairNumCounter;
    
    % set the pair order, which comes first and which comes second
    pn = 1;
    if strcmp(phaseCfg.study_order{pn}{1},'image') && strcmp(phaseCfg.study_order{pn}{2},'word')
      studyStims_img.onePres(i).pairOrd = 1;
      studyStims_word.onePres(i).pairOrd = 2;
    elseif strcmp(phaseCfg.study_order{pn}{1},'word') && strcmp(phaseCfg.study_order{pn}{2},'image')
      studyStims_img.onePres(i).pairOrd = 2;
      studyStims_word.onePres(i).pairOrd = 1;
    end
  end
end

% set up the study buffers - start
if ~phaseCfg.isExp
  nPairs_study_buff_start = cfg.stim.practice.nPairs_study_buff_start;
  nPairs_study_buff_end = cfg.stim.practice.nPairs_study_buff_end;
else
  nPairs_study_buff_start = cfg.stim.nPairs_study_buff_start;
  nPairs_study_buff_end = cfg.stim.nPairs_study_buff_end;
end
if nPairs_study_buff_start > 0
  for i = 1:length(studyStims_img.buff_start)
    % set the presentation number
    studyStims_img.buff_start(i).presNum = 1;
    studyStims_word.buff_start(i).presNum = 1;
    
    % set a pair number to keep image and word stimuli linked
    pairNumCounter = pairNumCounter + 1;
    studyStims_img.buff_start(i).pairNum = pairNumCounter;
    studyStims_word.buff_start(i).pairNum = pairNumCounter;
    
    % set the pair order, which comes first and which comes second
    pn = 1;
    if strcmp(phaseCfg.study_order{pn}{1},'image') && strcmp(phaseCfg.study_order{pn}{2},'word')
      studyStims_img.buff_start(i).pairOrd = 1;
      studyStims_word.buff_start(i).pairOrd = 2;
    elseif strcmp(phaseCfg.study_order{pn}{1},'word') && strcmp(phaseCfg.study_order{pn}{2},'image')
      studyStims_img.buff_start(i).pairOrd = 2;
      studyStims_word.buff_start(i).pairOrd = 1;
    end
  end
end
if nPairs_study_buff_end > 0
  for i = 1:length(studyStims_img.buff_end)
    % set the presentation number
    studyStims_img.buff_end(i).presNum = 1;
    studyStims_word.buff_end(i).presNum = 1;
    
    % set a pair number to keep image and word stimuli linked
    pairNumCounter = pairNumCounter + 1;
    studyStims_img.buff_end(i).pairNum = pairNumCounter;
    studyStims_word.buff_end(i).pairNum = pairNumCounter;
    
    % set the pair order, which comes first and which comes second
    pn = 1;
    if strcmp(phaseCfg.study_order{pn}{1},'image') && strcmp(phaseCfg.study_order{pn}{2},'word')
      studyStims_img.buff_end(i).pairOrd = 1;
      studyStims_word.buff_end(i).pairOrd = 2;
    elseif strcmp(phaseCfg.study_order{pn}{1},'word') && strcmp(phaseCfg.study_order{pn}{2},'image')
      studyStims_img.buff_end(i).pairOrd = 2;
      studyStims_word.buff_end(i).pairOrd = 1;
    end
  end
end

% Reshuffle single presentation for the experiment. No more than X
% conecutive stimuli with the same category
fprintf('Shuffling %s study (%d) task stimuli.\n',sesName,phaseCount);
[studyStims_img.onePres,randind] = et_shuffleStims(...
 studyStims_img.onePres,'categoryNum',phaseCfg.studyMaxConsecCategory);
% put the words in the same order
studyStims_word.onePres = studyStims_word.onePres(randind);

% set up the field names for the combined stimuli
fn_img = fieldnames(studyStims_img.p1);
fn_img_str = sprintf('''%s'',[]',fn_img{1});
fn_img_str = cat(2,fn_img_str,sprintf(repmat(',''%s'',[]',1,length(fn_img) - 1),fn_img{2:end}));
fn_word = fieldnames(studyStims_word.p1);
fn_word_str = sprintf('''%s'',[]',fn_word{1});
fn_word_str = cat(2,fn_word_str,sprintf(repmat(',''%s'',[]',1,length(fn_word) - 1),fn_word{2:end}));
studyStims_img.all = eval(sprintf('struct(%s)',fn_img_str));
studyStims_word.all = eval(sprintf('struct(%s)',fn_word_str));

% put p1 and p2 (and single presentations) together in study order
placedAllStimuli = false;
maxParamAttempts = 100;
paramAttemptCounter = 0;
while ~placedAllStimuli
  stimIndex = nan(1,length(studyStims_img.p1) + length(studyStims_img.p2) + length(studyStims_img.onePres));
  % counter size is a function of the length of the stimIndex
  maxPlacementAttempts = length(stimIndex) * 100;
  
  % count how many times we tried to distribute stimuli
  paramAttemptCounter = paramAttemptCounter + 1;
  [placedAllStimuli,studyStims_img,studyStims_word,stimIndex] = distributeStims(...
    placedAllStimuli,stimIndex,studyStims_img,studyStims_word,maxPlacementAttempts,nPairs_study_targ_onePres);
  
  %disp(stimIndex);
  if placedAllStimuli == false && paramAttemptCounter > maxParamAttempts
    error('Tried these stim count parameters %d times. They probably will not work. Adjust parameters, delete this subject data directory, and try again.',maxParamAttempts);
  end
end

% add in the study buffers
if nPairs_study_buff_start > 0
  [studyStims_img.buff_start,randind] = et_shuffleStims(studyStims_img.buff_start);
  studyStims_word.buff_start = studyStims_word.buff_start(randind);
  
  for i = 1:length(studyStims_img.buff_start)
    studyStims_img.all = cat(2,studyStims_img.buff_start(i),studyStims_img.all);
    studyStims_word.all = cat(2,studyStims_word.buff_start(i),studyStims_word.all);
  end
end
if nPairs_study_buff_end > 0
  [studyStims_img.buff_end,randind] = et_shuffleStims(studyStims_img.buff_end);
  studyStims_word.buff_end = studyStims_word.buff_end(randind);
  
  for i = 1:length(studyStims_img.buff_end)
    studyStims_img.all = cat(2,studyStims_img.all,studyStims_img.buff_end(i));
    studyStims_word.all = cat(2,studyStims_word.all,studyStims_word.buff_end(i));
  end
end

% save stimuli in the expParam struct
expParam.session.(sesName).(phaseName)(phaseCount).studyStims_img = studyStims_img.all;
expParam.session.(sesName).(phaseName)(phaseCount).studyStims_word = studyStims_word.all;

% save this for bookkeeping
expParam.session.(sesName).(phaseName)(phaseCount).stimIndex = stimIndex;

fprintf('Done.\n');

%% function to distribute stims

  function [placedAllStimuli,studyStims_img,studyStims_word,stimIndex] = distributeStims(placedAllStimuli,stimIndex,studyStims_img,studyStims_word,maxPlacementAttempts,nPairs_study_targ_onePres)
    
    for si = 1:length(studyStims_img.p1)
      
      placementCount = 0;
      tooManyAttempts = false;
      
      % get the first presentation of this stimulus
      p1stim_img = studyStims_img.p1(si);
      p1stim_word = studyStims_word.p1(si);
      
      % if this is not a single presentation item
      if p1stim_img.lag ~= -1
        % get the second presentation of this stimulus
        p2stim_img = studyStims_img.p2([studyStims_img.p2.pairNum] == p1stim_img.pairNum);
        p2stim_word = studyStims_word.p2([studyStims_word.p2.pairNum] == p1stim_word.pairNum);
      end
      
      placedStimulus = false;
      while ~placedStimulus
        remainingValid_p1 = find(isnan(stimIndex));
        
        % choose a random index that is valid for P1
        valid_p1 = false;
        valid_p2 = false;
        while ~valid_p1 || ~valid_p2
          rand_p1 = randperm(length(remainingValid_p1),1);
          stimLoc_p1 = remainingValid_p1(rand_p1);
          
          % find out if there's enough room to put in both p1 and p2
          if stimLoc_p1 <= length(stimIndex) - p1stim_img.lag - 1
            valid_p1 = true;
          else
            % otherwise go back and pick a new rand_p1
            continue
          end
          
          % if this is not a single presentation, find the location of p2
          if p1stim_img.lag ~= -1
            stimLoc_p2 = stimLoc_p1 + p1stim_img.lag + 1;
            
            % if there's a NaN there, we can put it there
            if isnan(stimIndex(stimLoc_p2))
              valid_p2 = true;
            else
              % otherwise we need a new p1
              placementCount = placementCount + 1;
              
              % but don't try too many times
              if placementCount >= maxPlacementAttempts
                fprintf('\n');
                warning('Made %d placement attempts. This stimIndex probably will not work. Trying again...',maxPlacementAttempts);
                %error('Made %d placement attempts. This stimIndex probably will not work. Delete this subject data directory and try again.',maxPlacementAttempts);
                
                tooManyAttempts = true;
                % break the inner while loop
                break
              else
                % otherwise go back and pick a new rand_p1
                continue
              end
            end
          else
            % this is a single presentation item
            valid_p2 = true;
          end
        end
        
        % break the outer while loop
        if tooManyAttempts
          break
        end
        
        % if we found valid indices for P1 and P2, add them to the list
        if valid_p1 && valid_p2
          stimIndex(stimLoc_p1) = p1stim_img.pairNum;
          studyStims_img.all(stimLoc_p1) = p1stim_img;
          studyStims_word.all(stimLoc_p1) = p1stim_word;
          if p1stim_img.lag ~= -1
            stimIndex(stimLoc_p2) = p2stim_img.pairNum;
            studyStims_img.all(stimLoc_p2) = p2stim_img;
            studyStims_word.all(stimLoc_p2) = p2stim_word;
          end
        end
        
        placedStimulus = true;
      end
      
      % break the for loop
      if tooManyAttempts
        break
      end
      
    end % si
    
    % get out of this function
    if tooManyAttempts
      return
    end
    
    if length(find(isnan(stimIndex))) == nPairs_study_targ_onePres * 2
      placedAllStimuli = true;
    end
    
    % add in the single presentations
    openSpots = find(isnan(stimIndex));
    for os = 1:length(openSpots)
      stimIndex(openSpots(os)) = studyStims_img.onePres(os).pairNum;
      studyStims_img.all(openSpots(os)) = studyStims_img.onePres(os);
      studyStims_word.all(openSpots(os)) = studyStims_word.onePres(os);
    end
    fprintf('Successfully placed all stimuli!\n');
    
  end % function

end % function
