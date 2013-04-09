function evaluation_matrix = test_delay(midiDir,audioDir, window_size)

true_positive_b = 0;
false_positive_b = 0;
false_negative_b = 0;
true_positive_s = 0;
false_positive_s = 0;
false_negative_s = 0;
true_positive_h = 0;
false_positive_h = 0;
false_negative_h = 0;

true_positive_o = 0;
false_positive_o = 0;
false_negative_o = 0;

wavFiles = dir(strcat(audioDir,'*.wav'));
midiFiles = dir(strcat(midiDir,'*.mid'));

for k = 1:length(wavFiles)   
    
    %get variables from file name
    Ind = findstr(wavFiles(k).name, 'd');
    seq = wavFiles(k).name(1:Ind-1);
    [a,b,c] = strread(seq,'%d%d%d','delimiter','_');
    if (numel(b)<1) 
        type(k)=1;
        in1(k) = int32(a);
        in2(k) = 0;
        in3(k) = 0;
    else if (numel(c)<1) 
            type(k)=2;
            in1(k) = int32(a);
            in2(k) = int32(b);
            in3(k) = 0;
        else
            type(k)=3;
            in1(k) = int32(a);
            in2(k) = int32(b);
            in3(k) = int32(c);
        end
    end
    d = wavFiles(k).name(Ind+1:end);
    Ind2 = findstr(d, '_');
    delay(k) = int32(str2num(d(1:Ind2-1)));

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
    
    tp_b(k) = detection_matrix(1,1);
    fp_b(k) = detection_matrix(1,2);
    fn_b (k)= detection_matrix(1,3);
    tp_s(k) = detection_matrix(2,1);
    fp_s(k) = detection_matrix(2,2);
    fn_s(k) = detection_matrix(2,3);
    tp_h(k) = detection_matrix(3,1);
    fp_h(k) = detection_matrix(3,2);
    fn_h(k) = detection_matrix(3,3);
    
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
    
    true_positive_o = true_positive_o + detection_matrix(4,1);
    false_positive_o = false_positive_o + detection_matrix(4,2);
    false_negative_o = false_negative_o + detection_matrix(4,3);
    
    tp_o(k) = detection_matrix(4,1);
    fp_o(k) = detection_matrix(4,2);
    fn_o(k) = detection_matrix(4,3);
    
    tp_bo(k) = detection_matrix(5,1);
    fp_bo(k) = detection_matrix(5,2);
    fn_bo(k) = detection_matrix(5,3);
    tp_so(k) = detection_matrix(6,1);
    fp_so(k) = detection_matrix(6,2);
    fn_so(k) = detection_matrix(6,3);
    tp_ho(k) = detection_matrix(7,1);
    fp_ho(k) = detection_matrix(7,2);
    fn_ho(k) = detection_matrix(7,3);
    
    fp_b_b(k) = detection_matrix(8,1);
    fp_b_s(k) = detection_matrix(8,2);
    fp_b_h(k) = detection_matrix(8,3);
    fp_s_s(k) = detection_matrix(9,1);
    fp_s_b(k) = detection_matrix(9,2);
    fp_s_h(k) = detection_matrix(9,3);
    fp_h_h(k) = detection_matrix(10,1);
    fp_h_b(k) = detection_matrix(10,2);
    fp_h_s(k) = detection_matrix(10,3);
    fpo_b_b(k) = detection_matrix(11,1);
    fpo_b_s(k) = detection_matrix(11,2);
    fpo_b_h(k) = detection_matrix(11,3);
    fpo_s_s(k) = detection_matrix(12,1);
    fpo_s_b(k) = detection_matrix(12,2);
    fpo_s_h(k) = detection_matrix(12,3);
    fpo_h_h(k) = detection_matrix(13,1);
    fpo_h_b(k) = detection_matrix(13,2);
    fpo_h_s(k) = detection_matrix(13,3);

end

%generate F measures based on delay time
delays=[-90 -70 -50 -30 -20 -10 0 10 20 30 50 70 90 120];
f_b_b = zeros(1,numel(delays));
f_b_s = zeros(1,numel(delays));
f_b_h = zeros(1,numel(delays));
f_s_s = zeros(1,numel(delays));
f_s_b = zeros(1,numel(delays));
f_s_h = zeros(1,numel(delays));
f_h_h = zeros(1,numel(delays));
f_h_b = zeros(1,numel(delays));
f_h_s = zeros(1,numel(delays));
fo_b_b = zeros(1,numel(delays));
fo_b_s = zeros(1,numel(delays));
fo_b_h = zeros(1,numel(delays));
fo_s_s = zeros(1,numel(delays));
fo_s_b = zeros(1,numel(delays));
fo_s_h = zeros(1,numel(delays));
fo_h_h = zeros(1,numel(delays));
fo_h_b = zeros(1,numel(delays));
fo_h_s = zeros(1,numel(delays));

