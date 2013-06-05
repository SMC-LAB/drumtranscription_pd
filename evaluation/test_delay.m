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
    
    fp_b_b(k) = detection_matrix(8,1);
    fp_b_s(k) = detection_matrix(8,2);
    fp_b_h(k) = detection_matrix(8,3);
    fp_s_s(k) = detection_matrix(9,1);
    fp_s_b(k) = detection_matrix(9,2);
    fp_s_h(k) = detection_matrix(9,3);
    fp_h_h(k) = detection_matrix(10,1);
    fp_h_b(k) = detection_matrix(10,2);
    fp_h_s(k) = detection_matrix(10,3);

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

for i=1:numel(delays)
   index = delay==delays(i);
   %index = ((delay==delays(i)) & (type==3));
 
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
end

precisiond_b = 1-precisiond_b;
precisiond_s = 1-precisiond_s;
precisiond_h = 1-precisiond_h;

figure
%subplot(3,3,1)
ylim([0 1])
h=bar(delays,Fd_b);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
xlabel('delay times kick')
ylabel('F measure kick')
%subplot(3,3,2)
figure
ylim([0 1])
h=bar(delays,Fd_s);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
xlabel('delay times snare')
ylabel('F measure snare')
%subplot(3,3,3)
figure
ylim([0 1])
h=bar(delays,Fd_h);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
xlabel('delay times hihat')
ylabel('F measure hihat')
%subplot(3,3,4)
figure
ylim([0 1])
h = bar(delays,[f_b_b'.*precisiond_b' f_b_s'.*precisiond_b' f_b_h'.*precisiond_b'], 'stacked');
axis([-100 130 0 1]);legend('BD', 'SD', 'HH');set(h(1),'facecolor',[0 0 0]);set(h(2),'facecolor',[0.6 0.6 0.6]);set(h(3),'facecolor',[0.91 0.91 0.91]);
xlabel('delay times kick')
ylabel('1-precision kick')
%subplot(3,3,5)
figure
ylim([0 1])
h = bar(delays,[f_s_b'.*precisiond_s' f_s_s'.*precisiond_s' f_s_h'.*precisiond_s'], 'stacked');
axis([-100 130 0 1]);legend('BD', 'SD', 'HH');set(h(1),'facecolor',[0 0 0]);set(h(2),'facecolor',[0.6 0.6 0.6]);set(h(3),'facecolor',[0.91 0.91 0.91]);
xlabel('delay times snare')
ylabel('1-precision snare')
%subplot(3,3,6)
figure
ylim([0 1])
h = bar(delays,[f_h_b'.*precisiond_h' f_h_s'.*precisiond_h' f_h_h'.*precisiond_h'], 'stacked');
axis([-100 130 0 1]);legend('BD', 'SD', 'HH');set(h(1),'facecolor',[0 0 0]);set(h(2),'facecolor',[0.6 0.6 0.6]);set(h(3),'facecolor',[0.91 0.91 0.91]);
xlabel('delay times hihat')
ylabel('1-precision hihat')
%subplot(3,3,7)
figure
ylim([0 1])
h=bar(delays,recalld_b);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
xlabel('delay times kick')
ylabel('recall kick')
%subplot(3,3,8)
figure
ylim([0 1])
h=bar(delays,recalld_s);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
xlabel('delay times snare')
ylabel('recall snare')
%subplot(3,3,9)
figure
ylim([0 1])
h=bar(delays,recalld_h);
axis([-100 130 0 1]);set(h(1),'facecolor',[0 0 0]);
xlabel('delay times hihat')
ylabel('recall hihat')



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
bass = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_bassnf.txt'), ' ')';
snare = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_snarenf.txt'), ' ')';
hihat = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_hihatnf.txt'), ' ')';

idx1 = [false;diff(bass)<(9*(10^-3))]; 
bass(idx1) = [];
idx2 = [false;diff(snare)<(9*(10^-3))]; 
snare(idx2) = [];
idx3 = [false;diff(hihat)<(9*(10^-3))]; 
hihat(idx3) = [];
% idx4 = [false;diff(onset)<(9*(10^-3))]; 
% onset(idx4) = [];

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
[true_positive_b,false_positive_b,false_negative_b,fp_b_b,fp_b_s,fp_b_h] = evaluate_instrument(m_bass, bass, window_size, m_snare, m_hihat);
[true_positive_s,false_positive_s,false_negative_s,fp_s_s,fp_s_b,fp_s_h] = evaluate_instrument(m_snare, snare, window_size, m_bass, m_hihat);
[true_positive_h,false_positive_h,false_negative_h,fp_h_h,fp_h_b,fp_h_s] = evaluate_instrument(m_hihat, hihat, window_size, m_bass, m_snare);
%[true_positive_o,false_positive_o,false_negative_o] = evaluate_instrument(m_onset, onset, window_size);
%evaluate onsets for each class

detection_matrix = vertcat([true_positive_b,false_positive_b,false_negative_b],...
    [true_positive_s,false_positive_s,false_negative_s],...
    [true_positive_h,false_positive_h,false_negative_h],...
    [0,0,0],...
    [0,0,0],...
    [0,0,0],...
    [0,0,0],...
    [fp_b_b,fp_b_s,fp_b_h],...
    [fp_s_s,fp_s_b,fp_s_h],...
    [fp_h_h,fp_h_b,fp_h_s],...
    [0,0,0],...
    [0,0,0],...
    [0,0,0]);
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
