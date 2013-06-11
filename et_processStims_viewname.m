function [cfg,expParam] = et_processStims_viewname(cfg,expParam,sesName,phaseName,phaseCount)
% function [cfg,expParam] = et_processStims_viewname(cfg,expParam,sesName,phaseName,phaseCount)

fprintf('Configuring %s %s (%d)...\n',sesName,phaseName,phaseCount);

phaseCfg = cfg.stim.(sesName).(phaseName)(phaseCount);

if ~isfield(phaseCfg,'familyNames')
  if ~phaseCfg.isExp
    phaseCfg.familyNames = cfg.stim.practice.familyNames;
  else
    phaseCfg.familyNames = cfg.stim.familyNames;
  end
end

% add the species in order from 1 to nSpecies; this is ok because, for each
% subject, each species number corresonds to a random species letter, as
% determined in et_saveStimList()
speciesOrder = nan(length(cfg.stim.familyNames),cfg.stim.nSpecies);
for f = 1:length(cfg.stim.familyNames)
  speciesOrder(f,:) = (1:cfg.stim.nSpecies);
end

% initialize viewing and naming cells, one for each block
expParam.session.(sesName).(phaseName)(phaseCount).viewStims = cell(1,length(phaseCfg.blockSpeciesOrder));
expParam.session.(sesName).(phaseName)(phaseCount).nameStims = cell(1,length(phaseCfg.blockSpeciesOrder));

for b = 1:length(phaseCfg.blockSpeciesOrder)
  for s = 1:length(phaseCfg.blockSpeciesOrder{b})
    for f = 1:length(cfg.stim.familyNames)
      % get the indices for this species
      sInd = find([expParam.session.(sprintf('f%dTrained',f)).speciesNum] == speciesOrder(f,phaseCfg.blockSpeciesOrder{b}(s)));
      % shuffle the stimulus index
      randind = randperm(length(sInd));
      
      % shuffle the exemplars
      thisSpecies = expParam.session.(sprintf('f%dTrained',f))(sInd(randind));
      
      % add them to the viewing list
      expParam.session.(sesName).(phaseName)(phaseCount).viewStims{b} = cat(1,...
        expParam.session.(sesName).(phaseName)(phaseCount).viewStims{b},...
        thisSpecies(phaseCfg.viewIndices{b}{s}));
    
      % add them to the naming list
      expParam.session.(sesName).(phaseName)(phaseCount).nameStims{b} = cat(1,...
        expParam.session.(sesName).(phaseName)(phaseCount).nameStims{b},...
        thisSpecies(phaseCfg.nameIndices{b}{s}));
    end % for each family
  end % for each species
  
  % if there are more than X consecutive exemplars from the same
  % family, reshuffle for the experiment. There's probably a better way
  % to do this but it works.
  
  % viewing
  fprintf('Shuffling %s viewing (%d) task stimuli.\n',sesName,phaseCount);
  [expParam.session.(sesName).(phaseName)(phaseCount).viewStims{b}] = et_shuffleStims(...
    expParam.session.(sesName).(phaseName)(phaseCount).viewStims{b},'familyNum',phaseCfg.viewMaxConsecFamily);
  % naming
  fprintf('Shuffling %s naming (%d) task stimuli.\n',sesName,phaseCount);
  [expParam.session.(sesName).(phaseName)(phaseCount).nameStims{b}] = et_shuffleStims(...
    expParam.session.(sesName).(phaseName)(phaseCount).nameStims{b},'familyNum',phaseCfg.nameMaxConsecFamily);
  
end % for each block

fprintf('Done.\n');

end % function