for i=1:numel(delays)
   index = delay==delays(i);
   %index = ((delay==delays(i)) & (type==3));
   %[Fd_o(i),precisiond_o(i),recalld_o(i)] = evaluate_measures(tp_o(index),fp_o(index),fn_o(index)); 
   [Fd_bo(i),precisiond_bo(i),recalld_bo(i)] = evaluate_measures(tp_bo(index),fp_bo(index),fn_bo(index));
   [Fd_so(i),precisiond_so(i),recalld_so(i)] = evaluate_measures(tp_so(index),fp_so(index),fn_so(index));
   [Fd_ho(i),precisiond_ho(i),recalld_ho(i)] = evaluate_measures(tp_ho(index),fp_ho(index),fn_ho(index));
   
   [Fd_b(i),precisiond_b(i),recalld_b(i)] = evaluate_measures(tp_b(index),fp_b(index),fn_b(index));
   [Fd_s(i),precisiond_s(i),recalld_s(i)] = evaluate_measures(tp_s(index),fp_s(index),fn_s(index));
   [Fd_h(i),precisiond_h(i),recalld_h(i)] = evaluate_measures(tp_h(index),fp_h(index),fn_h(index)); 
   
    f_b_b(i) = fp_b_b(index)/fp_b(index);
    f_b_s(i) = fp_b_s(index)/fp_b(index);
    f_b_h(i) = fp_b_h(index)/fp_b(index);
    f_s_s(i) = fp_s_s(index)/fp_s(index);
    f_s_b(i) = fp_s_b(index)/fp_s(index);
    f_s_h(i) = fp_s_h(index)/fp_s(index);
    f_h_h(i) = fp_h_h(index)/fp_h(index);
    f_h_b(i) = fp_h_b(index)/fp_h(index);
    f_h_s(i) = fp_h_s(index)/fp_h(index);
    fo_b_b(i) = fpo_b_b(index)/fp_bo(index);
    fo_b_s(i) = fpo_b_s(index)/fp_bo(index);
    fo_b_h(i) = fpo_b_h(index)/fp_bo(index);
    fo_s_s(i) = fpo_s_s(index)/fp_so(index);
    fo_s_b(i) = fpo_s_b(index)/fp_so(index);
    fo_s_h(i) = fpo_s_h(index)/fp_so(index);
    fo_h_h(i) = fpo_h_h(index)/fp_ho(index);
    fo_h_b(i) = fpo_h_b(index)/fp_ho(index);
    fo_h_s(i) = fpo_h_s(index)/fp_ho(index);
end

precisiond_bo = 1-precisiond_bo;
precisiond_so = 1-precisiond_so;
precisiond_ho = 1-precisiond_ho;
precisiond_b = 1-precisiond_b;
precisiond_s = 1-precisiond_s;
precisiond_h = 1-precisiond_h;

% figure
% subplot(3,3,1)
% ylim([0 1])
% bar(delays,Fd_bo);
% %xlabel('delay times kick')
% %ylabel('F measure onsets kick')
% subplot(3,3,2)
% ylim([0 1])
% bar(delays,Fd_so);
% %xlabel('delay times snare')
% %ylabel('F measure onsets snare')
% subplot(3,3,3)
% ylim([0 1])
% bar(delays,Fd_ho);
% %xlabel('delay times hihat')
% %ylabel('F measure onsets hihat')
% subplot(3,3,4)
% ylim([0 1])
% bar(delays,[fo_b_b'.*precisiond_bo' fo_b_s'.*precisiond_bo' fo_b_h'.*precisiond_bo'], 'stacked');legend('K', 'S', 'H');
% %xlabel('delay times kick')
% %ylabel('1-precision onsets kick')
% subplot(3,3,5)
% ylim([0 1])
% bar(delays,[fo_s_s'.*precisiond_so' fo_s_b'.*precisiond_so' fo_s_h'.*precisiond_so'], 'stacked');legend('S', 'K', 'H');
% %xlabel('delay times onsets snare')
% %ylabel('1-precision onsets snare')
% subplot(3,3,6)
% ylim([0 1])
% bar(delays,[fo_h_h'.*precisiond_ho' fo_h_b'.*precisiond_ho' fo_h_s'.*precisiond_ho'], 'stacked');legend('H', 'K', 'S');
% %xlabel('delay times hihat')
% %ylabel('1-precision onsets hihat')
% subplot(3,3,7)
% ylim([0 1])
% bar(delays,recalld_bo);
% %xlabel('delay times kick')
% %ylabel('recall onsets kick')
% subplot(3,3,8)
% ylim([0 1])
% bar(delays,recalld_so);
% %xlabel('delay times snare')
% %ylabel('recall onsets snare')
% subplot(3,3,9)
% ylim([0 1])
% bar(delays,recalld_ho);
% %xlabel('delay times hihat')
% %ylabel('recall onsets hihat')

