function [syncperbar,numEvents,syncall] = INESC_SyncopPattern(allpattern,usulweights,loopmode)
%this is a first version of syncopation calculation for patterns
% syncperbar: gives the (normalized) sum of positive syncopations for each measure
% numEvents: number of events per bar
% syncall: vector of allpattern length, with syncopation values for each
% onsets
% syncall_p: same as synall, but relating values to the pauses
%INPUTS:
% allpattern: input signal, starting at a downbeat.
% usulweights: definition of metric weights, highest weight is zero, then
% decreasing, for example for a 4/4 at 1/16 resolution:
% usulweights = [0 -4 -3 -4  -2 -4 -3 -4  -1 -4 -3 -4  -2 -4 -3 -3]';
% loopmode: if 1 then every measure is treated separately independent of
% its context!
% Andre Holzapfel
% 2012 at INESC TEC Porto
flag = 0;
syncall = zeros(size(allpattern));
syncall_p = zeros(size(allpattern));
numpatterns = floor(length(allpattern)/length(usulweights));
syncperbar = zeros(numpatterns,1);
numEvents = zeros(numpatterns,1);
if ~loopmode
    allpattern = [zeros(length(usulweights),1);allpattern;zeros(length(usulweights),1)];
end
for i = 1:numpatterns
    if loopmode
        pattern = allpattern([1:length(usulweights)]+(i-1)*length(usulweights));
        pattern = repmat(pattern,3,1);
    else
        pattern = allpattern([1:3*length(usulweights)]+(i-1)*length(usulweights));
    end
    onsetpos = find(pattern);
    weight_signal = repmat(usulweights,3,1);
    syncvals = zeros(size(onsetpos));
    pauselocs = zeros(size(onsetpos));
    for j = 1:length(onsetpos)-1
        current = onsetpos(j)+1;
        pauselocs(j) = current;
        if current < onsetpos(j+1)
            syncvals(j) = weight_signal(current)-weight_signal(onsetpos(j));
        end
        current = current +1;
        while current < onsetpos(j+1)
            tmp = weight_signal(current)-weight_signal(onsetpos(j));
            if tmp > syncvals(j)
                syncvals(j) = tmp;
                pauselocs(j) = current;
            end
            current = current + 1;
        end
    end
    syncvals(syncvals<0) = 0;%to get same range as Sioros
    tmp = zeros(length(usulweights),1);
    tmp_p = zeros(length(usulweights),1);
    if length(onsetpos)
        syncvals(end) = max(weight_signal(onsetpos(end):end)-weight_signal(onsetpos(end)));
        pauselocs(end) = length(weight_signal);
        first = length(usulweights)+1;
        last = 2*length(usulweights);
        pauselocs_b = (pauselocs-1);
        which = pauselocs_b >= first & pauselocs_b <= last;
        syncperbar(i) = sum([syncvals(which); 0]);
        numevents(i) = length(which);
        indices = onsetpos(which)-length(usulweights);%where are the onsets that start a syncopation?
        indices_p = pauselocs(which)-length(usulweights);%where are the strongest metrical weights in the following pause?
        syncvals = syncvals(which);
        if ~isempty(indices)
            if indices(1) <= 0
                previous = indices(1);
                indices = indices(2:end);
                thisval = syncvals(1);
                syncvals = syncvals(2:end);
                flag = 1;
            end
        end
        tmp(indices)=syncvals;
    else
       syncperbar(i) = 0;
       numEvents(i) = 0;
    end
    if flag
        syncall(length(usulweights)+previous+(i-2)*length(usulweights)) = thisval; 
        flag = 0;
    end
    syncall([1:length(usulweights)]+(i-1)*length(usulweights))=tmp;
end
syncperbar = syncperbar ./ (length(usulweights)-1);




