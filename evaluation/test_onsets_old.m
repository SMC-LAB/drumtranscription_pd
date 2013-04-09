function evaluation_matrix = test_onsets_old(midiDir,audioDir, window_size)

true_positive_o = 0;
false_positive_o = 0;
false_negative_o = 0;

wavFiles = dir(strcat(audioDir,'*.wav'));
midiFiles = dir(strcat(midiDir,'*.MID'));
for k = 1:length(wavFiles)
    detection_matrix = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);  
    true_positive_o = true_positive_o + detection_matrix(1);
    false_positive_o = false_positive_o + detection_matrix(2);
    false_negative_o = false_negative_o + detection_matrix(3);
end

[F_o,precision_o,recall_o] = evaluate_measures(true_positive_o,false_positive_o,false_negative_o)

[true_positive_o,false_positive_o,false_negative_o]

evaluation_matrix = [F_o,precision_o,recall_o];

end

function detection_matrix = get_transcription(audiofile, midiDir, audioDir, window_size)

midiFile = strcat(strrep(audiofile, '.wav', ''),'.MID');

%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
%drums = nmat(nmat(:,3) == 10,:);
drums = nmat;
m_onset = drums(:,6);
%idx = [false;diff(m_onset)<2*(10^-2)]; 
%m_onset(idx) = [];
csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_midi.txt'),m_onset); 

%load transcription
onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onset.txt'), ' ');

%audiofile
%midiFile
%lo = [length(m_onset),length(onset)]
%m_onset'
%onset
%joinUnevenVectors(m_onset,onset')'

[true_positive_o,false_positive_o,false_negative_o] = evaluate_instrument(m_onset, onset', window_size);

detection_matrix =[true_positive_o,false_positive_o,false_negative_o];

end

function [true_positive,false_positive,false_negative] = evaluate_instrument(midi, onset, window_size)

true_positive = 0;
false_positive = 0;
false_negative = 0;

for i = 1:length(onset)    
    
    if (size(midi)~=0)
        
        %detect the closest element from the midi grountruth and remove it  
        indices = find(abs(midi-onset(i))<window_size,1);
        %[min_difference, array_position] = min(abs(midi - onset(i)));
        if indices
            midi(indices(1))=[];
            true_positive = true_positive + 1;  
        else
            false_positive = false_positive + 1;
        end
    
    end
    
end

false_negative = length(midi);
%true_negative = abs(length(onset) - true_positive);

end

function [F,precision,recall] = evaluate_measures(true_positive,false_positive,false_negative)
%accuracy = ( true_positive + true_negative ) / ( true_positive + true_negative + false_positive + false_negative );
precision = true_positive / ( true_positive + false_positive );
recall = true_positive / ( true_positive + false_negative );
F = 2 * precision * recall / ( precision + recall );
end

function out=joinUnevenVectors(varargin)
%#Horizontally catenate multiple column vectors by appending zeros 
%#at the ends of the shorter vectors
%#
%#SYNTAX: out = joinUnevenVectors(vec1, vec2, ... , vecN)

    maxLength=max(cellfun(@numel,varargin));
    out=cell2mat(cellfun(@(x)cat(1,x,zeros(maxLength-length(x),1)),varargin,'UniformOutput',false));
end

%%evaluation_matrix = test_transcription('/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Midi Files/','/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Loops/')