figure
%subplot(3,3,1)
ylim([0 1])
h=bar(delays,Fd_b);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
%xlabel('delay times kick')
%ylabel('F measure kick')
%subplot(3,3,2)
figure
ylim([0 1])
h=bar(delays,Fd_s);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
%xlabel('delay times snare')
%ylabel('F measure snare')
%subplot(3,3,3)
figure
ylim([0 1])
h=bar(delays,Fd_h);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
%xlabel('delay times hihat')
%ylabel('F measure hihat')
%subplot(3,3,4)
figure
ylim([0 1])
h = bar(delays,[f_b_b'.*precisiond_b' f_b_s'.*precisiond_b' f_b_h'.*precisiond_b'], 'stacked');
axis([-100 130 0 1]);legend('BD', 'SD', 'HH');set(h(1),'facecolor',[0 0 0]);set(h(2),'facecolor',[0.6 0.6 0.6]);set(h(3),'facecolor',[0.91 0.91 0.91]);
%xlabel('delay times kick')
%ylabel('1-precision kick')
%subplot(3,3,5)
figure
ylim([0 1])
h = bar(delays,[f_s_b'.*precisiond_s' f_s_s'.*precisiond_s' f_s_h'.*precisiond_s'], 'stacked');
axis([-100 130 0 1]);legend('BD', 'SD', 'HH');set(h(1),'facecolor',[0 0 0]);set(h(2),'facecolor',[0.6 0.6 0.6]);set(h(3),'facecolor',[0.91 0.91 0.91]);
%xlabel('delay times snare')
%ylabel('1-precision snare')
%subplot(3,3,6)
figure
ylim([0 1])
h = bar(delays,[f_h_b'.*precisiond_h' f_h_s'.*precisiond_h' f_h_h'.*precisiond_h'], 'stacked');
axis([-100 130 0 1]);legend('BD', 'SD', 'HH');set(h(1),'facecolor',[0 0 0]);set(h(2),'facecolor',[0.6 0.6 0.6]);set(h(3),'facecolor',[0.91 0.91 0.91]);
%xlabel('delay times hihat')
%ylabel('1-precision hihat')
%subplot(3,3,7)
figure
ylim([0 1])
h=bar(delays,recalld_b);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
%xlabel('delay times kick')
%ylabel('recall kick')
%subplot(3,3,8)
figure
ylim([0 1])
h=bar(delays,recalld_s);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
%xlabel('delay times snare')
%ylabel('recall snare')
%subplot(3,3,9)
figure
ylim([0 1])
h=bar(delays,recalld_h);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
%xlabel('delay times hihat')
%ylabel('recall hihat')


% [F_b,precision_b,recall_b] = evaluate_measures(true_positive_b,false_positive_b,false_negative_b);
% [F_s,precision_s,recall_s] = evaluate_measures(true_positive_s,false_positive_s,false_negative_s);
% [F_h,precision_h,recall_h] = evaluate_measures(true_positive_h,false_positive_h,false_negative_h);
% [F,precision,recall] = evaluate_measures(true_positive_b + true_positive_s + true_positive_h,...
%                                         false_positive_b + false_positive_s + false_positive_h,...
%                                         false_negative_b + false_negative_s + false_negative_h);
% %[F_o,precision_o,recall_o] = evaluate_measures(true_positive_o,false_positive_o,false_negative_o)
% 
% [true_positive_b,false_positive_b,false_negative_b]
% [true_positive_s,false_positive_s,false_negative_s]
% [true_positive_h,false_positive_h,false_negative_h]
% %[true_positive_o,false_positive_o,false_negative_o]
% 
% F_meanb = mean(F_mb)
% F_stdb = std(F_mb)
% F_means = mean(F_ms)
% F_stds = std(F_ms)
% F_meanh = mean(F_mh)
% F_stdh = std(F_mh)
% F_mean = mean(F_m)
% F_std = std(F_m)
% 
% evaluation_matrix = vertcat([F_b,precision_b,recall_b],...
%     [F_s,precision_s,recall_s],...
%     [F_h,precision_h,recall_h],...
%     [F,precision,recall]);

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
m_onset = drums(:,6);
idx1 = [false;diff(m_bass)<(9*(10^-3))]; 
m_bass(idx1) = [];
idx2 = [false;diff(m_snare)<(9*(10^-3))]; 
m_snare(idx2) = [];
idx3 = [false;diff(m_hihat)<(9*(10^-3))]; 
m_hihat(idx3) = [];
idx4 = [false;diff(m_onset)<(9*(10^-3))]; 
m_onset(idx3) = [];

