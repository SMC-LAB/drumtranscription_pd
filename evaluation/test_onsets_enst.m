function evaluation_matrix = test_onsets_enst(midiDir,audioDir, window_size)

true_positive_o = 0;
false_positive_o = 0;
false_negative_o = 0;

wavFiles = dir(strcat(audioDir,'*.wav'));
midiFiles = dir(strcat(midiDir,'*.mid'));
delay_times = [];
for k = 1:length(wavFiles)
    detection_matrix = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);
    true_positive_o = true_positive_o + detection_matrix(1);
    false_positive_o = false_positive_o + detection_matrix(2);
    false_negative_o = false_negative_o + detection_matrix(3);
    delay_times = horzcat(delay_times,detection_matrix(4:end));
end
[F_o,precision_o,recall_o] = evaluate_measures(true_positive_o,false_positive_o,false_negative_o);

[true_positive_o,false_positive_o,false_negative_o]

evaluation_matrix = [F_o,precision_o,recall_o];

plothist = true;
if plothist    
figure
[N,h]=hist(delay_times,15);
bar(h,N);
xlabel('Delay time from the actual onset (ms)');
ylabel('Number of onsets(ms)');
end

end

function detection_matrix = get_transcription(audiofile, midiDir, audioDir, window_size)

midiFile = strcat(strrep(audiofile, '.wav', ''));
midiFile = strcat(strrep(midiFile, '.mid', ''), '.txt');

A=fopen(strcat(midiDir,midiFile));
drums=textscan(A,'%f %s', 'delimiter',' ');
fclose(A);
m_onset = drums{1};
idx = [false;diff(m_onset)<(2*(10^-2))]; 
m_onset(idx) = [];

onset = [];
%load transcription
onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onset.txt'), ' ')';
%onset = sort(onset);
if (numel(onset)>2) 
    while (onset(1)>onset(2)) onset = onset(2:end);end
end    
%csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_midisv.txt'),m_onset); 
%csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetsv.txt'),onset'); 

%audiofile
%midiFile
%lo = [length(m_onset),length(onset)]
%m_onset'
%onset
%joinUnevenVectors(m_onset,onset')'

[true_positive_o,false_positive_o,false_negative_o,delay] = evaluate_instrument(m_onset, onset, window_size);
if (length(delay)<1) audiofile
end 

detection_matrix =[true_positive_o,false_positive_o,false_negative_o,delay];

end

function [true_positive,false_positive,false_negative,delay] = evaluate_instrument(midi, onset, window_size)
delay = [];
true_positive = 0;
false_positive = 0;
false_negative = 0;
k=0;
for i = 1:length(onset)    
    
    if (size(midi)~=0)
        
        %detect the closest element from the midi grountruth and remove it  
        %indices = find(abs(midi - onset(i))<window_size,1);
        indices = find(midi < onset(i),1,'last');        
        
        if ((length(indices)>0) && ((onset(i) - midi(indices(1)))<window_size))
            %time difference/delay for the histogram
            k = k + 1;
            delay(k) = onset(i) - midi(indices(1));
            
            %remove the element because it was detected
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

%%evaluation_matrix = test_transcription('/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Midi Files/','/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Loops/')
