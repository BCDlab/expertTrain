function [logFile] = et_viewing(w,cfg,expParam,logFile,sesName,phaseName,phaseCount,b)
% function [logFile] = et_viewing(w,cfg,expParam,logFile,sesName,phaseName,phaseCount,b)
%
% Descrption:
%  This function runs the viewing task.
%
%  Exposure: picture paired with label, must push corresponding key during
%  viewing so subjects learn better. Green if correct, red if incorrect.
%
%  The stimuli for the viewing task must already be in presentation order.
%  They are stored in expParam.session.(sesName).(phaseName).viewStims as a
%  struct.
%
% Inputs:
%  b:        Block number. Optional. Do not enter anything if only 1 block.
%
% Outputs:
%
%
%
% NB:
%  Once agian, stimuli must already be sorted in presentation order!
%

% % durations, in seconds
% cfg.stim.(sesName).(phaseName).view_isi = 0.8;
% cfg.stim.(sesName).(phaseName).view_preStim = 0.2;
% cfg.stim.(sesName).(phaseName).view_stim = 4.0;

% % keys
% cfg.keys.sXX, where XX is an integer, buffered with a zero if i <= 9
% cfg.keys.s00 is "other" (basic) family

% TODO: make instruction files. read in during config?

fprintf('Running %s %s (%d)...\n',sesName,phaseName,phaseCount);

%% preparation

% Small hack. Because training day 1 uses blocks, those stims are stored in
% cells. However, all other training days do not use blocks, and do not use
% cells, but we need to put them in a cell to access the stimuli correctly.
if ~iscell(expParam.session.(sesName).(phaseName).viewStims)
  runInBlocks = false;
  expParam.session.(sesName).(phaseName).viewStims = {expParam.session.(sesName).(phaseName).viewStims};
  if ~exist('b','var') || isempty(b)
    b = 1;
  else
    error('input variable ''b'' should not be defined when only running 1 block.');
  end
else
  runInBlocks = true;
end

phaseCfg = cfg.stim.(sesName).(phaseName)(phaseCount);
viewStims = expParam.session.(sesName).(phaseName)(phaseCount).viewStims{b};

% set some text color
instructColor = WhiteIndex(w);
fixationColor = WhiteIndex(w);

initial_sNumColor = BlackIndex(w);
correct_sNumColor = uint8((rgb('Green') * 255) + 0.5);
incorrect_sNumColor = uint8((rgb('Red') * 255) + 0.5);

% for "respond faster" text
respFasterColor = uint8((rgb('Red') * 255) + 0.5);
[respondFasterX,respondFasterY] = RectCenter(cfg.screen.wRect);
respondFasterY = respondFasterY + (cfg.screen.wRect(RectBottom) * 0.04);
respondFasterFeedbackTime = 1.5;

if ~isfield(phaseCfg,'playSound') || isempty(phaseCfg.playSound)
  phaseCfg.playSound = false;
end
% initialize beep player if needed
if phaseCfg.playSound
  Beeper(1,0);
end

%% preload all stimuli for presentation

message = sprintf('Preparing images, please wait...');
Screen('TextSize', w, cfg.text.basicTextSize);
% put the instructions on the screen
DrawFormattedText(w, message, 'center', 'center', instructColor);
% Update the display to show the message:
Screen('Flip', w);

% initialize
stimTex = nan(1,length(viewStims));

for i = 1:length(viewStims)
  % load up this stim's texture
  stimImgFile = fullfile(cfg.files.stimDir,viewStims(i).familyStr,viewStims(i).fileName);
  if exist(stimImgFile,'file')
    stimImg = imread(stimImgFile);
    stimTex(i) = Screen('MakeTexture',w,stimImg);
    % TODO: optimized?
    %stimtex(i) = Screen('MakeTexture',w,stimImg,[],1);
  else
    error('Study stimulus %s does not exist!',stimImgFile);
  end
end

% get the width and height of the final stimulus image
stimImgHeight = size(stimImg,1) * cfg.stim.stimScale;
stimImgWidth = size(stimImg,2) * cfg.stim.stimScale;
stimImgRect = [0 0 stimImgWidth stimImgHeight];
stimImgRect = CenterRect(stimImgRect,cfg.screen.wRect);

% y-coordinate for stimulus number (below stim by 4% of the screen height)
sNumY = round(stimImgRect(RectBottom) + (cfg.screen.wRect(RectBottom) * 0.04));

