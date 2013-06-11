function [cfg,expParam] = config_EBIRD(cfg,expParam)
% function [cfg,expParam] = config_EBIRD(cfg,expParam)
%
% Description:
%  Configuration function for creature expertise training experiment. This
%  file should be edited for your particular experiment. This function runs
%  et_processStims_EBUG to prepare the stimuli for experiment presentation.
%
% see also: et_saveStimList, et_processStims_EBUG, et_processStims_match,
% et_processStims_recog, et_processStims_viewname,
% et_processStims_nametrain, et_processStims_name

%% Experiment session information

% set up configuration structures to keep track of what day and phase we're
% on.

% do we want to record EEG using Net Station?
expParam.useNS = false;
% what host is netstation running on?
if expParam.useNS
  expParam.NSPort = 55513;
  
  % % D458
  expParam.NSHost = '128.138.223.251';
  
  % % D464
  % expParam.NSHost = '128.138.223.26'
  
  expParam.baselineRecordSecs = 10.0;
end

% sound defaults
playSound = true;
correctSound = 'high';
incorrectSound = 'low';
% matching task defaults
matchTextPrompt = true;

% Set the number of sessions
expParam.nSessions = 9;

% Pre-test, training day 1, training days 1-6, post-test, post-test delayed.
expParam.sesTypes = {'pretest','train1','train2','train3','train4','train5','train6','posttest','posttest_delay'};

% set up a field for each session type
expParam.session.pretest.phases = {'prac_match','match'};
expParam.session.train1.phases = {'prac_name','nametrain','name'};
expParam.session.train2.phases = {'name'};
expParam.session.train3.phases = {'name'};
expParam.session.train4.phases = {'name'};
expParam.session.train5.phases = {'name'};
expParam.session.train6.phases = {'name'};
expParam.session.posttest.phases = {'prac_match','match'};
expParam.session.posttest_delay.phases = {'prac_match','match'};

% % demo - debug
% expParam.nSessions = 2;
% expParam.sesTypes = {'pretest','train1'};
% % set up a field for each session type
% expParam.session.pretest.phases = {'prac_match'};
% expParam.session.train1.phases = {'prac_name','nametrain'};

%% do some error checking

possible_phases = {'match','name','recog','nametrain','viewname','prac_match','prac_name','prac_recog'};
if length(expParam.sesTypes) ~= expParam.nSessions
  error('There should be %d sessions defined, but expParam.sesTypes contains %d sessions.',expParam.nSessions,length(expParam.sesTypes));
end
for s = 1:length(expParam.sesTypes)
  if isfield(expParam.session,expParam.sesTypes{s}) && ~isempty(expParam.session.(expParam.sesTypes{s}))
    if isfield(expParam.session.(expParam.sesTypes{s}),'phases') && ~isempty(expParam.session.(expParam.sesTypes{s}).phases)
      for p = 1:length(expParam.session.(expParam.sesTypes{s}).phases)
        if ~ismember(expParam.session.(expParam.sesTypes{s}).phases{p},possible_phases)
          error('%s is not a valid phase in expParam.session.%s.phases',expParam.session.(expParam.sesTypes{s}).phases{p},expParam.sesTypes{s});
        end
      end
    elseif ~isfield(expParam.session.(expParam.sesTypes{s}),'phases') || isempty(expParam.session.(expParam.sesTypes{s}).phases)
      error('Session phases not defined for %s! (in expParam.session.%s.phases)',expParam.sesTypes{s},expParam.sesTypes{s});
    end
  elseif ~isfield(expParam.session,expParam.sesTypes{s}) || isempty(expParam.session.(expParam.sesTypes{s}))
    error('expParam.session does not contain a field for session type ''%s''!',expParam.sesTypes{s});
  end
end

%% If this is session 1, setup the experiment