%load transcription
bass = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_bassf.txt'), ' ')';
snare = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_snaref.txt'), ' ')';
hihat = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_hihatf.txt'), ' ')';
%onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onset.txt'), ' ')';
onsetb = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetbn.txt'), ' ')';
onsets = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsetsn.txt'), ' ')';
onseth = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onsethn.txt'), ' ')';
idx1 = [false;diff(bass)<(9*(10^-3))]; 
bass(idx1) = [];
idx2 = [false;diff(snare)<(9*(10^-3))]; 
snare(idx2) = [];
idx3 = [false;diff(hihat)<(9*(10^-3))]; 
hihat(idx3) = [];
% idx4 = [false;diff(onset)<(9*(10^-3))]; 
% onset(idx4) = [];
idx5 = [false;diff(onsetb)<(9*(10^-3))]; 
onsetb(idx5) = [];
idx5 = [false;diff(onsets)<(9*(10^-3))]; 
onsets(idx5) = [];
idx6 = [false;diff(onseth)<(9*(10^-3))]; 
onseth(idx6) = [];
if (numel(bass)>2) 
    while (bass(1)>bass(2)) bass = bass(2:end);end 
end
if (numel(snare)>2) 
    while (snare(1)>snare(2)) snare = snare(2:end);end 
end
if (numel(hihat)>2) 
    while (hihat(1)>hihat(2)) hihat = hihat(2:end);end 
end
% if (numel(onset)>2) 
%     while (onset(1)>onset(2)) onset = onset(2:end);end 
% end
if (numel(onsetb)>2) 
    while (onsetb(1)>onsetb(2)) onsetb = onsetb(2:end);end 
end
if (numel(onsets)>2) 
    while (onsets(1)>onsets(2)) onsets = onsets(2:end);end 
end
if (numel(onseth)>2) 
    while (onseth(1)>onseth(2)) onseth = onseth(2:end);end 
end

%m_bass'
%bass
%keyboard
[true_positive_b,false_positive_b,false_negative_b,fp_b_b,fp_b_s,fp_b_h] = evaluate_instrument(m_bass, bass, window_size, m_snare, m_hihat);
[true_positive_s,false_positive_s,false_negative_s,fp_s_s,fp_s_b,fp_s_h] = evaluate_instrument(m_snare, snare, window_size, m_bass, m_hihat);
[true_positive_h,false_positive_h,false_negative_h,fp_h_h,fp_h_b,fp_h_s] = evaluate_instrument(m_hihat, hihat, window_size, m_bass, m_snare);
%[true_positive_o,false_positive_o,false_negative_o] = evaluate_instrument(m_onset, onset, window_size);
%evaluate onsets for each class
[true_positive_bo,false_positive_bo,false_negative_bo,fpo_b_b,fpo_b_s,fpo_b_h] = evaluate_instrument(m_bass, onsetb, window_size, m_snare, m_hihat);
[true_positive_so,false_positive_so,false_negative_so,fpo_s_s,fpo_s_b,fpo_s_h] = evaluate_instrument(m_snare, onsets, window_size, m_bass, m_hihat);
[true_positive_ho,false_positive_ho,false_negative_ho,fpo_h_h,fpo_h_b,fpo_h_s] = evaluate_instrument(m_hihat, onseth, window_size, m_bass, m_snare);

detection_matrix = vertcat([true_positive_b,false_positive_b,false_negative_b],...
    [true_positive_s,false_positive_s,false_negative_s],...
    [true_positive_h,false_positive_h,false_negative_h],...
    [0,0,0],...
    [true_positive_bo,false_positive_bo,false_negative_bo],...
    [true_positive_so,false_positive_so,false_negative_so],...
    [true_positive_ho,false_positive_ho,false_negative_ho],...
    [fp_b_b,fp_b_s,fp_b_h],...
    [fp_s_s,fp_s_b,fp_s_h],...
    [fp_h_h,fp_h_b,fp_h_s],...
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

%%evaluation_matrix = test_transcription('/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Midi Files/','/Users/mmiron/Documents/INESC/drum_transcription/groundtruth/Loops/')