if runInBlocks
  theseSpecies = unique(phaseCfg.blockSpeciesOrder{b});
else
  theseSpecies = unique([nameStims.speciesNum]);
end
nSpecies = length(theseSpecies);

theseSpeciesStr = sprintf('%d',theseSpecies(1));
if nSpecies > 1
  theseSpeciesStr = sprintf('%s%s',theseSpeciesStr,sprintf(repmat(', %d',1,length(theseSpecies) - 1),theseSpecies(2:end)));
  theseSpeciesStr = strrep(theseSpeciesStr,num2str(theseSpecies(end)),sprintf('and %d',theseSpecies(end)));
end
if nSpecies < 3
  theseSpeciesStr = strrep(theseSpeciesStr,',','');
end

%% start NS recording, if desired

% put a message on the screen as experiment phase begins
message = 'Starting viewing phase...';
if expParam.useNS
  % start recording
  [NSStopStatus, NSStopError] = NetStation('StartRecording');
  % synchronize
  [NSSyncStatus, NSSyncError] = NetStation('Synchronize');
  message = 'Starting data acquisition for viewing phase...';
end
Screen('TextSize', w, cfg.text.basicTextSize);
% draw message to screen
DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w),70);
% put it on
Screen('Flip', w);
% Wait before starting trial
WaitSecs(5.000);
% Clear screen to background color (our 'gray' as set at the
% beginning):
Screen('Flip', w);

%% show the instructions

for i = 1:length(phaseCfg.instruct.view)
  WaitSecs(1.000);
  et_showTextInstruct(w,phaseCfg.instruct.view(i),cfg.keys.instructContKey,...
    instructColor,cfg.text.instructTextSize,cfg.text.instructCharWidth,...
    {'blockNum','nSpecies','theseSpecies'},{num2str(b),num2str(nSpecies),theseSpeciesStr});
end

% Wait a second before starting trial
WaitSecs(1.000);

%% run the viewing task

% set the fixation size
Screen('TextSize', w, cfg.text.fixSize);

% only check these keys
RestrictKeysForKbCheck([cfg.keys.s01, cfg.keys.s02, cfg.keys.s03, cfg.keys.s04, cfg.keys.s05,...
  cfg.keys.s06, cfg.keys.s07, cfg.keys.s08, cfg.keys.s09, cfg.keys.s10, cfg.keys.s00]);

% start the blink break timer
if phaseCfg.isExp && cfg.stim.secUntilBlinkBreak > 0
  blinkTimerStart = GetSecs;
end

