function [logFile] = et_recognition(w,cfg,expParam,logFile,sesName,phaseName,phaseCount)
% function [logFile] = et_recognition(w,cfg,expParam,logFile,sesName,phaseName,phaseCount)
%
% Description:
%  This function runs the recognition study and test tasks.
%
%  Study targets are stored in expParam.session.(sesName).(phaseName).targStims
%  and intermixed test targets and lures are stored in
%  expParam.session.(sesName).(phaseName).allStims as structs. Both study
%  targets and target+lure test stimuli must already be sorted in
%  presentation order.
%
%
% Inputs:
%
%
% Outputs:
%
%
% NB:
%  Once agian, study targets and test targets+lures must already be sorted
%  in presentation order!
%
% NB:
%  Test response time is measured from when response key image appears on
%  screen.
%

% % keys
% cfg.keys.recogKeyNames
% cfg.keys.recogDefUn
% cfg.keys.recogMayUn
% cfg.keys.recogMayF
% cfg.keys.recogDefF
% cfg.keys.recogRecoll

% % durations, in seconds
% cfg.stim.(sesName).(phaseName).recog_study_isi = 0.8;
% cfg.stim.(sesName).(phaseName).recog_study_preTarg = 0.2;
% cfg.stim.(sesName).(phaseName).recog_study_targ = 2.0;
% cfg.stim.(sesName).(phaseName).recog_test_isi = 0.8;
% cfg.stim.(sesName).(phaseName).recog_test_preStim = 0.2;
% cfg.stim.(sesName).(phaseName).recog_test_stim = 1.5;
% cfg.stim.(sesName).(phaseName).recog_response = 10.0;

% TODO: make instruction files. read in during config?

fprintf('Running %s %s (%d)...\n',sesName,phaseName,phaseCount);

%% general preparation for recognition study and test

phaseCfg = cfg.stim.(sesName).(phaseName)(phaseCount);
targStims = expParam.session.(sesName).(phaseName)(phaseCount).targStims;
allStims = expParam.session.(sesName).(phaseName)(phaseCount).allStims;

if phaseCfg.isExp
  stimDir = cfg.files.stimDir;
else
  stimDir = cfg.files.stimDir_prac;
end

% read the proper response key image
respKeyImg = imread(cfg.files.recogTestRespKeyImg);
respKeyImgHeight = size(respKeyImg,1) * cfg.files.recogTestRespKeyImgScale;
respKeyImgWidth = size(respKeyImg,2) * cfg.files.recogTestRespKeyImgScale;
respKeyImg = Screen('MakeTexture',w,respKeyImg);

if ~isfield(phaseCfg,'playSound') || isempty(phaseCfg.playSound)
  phaseCfg.playSound = false;
end
% initialize beep player if needed
if phaseCfg.playSound
  Beeper(1,0);
end

%% start NS recording, if desired

% put a message on the screen as experiment phase begins
message = 'Starting recognition phase...';
if expParam.useNS
  % start recording
  [NSStopStatus, NSStopError] = NetStation('StartRecording');
  % synchronize
  [NSSyncStatus, NSSyncError] = NetStation('Synchronize');
  message = 'Starting data acquisition for recognition phase...';
end
Screen('TextSize', w, cfg.text.basicTextSize);
% draw message to screen
DrawFormattedText(w, message, 'center', 'center', cfg.text.basicTextColor, cfg.text.instructCharWidth);
% put it on
Screen('Flip', w);
% Wait before starting trial
WaitSecs(5.000);
% Clear screen to background color (our 'gray' as set at the
% beginning):
Screen('Flip', w);

%% Run recognition study and test

