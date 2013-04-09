function evaluation_matrix = test_onsets_classes_delay(midiDir,audioDir, window_size)

tp_bo = 0;
fp_bo = 0;
fn_bo = 0;
tp_so = 0;
fp_so = 0;
fn_so = 0;
tp_ho = 0;
fp_ho = 0;
fn_ho = 0;
fpo_b_b = 0;
fpo_b_s = 0;
fpo_b_h = 0;
fpo_s_s = 0;
fpo_s_b = 0;
fpo_s_h = 0;
fpo_h_h = 0;
fpo_h_b = 0;
fpo_h_s = 0;

ioi_bass = [];
ioi_snare = [];
ioi_hihat = [];

wavFiles = dir(strcat(audioDir,'*.wav'));

for k = 1:length(wavFiles)
    detection_matrix = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);
    tp_bo = tp_bo + detection_matrix(1,1);
    fp_bo = fp_bo + detection_matrix(1,2);
    fn_bo = fn_bo + detection_matrix(1,3);
    tp_so = tp_so + detection_matrix(2,1);
    fp_so = fp_so + detection_matrix(2,2);
    fn_so = fn_so + detection_matrix(2,3);
    tp_ho = tp_ho + detection_matrix(3,1);
    fp_ho = fp_ho + detection_matrix(3,2);
    fn_ho = fn_ho + detection_matrix(3,3);
    fpo_b_b = fpo_b_b + detection_matrix(4,1);
    fpo_b_s = fpo_b_s + detection_matrix(4,2);
    fpo_b_h = fpo_b_h + detection_matrix(4,3);
    fpo_s_s = fpo_s_s + detection_matrix(5,1);
    fpo_s_b = fpo_s_b + detection_matrix(5,2);
    fpo_s_h = fpo_s_h + detection_matrix(5,3);
    fpo_h_h = fpo_h_h + detection_matrix(6,1);
    fpo_h_b = fpo_h_b + detection_matrix(6,2);
    fpo_h_s = fpo_h_s + detection_matrix(6,3);

    [t_bass ,t_snare, t_hihat] = get_ioi(wavFiles(k).name, midiDir, audioDir, window_size);
    ioi_bass = horzcat(ioi_bass,t_bass');
    ioi_snare = horzcat(ioi_snare,t_snare');
    ioi_hihat = horzcat(ioi_hihat,t_hihat');

end

[Fd_bo,precision_bo,recalld_bo] = evaluate_measures(tp_bo,fp_bo,fn_bo)
[Fd_so,precision_so,recalld_so] = evaluate_measures(tp_so,fp_so,fn_so)
[Fd_ho,precision_ho,recalld_ho] = evaluate_measures(tp_ho,fp_ho,fn_ho)
sensitivity_bo = tp_bo / (tp_bo + fn_bo)
sensitivity_so = tp_so / (tp_so + fn_so)
sensitivity_ho = tp_ho / (tp_ho + fn_ho)

fo_b_b = fpo_b_b/fp_bo;
fo_b_s = fpo_b_s/fp_bo;
fo_b_h = fpo_b_h/fp_bo;
fo_s_s = fpo_s_s/fp_so;
fo_s_b = fpo_s_b/fp_so;
fo_s_h = fpo_s_h/fp_so;
fo_h_h = fpo_h_h/fp_ho;
fo_h_b = fpo_h_b/fp_ho;
fo_h_s = fpo_h_s/fp_ho;

[fo_b_b * precision_bo ,fo_b_s * precision_bo ,fo_b_h * precision_bo]
[fo_s_s * precision_so ,fo_s_b * precision_so ,fo_s_h * precision_so]
[fo_h_h * precision_ho ,fo_h_b * precision_ho ,fo_h_s * precision_ho]

%evaluation_matrix = vertcat([Fd_bo,precisiond_bo,recalld_bo,sensitivity_bo];

plothist = false;
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

%load transcription
onsetb = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetbn.txt'), ' ')';
onsetbs = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetbsn.txt'), ' ')';
onsets = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetsn.txt'), ' ')';
onseth = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsethn.txt'), ' ')';
idx5 = [false;diff(onsetb)<(2*(10^-2))]; 
onsetb(idx5) = [];
idx5 = [false;diff(onsets)<(2*(10^-2))]; 
onsets(idx5) = [];
idx6 = [false;diff(onseth)<(2*(10^-2))]; 
onseth(idx6) = [];
idx7 = [false;diff(onsetbs)<(2*(10^-2))]; 
onsetbs(idx7) = [];
if (numel(onsetb)>2) 
    while (onsetb(1)>onsetb(2)) onsetb = onsetb(2:end);end 
end
if (numel(onsets)>2) 
    while (onsets(1)>onsets(2)) onsets = onsets(2:end);end 
end
if (numel(onseth)>2) 
    while (onseth(1)>onseth(2)) onseth = onseth(2:end);end 
end
if (numel(onsetbs)>2) 
    while (onsetbs(1)>onsetbs(2)) onsetbs = onsetbs(2:end);end 
end

%evaluate onsets for each class
[true_positive_bo,false_positive_bo,false_negative_bo,fpo_b_b,fpo_b_s,fpo_b_h] = evaluate_instrument(m_bass, onsetbs, window_size, m_snare, m_hihat);
[true_positive_so,false_positive_so,false_negative_so,fpo_s_s,fpo_s_b,fpo_s_h] = evaluate_instrument(m_snare, onsetbs, window_size, m_bass, m_hihat);
[true_positive_ho,false_positive_ho,false_negative_ho,fpo_h_h,fpo_h_b,fpo_h_s] = evaluate_instrument(m_hihat, onseth, window_size, m_bass, m_snare);


detection_matrix = vertcat([true_positive_bo,false_positive_bo,false_negative_bo],...
    [true_positive_so,false_positive_so,false_negative_so],...
    [true_positive_ho,false_positive_ho,false_negative_ho],...
    [fpo_b_b,fpo_b_s,fpo_b_h],...
    [fpo_s_s,fpo_s_b,fpo_s_h],...
    [fpo_h_h,fpo_h_b,fpo_h_s]);

end

function [true_positive,false_positive,false_negative,fp_zero,fp_one,fp_two] = evaluate_instrument(midi, onset, window_size, midi_one, midi_two)

true_positive = 0;
false_positive = 0;
false_negative = 0;

fp_zero = 0;
fp_one = 0;
fp_two = 0;

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
            %determine which kind of false positive we have
            fpz = 1;
            indices_one = find(midi_one < onset(i),1,'last');
            if ((length(indices_one)>0) && ((onset(i) - midi_one(indices_one(1)))<window_size)) fp_one = fp_one + 1;midi_one(indices_one(1))=[];fpz = 0;end
            indices_two = find(midi_two < onset(i),1,'last');
            if ((length(indices_two)>0) && ((onset(i) - midi_two(indices_two(1)))<window_size)) fp_two = fp_two + 1;midi_two(indices_two(1))=[];fpz = 0;end
            if (fpz==1) fp_zero = fp_zero + 1;end                  
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