for i = 1:length(stimTex)
  % do an impedance check after a certain number of blocks or trials
  if runInBlocks
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
      DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w),70);
      Screen('Flip', w);
      WaitSecs(5.000);
      
      % reset the blink timer
      if cfg.stim.secUntilBlinkBreak > 0
        blinkTimerStart = GetSecs;
      end
    end
  else
    if expParam.useNS && phaseCfg.isExp && i > 1 && i < length(stimTex) && mod((i - 1),phaseCfg.impedanceAfter_nTrials)
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
      DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w),70);
      Screen('Flip', w);
      WaitSecs(5.000);
      
      % reset the blink timer
      if cfg.stim.secUntilBlinkBreak > 0
        blinkTimerStart = GetSecs;
      end
    end
  end
  
  % Do a blink break if recording EEG and specified time has passed
  if phaseCfg.isExp && cfg.stim.secUntilBlinkBreak > 0 && (GetSecs - blinkTimerStart) >= cfg.stim.secUntilBlinkBreak && i > 3 && i < (length(stimTex) - 3)
    Screen('TextSize', w, cfg.text.basicTextSize);
    pauseMsg = sprintf('Blink now.\n\nReady for trial %d of %d.\nPress any key to continue.', i, length(stimTex));
    % just draw straight into the main window since we don't need speed here
    DrawFormattedText(w, pauseMsg, 'center', 'center');
    Screen('Flip', w);
    
    % wait for kb release in case subject is holding down keys
    KbReleaseWait;
    KbWait(-1); % listen for keypress on either keyboard
    
    Screen('TextSize', w, cfg.text.fixSize);
    DrawFormattedText(w,cfg.text.fixSymbol,'center','center',fixationColor);
    Screen('Flip',w);
    WaitSecs(0.5);
    % reset the timer
    blinkTimerStart = GetSecs;
  end
  
  % resynchronize netstation before the start of drawing
  if expParam.useNS
    [NSSyncStatus, NSSyncError] = NetStation('Synchronize');
  end
  
  % Is this a subordinate (1) or basic (0) family/species? If subordinate,
  % get the species number.
  if any(viewStims(i).familyNum == cfg.stim.famNumSubord)
    subord = 1;
    sNum = viewStims(i).speciesNum;
  else
    subord = 0;
    sNum = 0;
  end
  
  % ISI between trials
  WaitSecs(phaseCfg.view_isi);
  
  % draw fixation
  Screen('TextSize', w, cfg.text.fixSize);
  DrawFormattedText(w,cfg.text.fixSymbol,'center','center',fixationColor);
  [preStimFixOn] = Screen('Flip',w);
  
  % fixation on screen before stim
  WaitSecs(phaseCfg.view_preStim);
  
  % draw the stimulus
  Screen('DrawTexture', w, stimTex(i), [], stimImgRect);
  % and species number in black
  Screen('TextSize', w, cfg.text.basicTextSize);
  if sNum > 0
    DrawFormattedText(w,num2str(sNum),'center',sNumY,initial_sNumColor);
  else
    DrawFormattedText(w,cfg.text.basicFamStr,'center',sNumY,initial_sNumColor);
  end
  
  % Show stimulus on screen at next possible display refresh cycle,
  % and record stimulus onset time in 'stimOnset':
  [imgOn, stimOnset] = Screen('Flip', w);
  
  % debug
  fprintf('Trial %d of %d: %s, species num: %d.\n',i,length(stimTex),viewStims(i).fileName,sNum);
  
  % while loop to show stimulus until subject response or until
  % "duration" seconds elapse.
  %
  % if we get a keyhit, change the color of the species number
  while 1
    if (GetSecs - stimOnset) > phaseCfg.view_stim
      break
    end
    [keyIsDown, endRT, keyCode] = KbCheck;
    % if they push more than one key, don't accept it
    if keyIsDown && sum(keyCode) == 1
      % wait for key to be released
      while KbCheck(-1)
        WaitSecs(.0001);
      end
      % % debug
      % fprintf('"%s" typed at time %.3f seconds\n', KbName(keyCode), endRT - stimOnset);
      if keyCode(cfg.keys.(sprintf('s%.2d',sNum))) == 1
        sNumColor = correct_sNumColor;
        if phaseCfg.playSound
          respSound = phaseCfg.correctSound;
        end
      elseif keyCode(cfg.keys.(sprintf('s%.2d',sNum))) == 0
        sNumColor = incorrect_sNumColor;
        if phaseCfg.playSound
          respSound = phaseCfg.incorrectSound;
        end
      end
      % draw the stimulus
      Screen('DrawTexture', w, stimTex(i), [], stimImgRect);
      % and species number in the appropriate color
      Screen('TextSize', w, cfg.text.basicTextSize);
      if sNum > 0
        DrawFormattedText(w,num2str(sNum),'center',sNumY,sNumColor);
      else
        DrawFormattedText(w,cfg.text.basicFamStr,'center',sNumY,sNumColor);
      end
      Screen('Flip', w);
      
      if phaseCfg.playSound
        Beeper(respSound);
      end
      
      break
    end
    % Wait <1 ms before checking the keyboard again to prevent
    % overload of the machine at elevated Priority():
    WaitSecs(0.0001);
  end
  
  % wait out any remaining time
  while (GetSecs - stimOnset) <= phaseCfg.view_stim
    % Wait <1 ms before checking the keyboard again to prevent
    % overload of the machine at elevated Priority():
    WaitSecs(0.0001);
  end
  
  % if they didn't make a response, give incorrect feedback
  if ~keyIsDown
    % draw the stimulus
    Screen('DrawTexture', w, stimTex(i), [], stimImgRect);
    % and species number in the appropriate color
    Screen('TextSize', w, cfg.text.basicTextSize);
    if sNum > 0
      DrawFormattedText(w,num2str(sNum),'center',sNumY,incorrect_sNumColor);
    else
      DrawFormattedText(w,cfg.text.basicFamStr,'center',sNumY,incorrect_sNumColor);
    end
    % "need to respond faster"
    DrawFormattedText(w,cfg.text.respondFaster,respondFasterX,respondFasterY,respFasterColor);
    Screen('Flip', w);
    if phaseCfg.playSound
      Beeper(phaseCfg.incorrectSound);
    end
    
    % need a new endRT
    endRT = GetSecs;
    
    % give an extra bit of time to see the number
    WaitSecs(respondFasterFeedbackTime);
  end
  
  % Clear screen to background color after response
  Screen('Flip', w);
  
  % Close this stimulus before next trial
  Screen('Close', stimTex(i));
  
  % compute response time
  rt = round(1000 * (endRT - stimOnset));
  
  % compute accuracy
  if keyIsDown && keyCode(cfg.keys.(sprintf('s%.2d',sNum))) == 1
    % pushed the right key
    acc = 1;
  elseif keyIsDown && keyCode(cfg.keys.(sprintf('s%.2d',sNum))) == 0
    % pushed the wrong key
    acc = 0;
  elseif ~keyIsDown
    % did not push a key
    acc = 0;
  end
  
  % get key pressed by subject
  respKey = KbName(keyCode);
  if isempty(respKey)
    respKey = 'none';
  end
  
  % figure out which species number was chosen
  fn = fieldnames(cfg.keys);
  if keyIsDown
    % if they made a response
    for s = 1:length(fn)
      % go through each key fieldname that is s##
      if length(fn{s}) == 3 && strcmp(fn{s}(1),'s')
        if find(keyCode) == cfg.keys.(fn{s})
          % if the key that got hit is the same as this fieldname, then
          % this is the species that we want
          resp = num2str(str2double(fn{s}(2:3)));
          break
        end
      end
    end
  else
    resp = 'none';
  end
  
  % debug
  fprintf('Trial %d of %d: %s, species num: %d. response: %s (key: %s) (acc = %d)\n',i,length(stimTex),viewStims(i).fileName,sNum,resp,respKey,acc);
  
  % Write stimulus presentation to file:
  fprintf(logFile,'%f %s %s %s %s %i %i %s %s %i %i %i\n',...
    imgOn,...
    expParam.subject,...
    sesName,...
    phaseName,...
    'VIEW_STIM',...
    b,...
    i,...
    viewStims(i).familyStr,...
    viewStims(i).speciesStr,...
    viewStims(i).exemplarName,...
    subord,...
    sNum);
  
  % Write response to file:
  fprintf(logFile,'%f %s %s %s %s %i %i %s %s %i %i %i %s %s %i %i\n',...
    endRT,...
    expParam.subject,...
    sesName,...
    phaseName,...
    'VIEW_RESP',...
    b,...
    i,...
    viewStims(i).familyStr,...
    viewStims(i).speciesStr,...
    viewStims(i).exemplarName,...
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
    % 'famn', family number
    % 'spcn', species number (corresponds to keyboard)
    % 'sord', whether this is a subordinate (1) or basic (0) level family
    % 'resp', response string
    % 'resk', the name of the key pressed
    % 'corr', accuracy code (1=correct, 0=incorrect)
    % 'keyp', key pressed?(1=yes, 0=no)
    
    % write out the stimulus name
    stimName = sprintf('%s%s%d',...
      viewStims(i).familyStr,...
      viewStims(i).speciesStr,...
      viewStims(i).exemplarName);
  
    fNum = viewStims(i).familyNum;
    
    % pretrial fixation
    [NSEventStatus, NSEventError] = NetStation('Event', 'FIXT', preStimFixOn, .001,...
      'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
      'trln', i, 'stmn', stimName, 'famn', fNum, 'spcn', sNum, 'sord', subord,...
      'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
    
    % img presentation
    [NSEventStatus, NSEventError] = NetStation('Event', 'TIMG', imgOn, .001,...
      'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
      'trln', i, 'stmn', stimName, 'famn', fNum, 'spcn', sNum, 'sord', subord,...
      'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
    
    % did they make a response?
    if keyIsDown
      % button push
      [NSEventStatus, NSEventError] = NetStation('Event', 'RESP', endRT, .001,...
      'subn', expParam.subject, 'sess', sesName, 'phas', phaseName, 'bloc', b,...
      'trln', i, 'stmn', stimName, 'famn', fNum, 'spcn', sNum, 'sord', subord,...
      'resp', resp, 'resk', respKey, 'corr', acc, 'keyp', keyIsDown);
    end
  end % useNS
  
end

%% cleanup

% stop recording
if expParam.useNS
  WaitSecs(5.0);
  [NSSyncStatus, NSSyncError] = NetStation('StopRecording');
end

% reset the KbCheck
RestrictKeysForKbCheck([]);

end % function
