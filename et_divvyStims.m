function [origStims,chosenStims] = et_divvyStims(origStims,chosenStims,nStims,rmStims,newField,newValue)
% [origStims,selectedStims] = et_divvyStims(origStims,chosenStims,nStims,rmStims,newField,newValue)
%
% Description:
%  Shuffle a stimulus set (origStims) and slice out a subset (nStims) of
%  each available species into a new struct (chosenStims). If desired, add
%  new fields and values to the chosen stimuli (newField and newValue).
%
% Input:
%  origStims:   stimulus structure that you want to select from.
%  chosenStims: Empty array or existing struct to add the chosen. If it's
%               an existing struct, must have the same fields as what
%               you're expecting to return (i.e., newField/newValue).
%  nStims:      integer denoting the number of stimuli for this condition.
%  rmStims:     true or false, whether to remove stimuli. (default = true)
%  newField:    in case you want to add a new field to all these stimuli
%               (e.g., targ or lure). Optional (default = {}).
%  newValue:    the value for the new field. Optional (default = {}).
%
% Output:
%  origStims:   original stimulus structure with the chosen stimuli removed
%               if rmStims = true.
%  chosenStims: Struct containing the chosen stimuli from each available
%               species. This is where the new fields and values get added.
%

if ~exist('rmStims','var') || isempty(rmStims)
  rmStims = true;
end

if ~exist('newField','var') || isempty(newField)
  newField = {};
end

if ~exist('newValue','var') || isempty(newValue)
  newValue = {};
end

if ~isempty(newField)
  if length(newField) ~= length(newValue)
    error('newField and newValue are not the same length');
  end
end

% add the new field to all stims so we can concatenate
if ~isempty(newField)
  for f = 1:length(newField)
    origStims(1).(newField{f}) = [];
  end
end

% only go through the species in the available stimuli
theseSpecies = unique([origStims.speciesNum]);

% loop through every species
for s = 1:length(theseSpecies)
  % which indices does this species occupy?
  sInd = find([origStims.speciesNum] == theseSpecies(s));
  
  % shuffle the stimulus index
  %randsel = randperm(length(sInd));
  % debug
  randsel = 1:length(sInd);
  fprintf('%s, NB: Debug code. Not actually randomizing!\n',mfilename);
  % get the indices of the stimuli that we want
  chosenInd = sInd(randsel(1:nStims));
  
  if ~isempty(newField)
    % add new fields and values to these stimuli
    for f = 1:length(newField)
      for e = 1:length(chosenInd)
        origStims(chosenInd(e)).(newField{f}) = newValue{f};
      end
    end
  end
  
  % add them to the list
  chosenStims = cat(1,chosenStims,origStims(chosenInd));
  
  if rmStims
    origStims(chosenInd) = [];
  end
end

if ~isempty(newField)
  % remove the field from the stims struct
  for f = 1:length(newField)
    origStims = rmfield(origStims,newField{f});
  end
end

end