if expParam.sessionNum == 1
  
  %% Subject parameters
  
  % for counterbalancing
  
  % odd or even subject number
  if mod(str2double(expParam.subject(end)),2) == 0
    expParam.isEven = true;
  else
    expParam.isEven = false;
  end
  
  % subject number ends in 1-5 or 6-0
  if str2double(expParam.subject(end)) >= 1 && str2double(expParam.subject(end)) <= 5
    expParam.is15 = true;
  else
    expParam.is15 = false;
  end
  
  % blink break (set to 0 if you don't want breaks)
  if expParam.useNS
    % timer in secs for when to take a blink break (only when useNS=true)
    cfg.stim.secUntilBlinkBreak = 45.000;
  else
    % timer in secs for when to take a blink break (only when useNS=false)
    cfg.stim.secUntilBlinkBreak = 90.000;
  end
  
  %% Stimulus parameters
  
  cfg.files.stimFileExt = '.bmp';
  
  % scale stimlus down (< 1) or up (> 1)
  cfg.stim.stimScale = 0.75;
  
  % image directory holds the stims and resources
  cfg.files.imgDir = fullfile(cfg.files.expDir,'images');
  
  % set the stimulus directory
  cfg.files.stimDir = fullfile(cfg.files.imgDir,'Birds');
  
  % set the image resources directory
  cfg.files.resDir = fullfile(cfg.files.imgDir,'resources');
  
  % set the instructions directory
  cfg.files.instructDir = fullfile(cfg.files.expDir,'text','instructions');
  
  % family names correspond to the directories in which stimuli reside
  cfg.stim.familyNames = {'Finch_', 'Finch_g', 'Finch_g_hi8', 'Finch_g_lo8', 'Finch_invertab', 'Warbler_', 'Warbler_g', 'Warbler_g_hi8', 'Warbler_g_lo8', 'Warbler_invertab'};
  %cfg.stim.familyNames = {'Finch_', 'Warbler_'};
  %cfg.stim.manipulations = {'', 'g', 'g_hi8', 'g_lo8', 'invertab'};
  
  % assumes that each family has the same number of species
  cfg.stim.nSpecies = 10;
  
  % save an individual stimulus list for each subject
  cfg.stim.stimListFile = fullfile(cfg.files.subSaveDir,'stimList.txt');
  
  % whether to use the same species order across families
  cfg.stim.yokeSpecies = true;
  if cfg.stim.yokeSpecies
    cfg.stim.yokeTogether = [1 1 1 1 1 2 2 2 2 2];
  end
  
  % Number of trained and untrained exemplars per species per family
  cfg.stim.nTrained = 6;
  cfg.stim.nUntrained = 6;
  
  % create the stimulus list if it doesn't exist
  shuffleSpecies = true;
  if ~exist(cfg.stim.stimListFile,'file')
    [cfg] = et_saveStimList(cfg,cfg.files.stimDir,cfg.stim,shuffleSpecies);
  else
    % % debug = warning instead of error
    % warning('Stimulus list should not exist at the beginning of Session %d: %s',expParam.sessionNum,cfg.stim.stimListFile);
    error('Stimulus list should not exist at the beginning of Session %d: %s',expParam.sessionNum,cfg.stim.stimListFile);
  end
  
  % practice images stored in separate directories
  expParam.runPractice = true;
  cfg.stim.useSeparatePracStims = true;
  
  if expParam.runPractice
    % practice exemplars per species per family for all phases except
    % recognition (recognition stim count is determined by nStudyTarg and
    % nStudyLure in each prac_recog phase defined below)
    cfg.stim.practice.nPractice = 2;
    
    if cfg.stim.useSeparatePracStims
      % debug, use creatures
      cfg.files.stimDir_prac = fullfile(cfg.files.imgDir,'Creatures');
      cfg.stim.practice.familyNames = {'a','s'};
      
      %cfg.files.stimDir_prac = fullfile(cfg.files.imgDir,'Birds');
      %cfg.stim.practice.familyNames = {'Finch_','Warbler_'};
      cfg.stim.practice.stimListFile = fullfile(cfg.files.subSaveDir,'stimList_prac.txt');
      cfg.stim.practice.nSpecies = 2;
      cfg.stim.practice.yokeSpecies = false;
      if cfg.stim.practice.yokeSpecies
        cfg.stim.practice.yokeTogether = [1 1];
      end
      
      shuffleSpecies = true;
      if ~exist(cfg.stim.practice.stimListFile,'file')
        [cfg] = et_saveStimList(cfg,cfg.files.stimDir_prac,cfg.stim.practice,shuffleSpecies);
      else
        % % debug = warning instead of error
        % warning('Stimulus list should not exist at the beginning of Session %d: %s',expParam.sessionNum,cfg.stim.practice.stimListFile);
        error('Stimulus list should not exist at the beginning of Session %d: %s',expParam.sessionNum,cfg.stim.practice.stimListFile);
      end
    else
      cfg.files.stimDir_prac = cfg.files.stimDir;
      cfg.stim.practice.familyNames = cfg.stim.familyNames;
      %cfg.stim.practice.nSpecies = cfg.stim.nSpecies;
      %cfg.stim.practice.yokeSpecies = cfg.stim.yokeSpecies;
      cfg.stim.practice.nSpecies = 2;
      cfg.stim.practice.yokeSpecies = false;
      if cfg.stim.practice.yokeSpecies
        cfg.stim.practice.yokeTogether = [1 1];
      end
      cfg.stim.practice.nExemplars = repmat(cfg.stim.practice.nPractice,length(cfg.stim.practice.familyNames),cfg.stim.practice.nSpecies);
    end
  end
  
  % basic/subordinate families (counterbalance based on even/odd subNum)
  if expParam.isEven
    cfg.stim.famNumBasic = [1 2 3 4 5];
    cfg.stim.famNumSubord = [6 7 8 9 10];
  else
    cfg.stim.famNumBasic = [6 7 8 9 10];
    cfg.stim.famNumSubord = [1 2 3 4 5];
  end
  % what to call the basic-level family in viewing and naming tasks
  cfg.text.basicFamStr = 'Other';
  
  % whether to remove the trained/untrained stims from the stimulus pool
  % after they are chosen
  cfg.stim.rmStims_init = true;
  % whether to shuffle the stimulus pool before choosing trained/untrained
  cfg.stim.shuffleFirst_init = true;
  
  % % subordinate family species numbers
  % cfg.stim.specNum(cfg.stim.famNumSubord,:)
  % % subordinate family species letters
  % cfg.stim.specStr(cfg.stim.famNumSubord,:)
  
  %% Define the response keys
  
  % the experimenter's secret key to continue the experiment
  cfg.keys.expContinue = 'g';
  
  % use spacebar for naming "other" family (basic-level naming)
  cfg.keys.otherKeyNames = {'space'};
  cfg.keys.s00 = KbName(cfg.keys.otherKeyNames{1});
  % for i = 1:length(cfg.keys.otherKeyNames)
  %   cfg.keys.(sprintf('s%.2d',i-1)) = KbName(cfg.keys.otherKeyNames{i});
  % end
  
  % keys for naming particular species (subordinate-level naming)
  
  % upper row
  cfg.keys.speciesKeyNames = {'q','w','e','r','v','n','u','i','o','p'};
  % % middle row
  % if ismac || isunix
  %   cfg.keys.speciesKeyNames = {'a','s','d','f','v','n','j','k','l',';:'};
  % elseif ispc
  %   cfg.keys.speciesKeyNames = {'a','s','d','f','v','n','j','k','l',';'};
  % end
  
  % set the species keys
  for i = 1:length(cfg.keys.speciesKeyNames)
    % sXX, where XX is an integer, buffered with a zero if i <= 9
    %cfg.keys.(sprintf('s%.2d',i)) = KbName(cfg.keys.speciesKeyNames{cfg.keys.randKeyOrder(i)});
    cfg.keys.(sprintf('s%.2d',i)) = KbName(cfg.keys.speciesKeyNames{i});
  end
  
  cfg.files.speciesNumKeyImg = fullfile(cfg.files.resDir,'speciesNum_black_upper.jpg');
  %cfg.files.speciesNumKeyImg = fullfile(cfg.files.resDir,'speciesNum_black_middle.jpg');
  %cfg.files.speciesNumKeyImg = fullfile(cfg.files.resDir,'speciesNum_white_upper.jpg');
  %cfg.files.speciesNumKeyImg = fullfile(cfg.files.resDir,'speciesNum_white_middle.jpg');
  % scale image down (< 1) or up (> 1)
  cfg.files.speciesNumKeyImgScale = 0.6;
  
  % subordinate matching keys (counterbalanced based on subNum 1-5, 6-0)
  
  % upper row
  cfg.keys.matchKeyNames = {'r','u'};
  % % middle row
  % cfg.keys.matchKeyNames = {'f','j'};
  if expParam.is15
    cfg.keys.matchSame = KbName(cfg.keys.matchKeyNames{1});
    cfg.keys.matchDiff = KbName(cfg.keys.matchKeyNames{2});
  else
    cfg.keys.matchSame = KbName(cfg.keys.matchKeyNames{2});
    cfg.keys.matchDiff = KbName(cfg.keys.matchKeyNames{1});
  end
  
  %   % recognition keys
  %
  %   % upper row
  %   cfg.keys.recogKeyNames = {{'q','w','e','r','u'},{'r','u','i','o','p'}};
  %   % % middle row
  %   % if ismac || isunix
  %   %   cfg.keys.recogKeyNames = {{'a','s','d','f','j'},{'f','j','k','l',';:'}};
  %   % elseif ispc
  %   %   cfg.keys.recogKeyNames = {{'a','s','d','f','j'},{'f','j','k','l',';'}};
  %   % end
  %
  %   % recognition keys (counterbalanced based on even/odd and 1-5, 6-10)
  %   if expParam.isEven && expParam.is15 || ~expParam.isEven && ~expParam.is15
  %     cfg.keys.recogKeySet = 1;
  %     cfg.keys.recogKeyNames = cfg.keys.recogKeyNames{cfg.keys.recogKeySet};
  %     cfg.keys.recogDefUn = KbName(cfg.keys.recogKeyNames{1});
  %     cfg.keys.recogMayUn = KbName(cfg.keys.recogKeyNames{2});
  %     cfg.keys.recogMayF = KbName(cfg.keys.recogKeyNames{3});
  %     cfg.keys.recogDefF = KbName(cfg.keys.recogKeyNames{4});
  %     cfg.keys.recogRecoll = KbName(cfg.keys.recogKeyNames{5});
  %   elseif expParam.isEven && ~expParam.is15 || ~expParam.isEven && expParam.is15
  %     cfg.keys.recogKeySet = 2;
  %     cfg.keys.recogKeyNames = cfg.keys.recogKeyNames{cfg.keys.recogKeySet};
  %     cfg.keys.recogDefUn = KbName(cfg.keys.recogKeyNames{5});
  %     cfg.keys.recogMayUn = KbName(cfg.keys.recogKeyNames{4});
  %     cfg.keys.recogMayF = KbName(cfg.keys.recogKeyNames{3});
  %     cfg.keys.recogDefF = KbName(cfg.keys.recogKeyNames{2});
  %     cfg.keys.recogRecoll = KbName(cfg.keys.recogKeyNames{1});
  %   end
  %
  %   cfg.files.recogTestRespKeyImg = fullfile(cfg.files.resDir,sprintf('recogTest_resp_black_upper_%d.jpg',cfg.keys.recogKeySet));
  %   %cfg.files.recogTestRespKeyImg = fullfile(cfg.files.resDir,sprintf('recogTest_resp_black_middle_%d.jpg',cfg.keys.recogKeySet));
  %   %cfg.files.recogTestRespKeyImg = fullfile(cfg.files.resDir,sprintf('recogTest_resp_white_upper_%d.jpg',cfg.keys.recogKeySet));
  %   %cfg.files.recogTestRespKeyImg = fullfile(cfg.files.resDir,sprintf('recogTest_resp_white_middle_%d.jpg',cfg.keys.recogKeySet));
  %   %cfg.files.recogTestRespKeyImg = fullfile(cfg.files.resDir,sprintf('recog_test_resp%d.jpg',cfg.keys.recogKeySet));
  %
  %   % scale image down (< 1) or up (> 1)
  %   cfg.files.recogTestRespKeyImgScale = 0.6;
  
  %% Screen, text, and symbol configuration for size and color
  
  % Choose a gray color value to be used as experiment backdrop
  %cfg.screen.gray = 181;
  cfg.screen.gray = 210;

  % font size for small messages printed to the screen
  cfg.text.basicTextSize = 32;
  cfg.text.basicTextColor = uint8((rgb('Black') * 255) + 0.5);
  % font size for instructsions
  cfg.text.instructTextSize = 28;
  cfg.text.instructColor = uint8((rgb('Black') * 255) + 0.5);
  
  % number of characters wide at which the instructions will be shown
  cfg.text.instructCharWidth = 70;
  % key to push to dismiss instruction screen
  cfg.keys.instructContKey = 'space';
  
  % fixation info
  cfg.text.fixSize = 32;
  cfg.text.fixSymbol = '+';
  cfg.text.respSymbol = '?';
  cfg.text.fixationColor = uint8((rgb('Black') * 255) + 0.5);
  
  if matchTextPrompt
    cfg.text.matchSame = 'Same';
    cfg.text.matchDiff = 'Diff   ';
  end
  
  % "respond faster" text
  cfg.text.respondFaster = 'No response recorded!\nRespond faster!';
  cfg.text.respondFasterColor = uint8((rgb('Red') * 255) + 0.5);
  cfg.text.respondFasterFeedbackTime = 1.5;
  % "too fast" text
  cfg.text.tooFast = 'Too fast!';
  cfg.text.tooFastColor = uint8((rgb('Red') * 255) + 0.5);
  
  %% Session/phase configuration
  
  %% pretest configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  sesName = 'pretest';
  
  if ismember(sesName,expParam.sesTypes)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matching - practice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'prac_match';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = false;
      
      % every stimulus is in both the same and the different condition.
      cfg.stim.(sesName).(phaseName).nSame = cfg.stim.practice.nPractice;
      cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.practice.nPractice;
      % rmStims_orig is false because all stimuli are used in both "same"
      % and "diff" conditions
      cfg.stim.(sesName).(phaseName).rmStims_orig = false;
      
      % % number per species per family (half because each stimulus is only in
      % % same or different condition)
      % cfg.stim.(sesName).(phaseName).nSame = cfg.stim.practice.nPractice / 2;
      % cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.practice.nPractice / 2;
      % % rmStims_orig is true because half of stimuli are in "same" cond and
      % % half are in "diff"
      % cfg.stim.(sesName).(phaseName).rmStims_orig = true;
      
      % rmStims_pair is true because pairs are removed after they're added
      cfg.stim.(sesName).(phaseName).rmStims_pair = true;
      cfg.stim.(sesName).(phaseName).shuffleFirst = true;
      
      % nTrials = (nSame + nDiff) * nSpecies * nFamiles (and multiply by 2
      % if rmStims_orig=false). nSpecies = (nSame + nDiff) in practice.
      
      % minimum number of trials needed between exact repeats of a given
      % stimulus as stim2
      cfg.stim.(sesName).(phaseName).stim2MinRepeatSpacing = 0;
      % whether to have "same" and "diff" text with the response prompt
      cfg.stim.(sesName).(phaseName).matchTextPrompt = matchTextPrompt;
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).match_isi = 0.5;
      cfg.stim.(sesName).(phaseName).match_stim1 = 0.8;
      cfg.stim.(sesName).(phaseName).match_stim2 = 0.8;
      % random intervals are generated on the fly
      cfg.stim.(sesName).(phaseName).match_preStim1 = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).match_preStim2 = [1.0 1.2];
      cfg.stim.(sesName).(phaseName).match_response = 5.0;
      
      % do we want to play feedback beeps?
      cfg.stim.(sesName).(phaseName).playSound = playSound;
      cfg.stim.(sesName).(phaseName).correctSound = correctSound;
      cfg.stim.(sesName).(phaseName).incorrectSound = incorrectSound;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.match.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_match1_practice_intro.txt',expParam.expName)),...
        {'sameKey','diffKey','contKey'},{KbName(cfg.keys.matchSame),KbName(cfg.keys.matchDiff),cfg.keys.instructContKey});
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matching
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'match';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = true;
      
      % % every stimulus is in both the same and the different condition.
      % cfg.stim.(sesName).(phaseName).nSame = cfg.stim.nTrained;
      % cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.nTrained;
      % % rmStims_orig is false because all stimuli are used in both "same"
      % % and "diff" conditions
      % cfg.stim.(sesName).(phaseName).rmStims_orig = false;
      
      % number per species per family (half because each stimulus is only in
      % same or different condition)
      cfg.stim.(sesName).(phaseName).nSame = cfg.stim.nTrained / 2;
      cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.nTrained / 2;
      % rmStims_orig is true because half of stimuli are in "same" cond and
      % half are in "diff"
      cfg.stim.(sesName).(phaseName).rmStims_orig = true;
      
      % rmStims_pair is true because pairs are removed after they're added
      cfg.stim.(sesName).(phaseName).rmStims_pair = true;
      cfg.stim.(sesName).(phaseName).shuffleFirst = true;
      
      % nTrials = (nSame + nDiff) * nSpecies * nFamiles (and multiply by 2
      % if rmStims_orig=false)
      
      % minimum number of trials needed between exact repeats of a given
      % stimulus as stim2
      cfg.stim.(sesName).(phaseName).stim2MinRepeatSpacing = 2;
      % whether to have "same" and "diff" text with the response prompt
      cfg.stim.(sesName).(phaseName).matchTextPrompt = matchTextPrompt;
      
      if expParam.useNS
        cfg.stim.(sesName).(phaseName).impedanceAfter_nTrials = 240;
      end
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).match_isi = 0.5;
      cfg.stim.(sesName).(phaseName).match_stim1 = 0.8;
      cfg.stim.(sesName).(phaseName).match_stim2 = 0.8;
      % random intervals are generated on the fly
      cfg.stim.(sesName).(phaseName).match_preStim1 = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).match_preStim2 = [1.0 1.2];
      cfg.stim.(sesName).(phaseName).match_response = 5.0;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.match.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_match2_exp_intro.txt',expParam.expName)),...
        {'sameKey','diffKey','contKey'},{KbName(cfg.keys.matchSame),KbName(cfg.keys.matchDiff),cfg.keys.instructContKey});
    end
  end
  
  %% Training Day 1 configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  sesName = 'train1';
  if ismember(sesName,expParam.sesTypes)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Naming
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'prac_name';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = false;
      
      % only use stimuli from particular families
      cfg.stim.(sesName).(phaseName).familyNames = cfg.stim.practice.familyNames;
      
      % maximum number of repeated exemplars from each family in naming
      cfg.stim.(sesName).(phaseName).nameMaxConsecFamily = 3;
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).name_isi = 0.5;
      cfg.stim.(sesName).(phaseName).name_preStim = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).name_stim = 1.0;
      cfg.stim.(sesName).(phaseName).name_response = 2.0;
      cfg.stim.(sesName).(phaseName).name_feedback = 1.0;
      
      % do we want to play feedback beeps?
      cfg.stim.(sesName).(phaseName).playSound = playSound;
      cfg.stim.(sesName).(phaseName).correctSound = correctSound;
      cfg.stim.(sesName).(phaseName).incorrectSound = incorrectSound;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.name.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_name1_practice_intro.txt',expParam.expName)),...
        {'nFamily','basicFamStr','contKey'},...
        {num2str(length(cfg.stim.familyNames)),cfg.text.basicFamStr,cfg.keys.instructContKey});
      cfg.stim.(sesName).(phaseName).instruct.name.image = cfg.files.speciesNumKeyImg;
      cfg.stim.(sesName).(phaseName).instruct.name.imageScale = cfg.files.speciesNumKeyImgScale;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Name training (introduce species in a rolling fashion)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'nametrain';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = true;
      
      % only use stimuli from particular families
      cfg.stim.(sesName).(phaseName).familyNames = {'Finch_', 'Warbler_'};
      
      % hard coded order of which species are presented in each block
      % (counterbalanced). Blocks are denoted by vectors.
      cfg.stim.(sesName).(phaseName).blockSpeciesOrder = {...
        [1, 2],...
        [1, 2, 3],...
        [1, 2, 3, 4],...
        [1, 2, 3, 4, 5],...
        [3, 4, 5, 6],...
        [4, 5, 6, 7],...
        [5, 6, 7, 8],...
        [6, 7, 8, 9],...
        [7, 8, 9, 10],...
        [8, 9, 10, 1],...
        [9, 10, 2, 3],...
        [10, 4, 5, 6],...
        [7, 8, 9, 10]};
      
      % 8 species, 6 trained, 6 untrained
      % cfg.stim.(sesName).(phaseName).blockSpeciesOrder = {...
      %  [1, 2],...
      %  [1, 2, 3],...
      %  [1, 2, 3, 4],...
      %  [1, 2, 3, 4, 5],...
      %  [3, 4, 5, 6],...
      %  [4, 5, 6, 7],...
      %  [5, 6, 7, 8],...
      %  [6, 7, 8, 1],...
      %  [7, 8, 1, 2],...
      %  [8, 2, 3, 4],...
      %  [3, 4, 5, 6],...
      %  [5, 6, 7, 8],...
      %  [7, 8, 1, 2]};
      
      % hard coded stimulus indices for naming training block presentations
      % (counterbalanced). Blocks are denoted by cells. The vectors within each
      % block represent the exemplar number(s) for each species, corresponding
      % to the species numbers listed in blockSpeciesOrder (defined above). The
      % contents of each vector corresponds to the exemplar numbers for that
      % species.
      
      % 10 species, 6 trained, 6 untrained
      cfg.stim.(sesName).(phaseName).nameIndices = {...
        {[1, 2, 3], [1, 2, 3]},...
        {[4, 5, 6], [4, 5, 6], [1, 2, 3]},...
        {[2, 3, 4], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
        {[5, 1, 6], [2, 3, 4], [4, 5, 6], [3, 4, 5]},...
        {[5, 1, 6], [2, 3, 4], [3, 5, 6], [3, 5, 6]},...
        {[5, 1, 6], [2, 5, 6], [3, 5, 6], [3, 5, 6]},...
        {[3, 5, 6], [3, 5, 6], [3, 5, 6], [3, 5, 6]}};
      
      % % 10 species, 4 trained, 4 untrained
      % cfg.stim.(sesName).(phaseName).nameIndices = {...
      %   {[1, 2], [1, 2]},...
      %   {[3, 4], [3, 4], [1, 2]},...
      %   {[2, 3], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]},...
      %   {[1, 4], [2, 3], [3, 4], [1, 2]}};
      
      % % 8 species, 6 trained, 6 untrained
      % cfg.stim.(sesName).(phaseName).nameIndices = {...
      %   {[1, 2, 3], [1, 2, 3]},...
      %   {[4, 5, 6], [4, 5, 6], [1, 2, 3]},...
      %   {[2, 3, 4], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [2, 3, 4], [4, 5, 6], [1, 2, 3]},...
      %   {[5, 1, 6], [4, 5, 6], [1, 2, 3], [4, 5, 6]},...
      %   {[5, 1, 6], [4, 5, 6], [1, 2, 3], [3, 4, 5]},...
      %   {[4, 5, 6], [6, 1, 2], [1, 2, 3], [4, 5, 6]},...
      %   {[1, 2, 3], [3, 4, 5], [4, 5, 6], [1, 2, 3]}};
      
      % maximum number of repeated exemplars from each family in naming
      cfg.stim.(sesName).(phaseName).nameMaxConsecFamily = 3;
      
      if expParam.useNS
        cfg.stim.(sesName).(phaseName).impedanceAfter_nBlocks = 7;
      end
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).name_isi = 0.5;
      cfg.stim.(sesName).(phaseName).name_preStim = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).name_stim = 1.0;
      cfg.stim.(sesName).(phaseName).name_response = 2.0;
      cfg.stim.(sesName).(phaseName).name_feedback = 1.0;
      
      % do we want to play feedback beeps?
      cfg.stim.(sesName).(phaseName).playSound = playSound;
      cfg.stim.(sesName).(phaseName).correctSound = correctSound;
      cfg.stim.(sesName).(phaseName).incorrectSound = incorrectSound;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.name.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_nametrain1_exp_intro.txt',expParam.expName)),...
        {'nFamily','nSpeciesTotal','basicFamStr','contKey'},...
        {num2str(length(cfg.stim.familyNames)),num2str(cfg.stim.nSpecies),cfg.text.basicFamStr,...
        cfg.keys.instructContKey});
      cfg.stim.(sesName).(phaseName).instruct.name.image = cfg.files.speciesNumKeyImg;
      cfg.stim.(sesName).(phaseName).instruct.name.imageScale = cfg.files.speciesNumKeyImgScale;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Naming
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'name';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = true;
      
      % only use stimuli from particular families
      cfg.stim.(sesName).(phaseName).familyNames = {'Finch_', 'Warbler_'};
      
      % maximum number of repeated exemplars from each family in naming
      cfg.stim.(sesName).(phaseName).nameMaxConsecFamily = 3;
      
      if expParam.useNS
        cfg.stim.(sesName).(phaseName).impedanceAfter_nTrials = 120;
      end
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).name_isi = 0.5;
      cfg.stim.(sesName).(phaseName).name_preStim = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).name_stim = 1.0;
      cfg.stim.(sesName).(phaseName).name_response = 2.0;
      cfg.stim.(sesName).(phaseName).name_feedback = 1.0;
      
      % do we want to play feedback beeps?
      cfg.stim.(sesName).(phaseName).playSound = playSound;
      cfg.stim.(sesName).(phaseName).correctSound = correctSound;
      cfg.stim.(sesName).(phaseName).incorrectSound = incorrectSound;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.name.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_name2_exp_intro.txt',expParam.expName)),...
        {'nFamily','basicFamStr','contKey'},...
        {num2str(length(cfg.stim.familyNames)),cfg.text.basicFamStr,...
        cfg.keys.instructContKey});
      cfg.stim.(sesName).(phaseName).instruct.name.image = cfg.files.speciesNumKeyImg;
      cfg.stim.(sesName).(phaseName).instruct.name.imageScale = cfg.files.speciesNumKeyImgScale;
    end
  end
  
  %% Training Day 2-6 configuration (all these days are the same)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  sesNames = {'train2','train3','train4','train5','train6'};
  
  for s = 1:length(sesNames)
    sesName = sesNames{s};
    
    if ismember(sesName,expParam.sesTypes)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Naming
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      phaseName = 'name';
      
      if ismember(phaseName,expParam.session.(sesName).phases)
        cfg.stim.(sesName).(phaseName).isExp = true;
        
        % only use stimuli from particular families
        cfg.stim.(sesName).(phaseName).familyNames = {'Finch_', 'Warbler_'};
        
        % maximum number of repeated exemplars from each family in naming
        cfg.stim.(sesName).(phaseName).nameMaxConsecFamily = 3;
        
        if expParam.useNS
          cfg.stim.(sesName).(phaseName).impedanceAfter_nTrials = 120;
        end
        
        % durations, in seconds
        cfg.stim.(sesName).(phaseName).name_isi = 0.5;
        cfg.stim.(sesName).(phaseName).name_preStim = [0.5 0.7];
        cfg.stim.(sesName).(phaseName).name_stim = 1.0;
        cfg.stim.(sesName).(phaseName).name_response = 2.0;
        cfg.stim.(sesName).(phaseName).name_feedback = 1.0;
        
        % do we want to play feedback beeps?
        cfg.stim.(sesName).(phaseName).playSound = playSound;
        cfg.stim.(sesName).(phaseName).correctSound = correctSound;
        cfg.stim.(sesName).(phaseName).incorrectSound = incorrectSound;
        
        % instructions
        [cfg.stim.(sesName).(phaseName).instruct.name.text] = et_processTextInstruct(...
          fullfile(cfg.files.instructDir,sprintf('%s_name2_exp_intro.txt',expParam.expName)),...
          {'nFamily','basicFamStr','contKey'},...
          {num2str(length(cfg.stim.familyNames)),cfg.text.basicFamStr,cfg.keys.instructContKey});
        cfg.stim.(sesName).(phaseName).instruct.name.image = cfg.files.speciesNumKeyImg;
        cfg.stim.(sesName).(phaseName).instruct.name.imageScale = cfg.files.speciesNumKeyImgScale;
      end
    end
  end
  
  %% Posttest configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  sesName = 'posttest';
  
  if ismember(sesName,expParam.sesTypes)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matching - practice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'prac_match';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      % do we want to use the stimuli from a previous phase? Set to an empty
      % cell if not.
      cfg.stim.(sesName).(phaseName).usePrevPhase = {'pretest','prac_match',1};
      cfg.stim.(sesName).(phaseName).reshuffleStims = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matching
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'match';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = true;
      
      % % every stimulus is in both the same and the different condition.
      % cfg.stim.(sesName).(phaseName).nSame = cfg.stim.nTrained;
      % cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.nTrained;
      % % rmStims_orig is false because all stimuli are used in both "same"
      % % and "diff" conditions
      % cfg.stim.(sesName).(phaseName).rmStims_orig = false;
      
      % number per species per family (half because each stimulus is only in
      % same or different condition)
      cfg.stim.(sesName).(phaseName).nSame = cfg.stim.nTrained / 2;
      cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.nTrained / 2;
      % rmStims_orig is true because half of stimuli are in "same" cond and
      % half are in "diff"
      cfg.stim.(sesName).(phaseName).rmStims_orig = true;
      
      % rmStims_pair is true because pairs are removed after they're added
      cfg.stim.(sesName).(phaseName).rmStims_pair = true;
      cfg.stim.(sesName).(phaseName).shuffleFirst = true;
      
      % nTrials = (nSame + nDiff) * nSpecies * nFamiles (and multiply by 2
      % if rmStims_orig=false)
      
      % minimum number of trials needed between exact repeats of a given
      % stimulus as stim2
      cfg.stim.(sesName).(phaseName).stim2MinRepeatSpacing = 2;
      % whether to have "same" and "diff" text with the response prompt
      cfg.stim.(sesName).(phaseName).matchTextPrompt = matchTextPrompt;
      
      if expParam.useNS
        cfg.stim.(sesName).(phaseName).impedanceAfter_nTrials = 240;
      end
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).match_isi = 0.5;
      cfg.stim.(sesName).(phaseName).match_stim1 = 0.8;
      cfg.stim.(sesName).(phaseName).match_stim2 = 0.8;
      % random intervals are generated on the fly
      cfg.stim.(sesName).(phaseName).match_preStim1 = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).match_preStim2 = [1.0 1.2];
      cfg.stim.(sesName).(phaseName).match_response = 5.0;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.match.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_match2_exp_intro.txt',expParam.expName)),...
        {'sameKey','diffKey','contKey'},{KbName(cfg.keys.matchSame),KbName(cfg.keys.matchDiff),cfg.keys.instructContKey});
    end
  end
  
  %% Posttest Delayed configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  sesName = 'posttest_delay';
  
  if ismember(sesName,expParam.sesTypes)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matching - practice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'prac_match';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      % do we want to use the stimuli from a previous phase? Set to an empty
      % cell if not.
      cfg.stim.(sesName).(phaseName).usePrevPhase = {'pretest','prac_match',1};
      cfg.stim.(sesName).(phaseName).reshuffleStims = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matching
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseName = 'match';
    
    if ismember(phaseName,expParam.session.(sesName).phases)
      cfg.stim.(sesName).(phaseName).isExp = true;
      
      % % every stimulus is in both the same and the different condition.
      % cfg.stim.(sesName).(phaseName).nSame = cfg.stim.nTrained;
      % cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.nTrained;
      % % rmStims_orig is false because all stimuli are used in both "same"
      % % and "diff" conditions
      % cfg.stim.(sesName).(phaseName).rmStims_orig = false;
      
      % number per species per family (half because each stimulus is only in
      % same or different condition)
      cfg.stim.(sesName).(phaseName).nSame = cfg.stim.nTrained / 2;
      cfg.stim.(sesName).(phaseName).nDiff = cfg.stim.nTrained / 2;
      % rmStims_orig is true because half of stimuli are in "same" cond and
      % half are in "diff"
      cfg.stim.(sesName).(phaseName).rmStims_orig = true;
      
      % rmStims_pair is true because pairs are removed after they're added
      cfg.stim.(sesName).(phaseName).rmStims_pair = true;
      cfg.stim.(sesName).(phaseName).shuffleFirst = true;
      
      % nTrials = (nSame + nDiff) * nSpecies * nFamiles (and multiply by 2
      % if rmStims_orig=false)
      
      % minimum number of trials needed between exact repeats of a given
      % stimulus as stim2
      cfg.stim.(sesName).(phaseName).stim2MinRepeatSpacing = 2;
      % whether to have "same" and "diff" text with the response prompt
      cfg.stim.(sesName).(phaseName).matchTextPrompt = matchTextPrompt;
      
      if expParam.useNS
        cfg.stim.(sesName).(phaseName).impedanceAfter_nTrials = 240;
      end
      
      % durations, in seconds
      cfg.stim.(sesName).(phaseName).match_isi = 0.5;
      cfg.stim.(sesName).(phaseName).match_stim1 = 0.8;
      cfg.stim.(sesName).(phaseName).match_stim2 = 0.8;
      % random intervals are generated on the fly
      cfg.stim.(sesName).(phaseName).match_preStim1 = [0.5 0.7];
      cfg.stim.(sesName).(phaseName).match_preStim2 = [1.0 1.2];
      cfg.stim.(sesName).(phaseName).match_response = 5.0;
      
      % instructions
      [cfg.stim.(sesName).(phaseName).instruct.match.text] = et_processTextInstruct(...
        fullfile(cfg.files.instructDir,sprintf('%s_match2_exp_intro.txt',expParam.expName)),...
        {'sameKey','diffKey','contKey'},{KbName(cfg.keys.matchSame),KbName(cfg.keys.matchDiff),cfg.keys.instructContKey});
    end
  end
  
  %% process the stimuli for the entire experiment
  
  [cfg,expParam] = et_processStims_EBUG(cfg,expParam);
  
  %% save the parameters
  
  fprintf('Saving experiment parameters: %s...',cfg.files.expParamFile);
  save(cfg.files.expParamFile,'cfg','expParam');
  fprintf('Done.\n');
  
  %% print out the experiment length
  
  % % maximum duration
  % et_calcExpDuration(cfg,expParam,'max');
  % medium duration
  et_calcExpDuration(cfg,expParam,'med');
  % % minimum duration
  % et_calcExpDuration(cfg,expParam,'min');
  
end
