function evaluation_matrix = test_transcription_delay(midiDir,audioDir, window_size)

true_positive_b = 0;
false_positive_b = 0;
false_negative_b = 0;
true_positive_s = 0;
false_positive_s = 0;
false_negative_s = 0;
true_positive_h = 0;
false_positive_h = 0;
false_negative_h = 0;

%true_positive_o = 0;
%false_positive_o = 0;
%false_negative_o = 0;

wavFiles = dir(strcat(audioDir,'*.wav'));
midiFiles = dir(strcat(midiDir,'*.mid'));

for k = 1:length(wavFiles)   
    
    detection_matrix = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);
    true_positive_b = true_positive_b + detection_matrix(1,1);
    false_positive_b = false_positive_b + detection_matrix(1,2);
    false_negative_b = false_negative_b + detection_matrix(1,3);
    true_positive_s = true_positive_s + detection_matrix(2,1);
    false_positive_s = false_positive_s + detection_matrix(2,2);
    false_negative_s = false_negative_s + detection_matrix(2,3);
    true_positive_h = true_positive_h + detection_matrix(3,1);
    false_positive_h = false_positive_h + detection_matrix(3,2);
    false_negative_h = false_negative_h + detection_matrix(3,3);
    
    [F_tb,precision_tb,recall_tb] = evaluate_measures(detection_matrix(1,1),detection_matrix(1,2),detection_matrix(1,3));
    if (isnan(F_tb)) F_tb = 0;end 
    F_mb(k) = F_tb;
    [F_ts,precision_ts,recall_ts] = evaluate_measures(detection_matrix(2,1),detection_matrix(2,2),detection_matrix(2,3));
    if (isnan(F_ts)) F_ts = 0;end 
    F_ms(k) = F_ts;
    [F_th,precision_th,recall_th] = evaluate_measures(detection_matrix(3,1),detection_matrix(3,2),detection_matrix(3,3));
    if (isnan(F_th)) F_th = 0;end 
    F_mh(k) = F_th;
    [F_t,precision_t,recall_t] = evaluate_measures(detection_matrix(1,1)+detection_matrix(2,1)+detection_matrix(3,1),...
        detection_matrix(1,2)+detection_matrix(2,2)+detection_matrix(3,2),...
        detection_matrix(1,3)+detection_matrix(2,3)+detection_matrix(3,3));
    if (isnan(F_t)) F_t = 0;end 
    F_m(k) = F_t;
    
    %true_positive_o = true_positive_o + detection_matrix(4,1);
    %false_positive_o = false_positive_o + detection_matrix(4,2);
    %false_negative_o = false_negative_o + detection_matrix(4,3);
end

[F_b,precision_b,recall_b] = evaluate_measures(true_positive_b,false_positive_b,false_negative_b);
[F_s,precision_s,recall_s] = evaluate_measures(true_positive_s,false_positive_s,false_negative_s);
[F_h,precision_h,recall_h] = evaluate_measures(true_positive_h,false_positive_h,false_negative_h);
[F,precision,recall] = evaluate_measures(true_positive_b + true_positive_s + true_positive_h,...
                                        false_positive_b + false_positive_s + false_positive_h,...
                                        false_negative_b + false_negative_s + false_negative_h);
%[F_o,precision_o,recall_o] = evaluate_measures(true_positive_o,false_positive_o,false_negative_o)

[true_positive_b,false_positive_b,false_negative_b]
[true_positive_s,false_positive_s,false_negative_s]
[true_positive_h,false_positive_h,false_negative_h]
%[true_positive_o,false_positive_o,false_negative_o]

F_meanb = mean(F_mb)
F_stdb = std(F_mb)
F_means = mean(F_ms)
F_stds = std(F_ms)
F_meanh = mean(F_mh)
F_stdh = std(F_mh)
F_mean = mean(F_m)
F_std = std(F_m)

evaluation_matrix = vertcat([F_b,precision_b,recall_b],...
    [F_s,precision_s,recall_s],...
    [F_h,precision_h,recall_h],...
    [F,precision,recall]);

end

function detection_matrix = get_transcription(audiofile, midiDir, audioDir, window_size)

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
%drumhits=[35,36,38,40,42,44,46,49,51,52,53,55,57,59];
%m_onset = drums(:,6);
idx1 = [false;diff(m_bass)<(2*(10^-2))]; 
m_bass(idx1) = [];
idx2 = [false;diff(m_snare)<(2*(10^-2))]; 
m_snare(idx2) = [];
idx3 = [false;diff(m_hihat)<(2*(10^-2))]; 
m_hihat(idx3) = [];

%load transcription
bass = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_bassnf.txt'), ' ')';
snare = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_snarenf.txt'), ' ')';
hihat = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_hihatnf.txt'), ' ')';
%onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onset.txt'), ' ');
idx1 = [false;diff(bass)<(5*(10^-3))]; 
bass(idx1) = [];
idx2 = [false;diff(snare)<(5*(10^-3))]; 
snare(idx2) = [];
idx3 = [false;diff(hihat)<(3*(10^-3))]; 
hihat(idx3) = [];
if (numel(bass)>2) 
    while (bass(1)>bass(2)) bass = bass(2:end);end 
end
if (numel(snare)>2) 
    while (snare(1)>snare(2)) snare = snare(2:end);end 
end
if (numel(hihat)>2) 
    while (hihat(1)>hihat(2)) hihat = hihat(2:end);end 
end

%m_bass'
%bass
%keyboard
[true_positive_b,false_positive_b,false_negative_b] = evaluate_instrument(m_bass, bass, window_size);
[true_positive_s,false_positive_s,false_negative_s] = evaluate_instrument(m_snare, snare, window_size);
[true_positive_h,false_positive_h,false_negative_h] = evaluate_instrument(m_hihat, hihat, window_size);
%[true_positive_o,false_positive_o,false_negative_o] = evaluate_instrument(m_onset, onset', window_size);

detection_matrix = vertcat([true_positive_b,false_positive_b,false_negative_b],...
    [true_positive_s,false_positive_s,false_negative_s],...
    [true_positive_h,false_positive_h,false_negative_h]);
   % [true_positive_o,false_positive_o,false_negative_o]);

end

function [true_positive,false_positive,false_negative] = evaluate_instrument(midi, onset, window_size)

true_positive = 0;
false_positive = 0;
false_negative = 0;

for i = 1:length(onset)    
    
    if (size(midi)~=0)
        
        %detect the closest element from the midi grountruth and remove it  
        %indices = find(abs(midi - onset(i))<window_size,1);
        indices = find(midi < onset(i),1,'last');        
        %if indices
        if ((length(indices)>0) && ((onset(i) - midi(indices(1)))<window_size))          
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