for b = 1:phaseCfg.nBlocks
  
  %% do an impedance check before the block begins
  if expParam.useNS && phaseCfg.isExp && b > 1 && b < phaseCfg.nBlocks && mod((b - 1),phaseCfg.impedanceAfter_nBlocks) == 0
    Screen('TextSize', w, cfg.text.basicTextSize);
    pauseMsg = sprintf('The experimenter will now check the EEG cap.');
    % just draw straight into the main window since we don't need speed here
    DrawFormattedText(w, pauseMsg, 'center', 'center');
    Screen('Flip', w);
    
    WaitSecs(5.000);
    % stop recording
    [NSStopStatus, NSStopError] = NetStation('StopRecording');
    
    % wait until g key is held for ~1 seconds
    KbCheckHold(1000, {cfg.keys.expContinue}, -1);
    
    % start recording
    [NSStopStatus, NSStopError] = NetStation('StartRecording');
    
    message = 'Starting data acquisition...';
    DrawFormattedText(w, message, 'center', 'center', cfg.text.basicTextColor, cfg.text.instructCharWidth);
    Screen('Flip', w);
    WaitSecs(5.000);
  end
  
  %% prepare the recognition study task
  
  % load up the stimuli for this block
  blockStimTex = nan(1,length(targStims{b}));
  for i = 1:length(targStims{b})
    % this image
    stimImgFile = fullfile(stimDir,targStims{b}(i).familyStr,targStims{b}(i).fileName);
    if exist(stimImgFile,'file')
      stimImg = imread(stimImgFile);
      blockStimTex(i) = Screen('MakeTexture',w,stimImg);
      % TODO: optimized?
      %blockStims(i) = Screen('MakeTexture',w,stimImg,[],1);
    else
      error('Study stimulus %s does not exist!',stimImgFile);
    end
  end
  
  % get the width and height of the final stimulus image
  stimImgHeight = size(stimImg,1) * cfg.stim.stimScale;
  stimImgWidth = size(stimImg,2) * cfg.stim.stimScale;
  % set the stimulus image rectangle
  stimImgRect = [0 0 stimImgWidth stimImgHeight];
  stimImgRect = CenterRect(stimImgRect, cfg.screen.wRect);
  
  % text location for "too fast" text
  if ~phaseCfg.isExp
    [~,tooFastY] = RectCenter(cfg.screen.wRect);
    tooFastY = tooFastY + (stimImgHeight / 2);
  end
  
  %% show the study instructions
  
  for i = 1:length(phaseCfg.instruct.recogIntro)
    WaitSecs(1.000);
    et_showTextInstruct(w,phaseCfg.instruct.recogIntro(i),cfg.keys.instructContKey,...
      cfg.text.instructColor,cfg.text.instructTextSize,cfg.text.instructCharWidth,...
      {'blockNum'},{num2str(b)});
  end
  
  for i = 1:length(phaseCfg.instruct.recogStudy)
    WaitSecs(1.000);
    et_showTextInstruct(w,phaseCfg.instruct.recogStudy(i),cfg.keys.instructContKey,...
      cfg.text.instructColor,cfg.text.instructTextSize,cfg.text.instructCharWidth,...
      {'blockNum'},{num2str(b)});
  end
  
  % Wait a second before starting trial
  WaitSecs(1.000);
  
  %% run the recognition study task
  
  % set the fixation size
  Screen('TextSize', w, cfg.text.fixSize);
  
  % start the blink break timer
  if phaseCfg.isExp && cfg.stim.secUntilBlinkBreak > 0
    blinkTimerStart = GetSecs;
  end

  for i = 1:length(blockStimTex)
    % Do a blink break if specified time has passed
    if phaseCfg.isExp && cfg.stim.secUntilBlinkBreak > 0 && (GetSecs - blinkTimerStart) >= cfg.stim.secUntilBlinkBreak && i > 3 && i < (length(blockStimTex) - 3)
      Screen('TextSize', w, cfg.text.basicTextSize);
      pauseMsg = sprintf('Blink now.\n\nReady for trial %d of %d.\nPress any key to continue.', i, length(blockStimTex));
      % just draw straight into the main window since we don't need speed here
      DrawFormattedText(w, pauseMsg, 'center', 'center');
      Screen('Flip', w);
      
      % wait for kb release in case subject is holding down keys
      KbReleaseWait;
      KbWait(-1); % listen for keypress on either keyboard
      
      Screen('TextSize', w, cfg.text.fixSize);
      DrawFormattedText(w,cfg.text.fixSymbol,'center','center',cfg.text.fixationColor);
      Screen('Flip',w);
      WaitSecs(0.5);
      % reset the timer
      blinkTimerStart = GetSecs;
    end
    
    % Is this a subordinate (1) or basic (0) family/species? If subordinate,
    % get the species number.
    if any(targStims{b}(i).familyNum == cfg.stim.famNumSubord)
      subord = 1;
      sNum = targStims{b}(i).speciesNum;
    else
      subord = 0;
      sNum = 0;
    end
    
    % resynchronize netstation before the start of drawing
    if expParam.useNS
      [NSSyncStatus, NSSyncError] = NetStation('Synchronize');
    end
    
    % draw fixation
    Screen('TextSize', w, cfg.text.fixSize);
    DrawFormattedText(w,cfg.text.fixSymbol,'center','center',cfg.text.fixationColor);
    [preStimFixOn] = Screen('Flip',w);
    
    % ISI between trials
    WaitSecs(phaseCfg.recog_study_isi);
    
    % fixation on screen before starting trial
    WaitSecs(phaseCfg.recog_study_preTarg);
    
    % draw the stimulus
    Screen('DrawTexture', w, blockStimTex(i), [], stimImgRect);
    
    % Show stimulus on screen at next possible display refresh cycle,
    % and record stimulus onset time in 'startrt':
    [imgStudyOn, stimOnset] = Screen('Flip', w);
    
    % debug
    fprintf('Trial %d of %d: %s.\n',i,length(blockStimTex),allStims{b}(i).fileName);
    
    % while loop to show stimulus until subjects response or until
    % "duration" seconds elapsed.
    while (GetSecs - stimOnset) <= phaseCfg.recog_study_targ
      % Wait <1 ms before checking the keyboard again to prevent
      % overload of the machine at elevated Priority():
      WaitSecs(0.0001);
    end
    
    % Clear screen to background color after fixed 'duration'
    Screen('Flip', w);
    
    % close this stimulus before next trial
    Screen('Close', blockStimTex(i));
    
    % Write study stimulus presentation to file:
    fprintf(logFile,'%f %s %s %s %s %i %i %s %s %i %i %i %i\n',...
      imgStudyOn,...
      expParam.subject,...
      sesName,...
      phaseName,...
      'RECOGSTUDY_TARG',...
      b,...
      i,...
      targStims{b}(i).familyStr,...
      targStims{b}(i).speciesStr,...
      targStims{b}(i).exemplarName,...
      subord,...
      sNum,...
      targStims{b}(i).targ);
    
    
    % Write netstation logs
    if expParam.useNS
      % Write trial info to NetStation
      % mark every event with the following key code/value pairs
      % 'subn', subject number
      % 'sess', session type
      % 'phase', session phase name
      % 'bloc', block number (training day 1 only)
      % 'trln', trial number
      % 'stmn', stimulus name (family, species, exemplar)
      % 'spcn', species number (corresponds to keyboard)
      % 'sord', whether this is a subordinate (1) or basic (0) level family
      % 'targ', whether this is a target (always 1 for study)
      
      % write out the stimulus name
      stimName = sprintf('%s%s%d',...
        targStims{b}(i).familyStr,...
        targStims{b}(i).speciesStr,...
        targStims{b}(i).exemplarName);
      
      % pretrial fixation
      [NSEventStatus, NSEventError] = NetStation('Event', 'FIXT', preStimFixOn, .001,...
        'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
        'trln', i, 'stmn', stimName, 'spcn', sNum, 'sord', subord,...
        'targ', targStims{b}(i).targ);
      
      % img presentation
      [NSEventStatus, NSEventError] = NetStation('Event', 'TIMG', imgOn, .001,...
        'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
        'trln', i, 'stmn', stimName, 'spcn', sNum, 'sord', subord,...
        'targ', targStims{b}(i).targ);
    end % useNS
    
  end % for stimuli
  
  %% Prepare the recognition test task
  
  % load up the stimuli for this block
  blockStimTex = nan(1,length(allStims{b}));
  for i = 1:length(allStims{b})
    % this image
    stimImgFile = fullfile(stimDir,allStims{b}(i).familyStr,allStims{b}(i).fileName);
    if exist(stimImgFile,'file')
      stimImg = imread(stimImgFile);
      blockStimTex(i) = Screen('MakeTexture',w,stimImg);
      % TODO: optimized?
      %blockStims(i) = Screen('MakeTexture',w,stimImg,[],1);
    else
      error('Test stimulus %s does not exist!',stimImgFile);
    end
  end
  
  % get the width and height of the final stimulus image
  stimImgHeight = size(stimImg,1) * cfg.stim.stimScale;
  stimImgWidth = size(stimImg,2) * cfg.stim.stimScale;
  % set the stimulus image rectangle
  stimImgRect = [0 0 stimImgWidth stimImgHeight];
  stimImgRect = CenterRect(stimImgRect,cfg.screen.wRect);
  
  % set the response key image rectangle
  respKeyImgRect = CenterRect([0 0 respKeyImgWidth respKeyImgHeight], stimImgRect);
  respKeyImgRect = AdjoinRect(respKeyImgRect, stimImgRect, RectBottom);
  
  %% show the test instructions
  
  for i = 1:length(phaseCfg.instruct.recogTest)
    WaitSecs(1.000);
    et_showTextInstruct(w,phaseCfg.instruct.recogTest(i),cfg.keys.instructContKey,...
      cfg.text.instructColor,cfg.text.instructTextSize,cfg.text.instructCharWidth);
  end
  
  % Wait a second before starting trial
  WaitSecs(1.000);
  
  %% Run the recognition test task
  
  % set the fixation size
  Screen('TextSize', w, cfg.text.fixSize);
  
  % only check these keys
  RestrictKeysForKbCheck([cfg.keys.recogDefUn, cfg.keys.recogMayUn, cfg.keys.recogMayF, cfg.keys.recogDefF, cfg.keys.recogRecoll]);
  
  % start the blink break timer
  if phaseCfg.isExp && cfg.stim.secUntilBlinkBreak > 0
    blinkTimerStart = GetSecs;
  end

  for i = 1:length(blockStimTex)
    % Do a blink break if recording EEG and specified time has passed
    if phaseCfg.isExp && cfg.stim.secUntilBlinkBreak > 0 && (GetSecs - blinkTimerStart) >= cfg.stim.secUntilBlinkBreak && i > 3 && i < (length(blockStimTex) - 3)
      Screen('TextSize', w, cfg.text.basicTextSize);
      pauseMsg = sprintf('Blink now.\n\nReady for trial %d of %d.\nPress any key to continue.', i, length(blockStimTex));
      % just draw straight into the main window since we don't need speed here
      DrawFormattedText(w, pauseMsg, 'center', 'center');
      Screen('Flip', w);
      
      % wait for kb release in case subject is holding down keys
      KbReleaseWait;
      KbWait(-1); % listen for keypress on either keyboard
      
      Screen('TextSize', w, cfg.text.fixSize);
      DrawFormattedText(w,cfg.text.fixSymbol,'center','center',cfg.text.fixationColor);
      Screen('Flip',w);
      WaitSecs(0.5);
      % reset the timer
      blinkTimerStart = GetSecs;
    end
    
    % Is this a subordinate (1) or basic (0) family/species? If subordinate,
    % get the species number.
    if any(allStims{b}(i).familyNum == cfg.stim.famNumSubord)
      subord = 1;
      sNum = allStims{b}(i).speciesNum;
    else
      subord = 0;
      sNum = 0;
    end
    
    % resynchronize netstation before the start of drawing
    if expParam.useNS
      [NSSyncStatus, NSSyncError] = NetStation('Synchronize');
    end
    
    % draw fixation
    Screen('TextSize', w, cfg.text.fixSize);
    DrawFormattedText(w,cfg.text.fixSymbol,'center','center',cfg.text.fixationColor);
    [preStimFixOn] = Screen('Flip',w);
    
    % ISI between trials
    WaitSecs(phaseCfg.recog_test_isi);
    
    % fixation on screen before starting trial
    WaitSecs(phaseCfg.recog_test_preStim);
    
    % draw the stimulus
    Screen('DrawTexture', w, blockStimTex(i), [], stimImgRect);
    % and fixation on top of it
    Screen('TextSize', w, cfg.text.fixSize);
    DrawFormattedText(w,cfg.text.fixSymbol,'center','center',cfg.text.fixationColor);
    
    % Show stimulus on screen at next possible display refresh cycle,
    % and record stimulus onset time in 'stimOnset':
    [imgTestOn, stimOnset] = Screen('Flip', w);
    
    % debug
    fprintf('Trial %d of %d: %s, targ (1) or lure (0): %d.\n',i,length(blockStimTex),allStims{b}(i).fileName,allStims{b}(i).targ);
    
    % while loop to show stimulus until "duration" seconds elapsed.
    while (GetSecs - stimOnset) <= phaseCfg.recog_test_stim
      % check for too-fast response in practice only
      if ~phaseCfg.isExp
        [keyIsDown] = KbCheck;
        % if they press a key too early, tell them they responded too fast
        if keyIsDown
          Screen('DrawTexture', w, blockStimTex(i), [], stimImgRect);
          DrawFormattedText(w,cfg.text.tooFast,'center',tooFastY,cfg.text.tooFastColor);
          Screen('Flip', w);
        end
      end
      
      % Wait <1 ms before checking the keyboard again to prevent
      % overload of the machine at elevated Priority():
      WaitSecs(0.0001);
    end
    
    % draw the stimulus with the response key image
    Screen('DrawTexture', w, blockStimTex(i), [], stimImgRect);
    Screen('DrawTexture', w, respKeyImg, [], respKeyImgRect);
    % put them on the screen; measure RT from when response key img appears
    [respKeyImgOn, startRT] = Screen('Flip', w);
    
    % poll for a resp
    while 1
      if (GetSecs - startRT) > phaseCfg.recog_response
        break
      end
      
      [keyIsDown, endRT, keyCode] = KbCheck;
      % if they push more than one key, don't accept it
      if keyIsDown && sum(keyCode) == 1
        % wait for key to be released
        while KbCheck(-1)
          WaitSecs(0.0001);
        end
        % % debug
        % fprintf('"%s" typed at time %.3f seconds\n', KbName(keyCode), endRT - startRT);
        if (keyCode(cfg.keys.recogDefUn) == 1 && all(keyCode(~cfg.keys.recogDefUn) == 0)) ||...
            (keyCode(cfg.keys.recogMayUn) == 1 && all(keyCode(~cfg.keys.recogMayUn) == 0)) ||...
            (keyCode(cfg.keys.recogMayF) == 1 && all(keyCode(~cfg.keys.recogMayF) == 0)) ||...
            (keyCode(cfg.keys.recogDefF) == 1 && all(keyCode(~cfg.keys.recogDefF) == 0)) ||...
            (keyCode(cfg.keys.recogRecoll) == 1 && all(keyCode(~cfg.keys.recogRecoll) == 0))
          break
        end
      end
      % wait so we don't overload the system
      WaitSecs(0.0001);
    end
    
    if ~keyIsDown
      if phaseCfg.playSound
        Beeper(phaseCfg.incorrectSound);
      end
      
      % "need to respond faster"
      DrawFormattedText(w,cfg.text.respondFaster,'center','center',cfg.text.respondFasterColor);
      
      Screen('Flip', w);
      
      % need a new endRT
      endRT = GetSecs;
      
      % wait to let them view the feedback
      WaitSecs(cfg.text.respondFasterFeedbackTime);
    end
    
    % Clear screen to background color after response
    Screen('Flip', w);
    
    % Close this stimulus before next trial
    Screen('Close', blockStimTex(i));
    
    % compute response time
    rt = round(1000 * (endRT - startRT));
    
    % compute accuracy
    if keyIsDown
      if allStims{b}(i).targ && (keyCode(cfg.keys.recogMayF) == 1 || keyCode(cfg.keys.recogDefF) == 1 || keyCode(cfg.keys.recogRecoll) == 1)
        % target (hit)
        acc = 1;
      elseif ~allStims{b}(i).targ && (keyCode(cfg.keys.recogDefUn) == 1 || keyCode(cfg.keys.recogMayUn) == 1)
        % lure (correct rejection)
        acc = 1;
      else
        % miss or false alarm
        acc = 0;
      end
    else
      % did not push a key
      acc = 0;
    end
    
    % get the response
    if keyIsDown
      if keyCode(cfg.keys.recogRecoll) == 1
        resp = 'recollect';
      elseif keyCode(cfg.keys.recogDefF) == 1
        resp = 'definitelyFam';
      elseif keyCode(cfg.keys.recogMayF) == 1
        resp = 'maybeFam';
      elseif keyCode(cfg.keys.recogMayUn) == 1
        resp = 'maybeUnfam';
      elseif keyCode(cfg.keys.recogDefUn) == 1
        resp = 'definitelyUnfam';
      else
        % debug
        fprintf('Key other than a recognition response key was pressed. This should not happen.\n');
        resp = 'ERROR';
      end
    elseif ~keyIsDown
      resp = 'none';
    end
    
    % get key pressed by subject
    respKey = KbName(keyCode);
    if isempty(respKey)
      respKey = 'none';
    end
    
    % debug
    fprintf('Trial %d of %d: %s, targ (1) or lure (0): %d. response: %s (key: %s) (acc = %d)\n',i,length(blockStimTex),allStims{b}(i).fileName,allStims{b}(i).targ,resp,respKey,acc);
    
    % Write test stimulus presentation to file:
    fprintf(logFile,'%f %s %s %s %s %i %i %s %s %i %i %i %i\n',...
      imgTestOn,...
      expParam.subject,...
      sesName,...
      phaseName,...
      'RECOGTEST_STIM',...
      b,...
      i,...
      allStims{b}(i).familyStr,...
      allStims{b}(i).speciesStr,...
      allStims{b}(i).exemplarName,...
      subord,...
      sNum,...
      allStims{b}(i).targ);
    
    % Write test stimulus presentation to file:
    fprintf(logFile,'%f %s %s %s %s %i %i %s %s %i %i %i %i\n',...
      respKeyImgOn,...
      expParam.subject,...
      sesName,...
      phaseName,...
      'RECOGTEST_RESPKEYIMG',...
      b,...
      i,...
      allStims{b}(i).familyStr,...
      allStims{b}(i).speciesStr,...
      allStims{b}(i).exemplarName,...
      subord,...
      sNum,...
      allStims{b}(i).targ);
    
    % Write trial result to file:
    fprintf(logFile,'%f %s %s %s %s %i %i %s %i %i %i %i %i %s %s %i %i\n',...
      endRT,...
      expParam.subject,...
      sesName,...
      phaseName,...
      'RECOGTEST_RESP',...
      b,...
      i,...
      allStims{b}(i).familyStr,...
      allStims{b}(i).speciesStr,...
      allStims{b}(i).exemplarName,...
      allStims{b}(i).targ,...
      subord,...
      sNum,...
      resp,...
      respKey,...
      acc,...
      rt);
    
    % Write netstation logs
    if expParam.useNS
      % Write trial info to NetStation
      % mark every event with the following key code/value pairs
      % 'subn', subject number
      % 'sess', session type
      % 'phase', session phase name
      % 'bloc', block number (training day 1 only)
      % 'trln', trial number
      % 'stmn', stimulus name (family, species, exemplar)
      % 'spcn', species number (corresponds to keyboard)
      % 'sord', whether this is a subordinate (1) or basic (0) level family
      % 'targ', whether this is a target (1) or not (0)
      % 'resp', response string
      % 'resk', the name of the key pressed
      % 'corr', accuracy code (1=correct, 0=incorrect)
      % 'keyp', key pressed?(1=yes, 0=no)
      
      % write out the stimulus name
      stimName = sprintf('%s%s%d',...
        allStims{b}(i).familyStr,...
        allStims{b}(i).speciesStr,...
        allStims{b}(i).exemplarName);
      
      % pretrial fixation
      [NSEventStatus, NSEventError] = NetStation('Event', 'FIXT', preStimFixOn, .001,...
        'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
        'trln', i, 'stmn', stimName, 'spcn', sNum, 'sord', subord, 'targ', allStims{b}(i).targ,...
        'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
      
      % img presentation
      [NSEventStatus, NSEventError] = NetStation('Event', 'TIMG', imgOn, .001,...
        'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
        'trln', i, 'stmn', stimName, 'spcn', sNum, 'sord', subord, 'targ', allStims{b}(i).targ,...
        'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
      
      % response prompt
      [NSEventStatus, NSEventError] = NetStation('Event', 'PROM', respKeyImgOn, .001,...
        'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
        'trln', i, 'stmn', stimName, 'spcn', sNum, 'sord', subord, 'targ', allStims{b}(i).targ,...
        'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
      
      % did they make a response?
      if keyIsDown
        % button push
        [NSEventStatus, NSEventError] = NetStation('Event', 'RESP', endRT, .001,...
          'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
          'trln', i, 'stmn', stimName, 'spcn', sNum, 'sord', subord, 'targ', allStims{b}(i).targ,...
          'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
      end
    end % useNS
    
  end % for stimuli
  
  % reset the KbCheck
  RestrictKeysForKbCheck([]);
  
end % for nBlocks

%% cleanup

% Close the response key image
Screen('Close',respKeyImg);

% stop recording
if expParam.useNS
  WaitSecs(5.0);
  [NSSyncStatus, NSSyncError] = NetStation('StopRecording');
end

end % function
