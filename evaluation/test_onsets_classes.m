function evaluation_matrix = test_onsets_classes(midiDir,audioDir, window_size)

true_positive_o = 0;
false_positive_o = 0;
false_negative_o = 0;

true_positive_b = 0;
false_negative_b = 0;
true_positive_s = 0;
false_negative_s = 0;
true_positive_h = 0;
false_negative_h = 0;

ioi_bass = [];
ioi_snare = [];
ioi_hihat = [];

wavFiles = dir(strcat(audioDir,'*.wav'));

for k = 1:length(wavFiles)
    detection_matrix = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);
    true_positive_o = true_positive_o + detection_matrix(1);
    false_positive_o = false_positive_o + detection_matrix(2);
    false_negative_o = false_negative_o + detection_matrix(3);
    true_positive_b = true_positive_b + detection_matrix(4);
    false_negative_b = false_negative_b + detection_matrix(5);
    true_positive_s = true_positive_s + detection_matrix(6);
    false_negative_s = false_negative_s + detection_matrix(7);
    true_positive_h = true_positive_h + detection_matrix(8);
    false_negative_h = false_negative_h + detection_matrix(9);
    [t_bass ,t_snare, t_hihat] = get_ioi(wavFiles(k).name, midiDir, audioDir, window_size);
    ioi_bass = horzcat(ioi_bass,t_bass');
    ioi_snare = horzcat(ioi_snare,t_snare');
    ioi_hihat = horzcat(ioi_hihat,t_hihat');

end

[F_o,precision_o,recall_o] = evaluate_measures(true_positive_o,false_positive_o,false_negative_o);

[true_positive_o,false_positive_o,false_negative_o];

sensitivity_b = true_positive_b / (true_positive_b + false_negative_b);
sensitivity_s = true_positive_s / (true_positive_s + false_negative_s);
sensitivity_h = true_positive_h / (true_positive_h + false_negative_h);

evaluation_matrix = [F_o,precision_o,recall_o,sensitivity_b,sensitivity_s,sensitivity_h];

plothist = true;
if plothist    
figure
[N,h]=hist(ioi_bass,300);
bar(h,N);
xlim([0 0.1]);
figure
[N,h]=hist(ioi_snare,300);
bar(h,N);
xlim([0 0.1]);
figure
[N,h]=hist(ioi_hihat,600);
bar(h,N);
xlim([0 0.03]);
end

end

function [ioi_bass,ioi_snare,ioi_hihat] = get_ioi(audiofile, midiDir, audioDir, window_size)
midiFile = strcat(strrep(audiofile, '.wav', ''));
midiFile = strcat(strrep(midiFile, '.mid', ''), '.mid');

%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
%drums = nmat(nmat(:,3) == 10,:);
drums = nmat;

m_bass = drums(((drums(:,4) == 35) | (drums(:,4) == 36)), 6);
m_snare = drums((drums(:,4) == 38) | (drums(:,4) == 40), 6);
m_hihat = drums((drums(:,4) == 44) | (drums(:,4) == 46) ...
    | (drums(:,4) == 49) | (drums(:,4) == 51) ...
    | (drums(:,4) == 52) | (drums(:,4) == 55) ...
    | (drums(:,4) == 53) | (drums(:,4) == 42) ...
    | (drums(:,4) == 57) | (drums(:,4) == 59), 6);

ioi_bass = diff(m_bass);
ioi_snare = diff(m_snare);
ioi_hihat = diff(m_hihat);

end

function detection_matrix = get_transcription(audiofile, midiDir, audioDir, window_size)

midiFile = strcat(strrep(audiofile, '.wav', ''));
midiFile = strcat(strrep(midiFile, '.mid', ''), '.mid');

%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
%drums = nmat(nmat(:,3) == 10,:);
drums = nmat;
m_onset = drums(:,6);
idx = [false;diff(m_onset)<(2*(10^-2))]; 
m_onset(idx) = [];

m_bass = drums(((drums(:,4) == 35) | (drums(:,4) == 36)), 6);
m_snare = drums((drums(:,4) == 38) | (drums(:,4) == 40), 6);
m_hihat = drums((drums(:,4) == 44) | (drums(:,4) == 46) ...
    | (drums(:,4) == 49) | (drums(:,4) == 51) ...
    | (drums(:,4) == 52) | (drums(:,4) == 55) ...
    | (drums(:,4) == 53) | (drums(:,4) == 42) ...
    | (drums(:,4) == 57) | (drums(:,4) == 59), 6);
idx1 = [false;diff(m_bass)<(2*(10^-2))]; 
m_bass(idx1) = [];
idx2 = [false;diff(m_snare)<(2*(10^-2))]; 
m_snare(idx2) = [];
idx3 = [false;diff(m_hihat)<(2*(10^-2))]; 
m_hihat(idx3) = [];

onset = [];
%load transcription
onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onset.txt'), ' ')';
idx1 = [false;diff(onset)<(2*(10^-3))]; 
onset(idx1) = [];
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

[true_positive_o,false_positive_o,false_negative_o,delay] = evaluate_instrument(m_onset, onset', window_size);

%evaluate onsets for each class
[true_positive_b,false_positive_b,false_negative_b] = evaluate_instrument(m_bass, onset, window_size);
[true_positive_s,false_positive_s,false_negative_s] = evaluate_instrument(m_snare, onset, window_size);
[true_positive_h,false_positive_h,false_negative_h] = evaluate_instrument(m_hihat, onset, window_size);


detection_matrix =[true_positive_o,false_positive_o,false_negative_o,...
    true_positive_b,false_negative_b,true_positive_s,false_negative_s,...
    true_positive_h,false_negative_h];

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

function out=joinUnevenVectors(varargin)
%#Horizontally catenate multiple column vectors by appending zeros 
%#at the ends of the shorter vectors
%#
%#SYNTAX: out = joinUnevenVectors(vec1, vec2, ... , vecN)

    maxLength=max(cellfun(@numel,varargin));
    out=cell2mat(cellfun(@(x)cat(1,x,zeros(maxLength-length(x),1)),varargin,'UniformOutput',false));
end

%%evaluation_matrix = test_transcription('/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Midi Files/','/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Loops/')
