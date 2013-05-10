function [shuffledStims] = et_shuffleStims(stims,valueField,maxConsec)
% function [shuffledStims] = et_shuffleStims(stims,valueField,maxConsec)
%
% Description:
%  Shuffle stimuli until there are no more than X consecutive stimuli of a
%  given type in a row.
%
% Input:
%  stims:      Struct. Stimuli to shuffle. Assumes that the field
%              stims.(valueField) consists of integers.
%  valueField: String. Name of the field on which the order is contingent.
%  maxConsec:  Integer. Maximum number of consecutive stimuli from the same
%              family.
%
% Output:
%  shuffledStims: Stimuli in shuffled order.
%
% NB: Makes 1,000,000 shuffle attempts before erroring because it counldn't
%     find a solution.
%

not_good = true;
maxShuffle = 1000000;
shuffleCount = 1;
fprintf('Shuffle count: %s',repmat(' ',1,length(num2str(maxShuffle))));
while not_good
  % shuffle the stimuli
  randind = randperm(length(stims));
  % debug
  %randind = 1:length(stims);
  %fprintf('%s, NB: Debug code. Not actually randomizing!\n',mfilename);
  % shuffle the exemplars
  stims = stims(randind);
  fprintf(1,[repmat('\b',1,length(num2str(shuffleCount))),'%d'],shuffleCount);
  
  stimValues = [stims.(valueField)];
  possibleValues = unique(stimValues);
  % initialize to count how many of each value we find
  consecCount = zeros(1,length(possibleValues));
  
  % increment the value for the first stimulus
  consecCount(stimValues(1) == possibleValues) = 1;
  
  for i = 2:length(stimValues)
    if stimValues(i) == stimValues(i-1)
      % if we found a repeat, add 1 to the count
      consecCount(stimValues(i) == possibleValues) = consecCount(stimValues(i) == possibleValues) + 1;
      if consecCount(stimValues(i) == possibleValues) > maxConsec
        % if we hit the maximum number, break out
        break
      end
    else
      % if it's not a repeat, reset the count
      consecCount = zeros(1,length(possibleValues));
      consecCount(stimValues(i) == possibleValues) = 1;
    end
  end
  if any(consecCount > maxConsec)
    shuffleCount = shuffleCount + 1;
  else
    not_good = false;
    shuffledStims = stims;
    fprintf('\nSuccessfully shuffled the stimuli contingent on the %s field.\n',valueField);
  end
  
  if shuffleCount == maxShuffle && not_good
    error('\nPerformed %d shuffle attempts. That is too many.',maxShuffle);
  end
end % while

end
