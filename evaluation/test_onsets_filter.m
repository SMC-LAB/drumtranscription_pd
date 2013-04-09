function evaluation_matrix = test_onsets_filter(midiDir,audioDir, window_size)

true_positive_b = 0;
false_positive_b1 = 0;
false_positive_b2 = 0;
false_negative_b = 0;
true_negative_b = 0;
true_positive_s = 0;
false_positive_s1 = 0;
false_positive_s2 = 0;
false_negative_s = 0;
true_negative_s = 0;
true_positive_h = 0;
false_positive_h1 = 0;
false_positive_h2 = 0;
false_negative_h = 0;
true_negative_h = 0;

wavFiles = dir(strcat(audioDir,'*.wav'));

for k = 1:length(wavFiles)
    detection_matrix = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);
    true_positive_b = true_positive_b + detection_matrix(1,1);
    false_positive_b1 = false_positive_b1 + detection_matrix(1,2);
    false_positive_b2 = false_positive_b2 + detection_matrix(1,3);
    false_negative_b = false_negative_b + detection_matrix(1,4);
    true_negative_b = true_negative_b + detection_matrix(1,5);
    true_positive_s = true_positive_s + detection_matrix(2,1);
    false_positive_s1 = false_positive_s1 + detection_matrix(2,2);
    false_positive_s2 = false_positive_s2 + detection_matrix(2,3);
    false_negative_s = false_negative_s + detection_matrix(2,4);
    true_negative_s = true_negative_s + detection_matrix(2,5);
    true_positive_h = true_positive_h + detection_matrix(3,1);
    false_positive_h1 = false_positive_h1 + detection_matrix(3,2);
    false_positive_h2 = false_positive_h2 + detection_matrix(3,3);
    false_negative_h = false_negative_h + detection_matrix(3,4);
    true_negative_h = true_negative_h + detection_matrix(3,5);
end



%false_positive_b1 = false_positive_b1 - false_positive_b2;
%false_positive_s1 = false_positive_s1 - false_positive_s2;
%false_positive_h1 = false_positive_h1 - false_positive_h2;

bass=[true_positive_b,false_negative_b,true_negative_b,false_positive_b1,false_positive_b2]
snare=[true_positive_s,false_negative_s,true_negative_s,false_positive_s1,false_positive_s2]
hihat=[true_positive_h,false_negative_h,true_negative_h,false_positive_h1,false_positive_h2]

[F_b,precision_b,recall_b] = evaluate_measures(true_positive_b,false_positive_b2,false_negative_b);
[F_s,precision_s,recall_s] = evaluate_measures(true_positive_s,false_positive_s2,false_negative_s);
[F_h,precision_h,recall_h] = evaluate_measures(true_positive_h,false_positive_h2,false_negative_h);

sensitivity_b = true_positive_b / (true_positive_b + false_negative_b);
sensitivity_s = true_positive_s / (true_positive_s + false_negative_s);
sensitivity_h = true_positive_h / (true_positive_h + false_negative_h);

specificity_b = true_negative_b / (true_negative_b + false_positive_b1);
specificity_s = true_negative_s / (true_negative_s + false_positive_s1);
specificity_h = true_negative_h / (true_negative_h + false_positive_h1);

performance_b = true_positive_b / (true_positive_b + false_positive_b1);
performance_s = true_positive_s / (true_positive_s + false_positive_s1);
performance_h = true_positive_h / (true_positive_h + false_positive_h1);

evaluation_matrix = [F_b,precision_b,recall_b,specificity_b,performance_b;...
    F_s,precision_s,recall_s,specificity_s,performance_s;...
    F_h,precision_h,recall_h,specificity_h,performance_h];

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

m_not_bass = drums(((drums(:,4) ~= 35) | (drums(:,4) ~= 36)), 6);
m_not_snare = drums((drums(:,4) ~= 38) | (drums(:,4) ~= 40), 6);
m_not_hihat = drums((drums(:,4) ~= 44) | (drums(:,4) ~= 46) ...
    | (drums(:,4) ~= 49) | (drums(:,4) ~= 51) ...
    | (drums(:,4) ~= 52) | (drums(:,4) ~= 55) ...
    | (drums(:,4) ~= 53) | (drums(:,4) ~= 42) ...
    | (drums(:,4) ~= 57) | (drums(:,4) ~= 59), 6);

idx1 = [false;diff(m_bass)<(2*(10^-2))]; 
m_bass(idx1) = [];
idx2 = [false;diff(m_snare)<(2*(10^-2))]; 
m_snare(idx2) = [];
idx3 = [false;diff(m_hihat)<(2*(10^-2))]; 
m_hihat(idx3) = [];

%check bass and snare simultaneously 
%[tp,fp,fn] = evaluate_instrument(m_bass, m_snare, 0.02);
%if (tp>0)
%tp
%m_bass
%m_snare
%end

onset_b = [];
onset_s = [];
onset_h = [];
%load transcription
onset_b = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetfb.txt'), ' ')';
onset_s = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetfs.txt'), ' ')';
onset_h = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetfh.txt'), ' ')';
idx1 = [false;diff(onset_b)<(5*(10^-3))]; 
onset_b(idx1) = [];
idx2 = [false;diff(onset_s)<(5*(10^-3))]; 
onset_s(idx2) = [];
idx3 = [false;diff(onset_h)<(3*(10^-3))]; 
onset_h(idx3) = [];
if (numel(onset_b)>2) 
    while (onset_b(1)>onset_b(2)) onset_b = onset_b(2:end);end
end
if (numel(onset_s)>2) 
    while (onset_s(1)>onset_s(2)) onset_s = onset_s(2:end);end
end
if (numel(onset_h)>2) 
    while (onset_h(1)>onset_h(2)) onset_h = onset_h(2:end);end
end

%evaluate onsets for each class
[true_positive_b,false_positive_b1,false_negative_b] = evaluate_instrument(m_bass, onset_b, window_size);
[true_positive_s,false_positive_s1,false_negative_s] = evaluate_instrument(m_snare, onset_s, window_size);
[true_positive_h,false_positive_h1,false_negative_h] = evaluate_instrument(m_hihat, onset_h, window_size);


[t,false_positive_b2,f] = evaluate_instrument(m_onset, onset_b, window_size);
[t,false_positive_s2,f] = evaluate_instrument(m_onset, onset_s, window_size);
[t,false_positive_h2,f] = evaluate_instrument(m_onset, onset_h, window_size);

[t,f,true_negative_b] = evaluate_instrument(m_not_bass, onset_b, window_size);
[t,f,true_negative_s] = evaluate_instrument(m_not_snare, onset_s, window_size);
[t,f,true_negative_h] = evaluate_instrument(m_not_hihat, onset_h, window_size);


detection_matrix = vertcat([true_positive_b,false_positive_b1,false_positive_b2,false_negative_b,true_negative_b],...
    [true_positive_s,false_positive_s1,false_positive_s2,false_negative_s,true_negative_s],...
    [true_positive_h,false_positive_h1,false_positive_h2,false_negative_h,true_negative_h]);

end

function [true_positive,false_positive,false_negative] = evaluate_instrument(midi, onset, window_size)
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
