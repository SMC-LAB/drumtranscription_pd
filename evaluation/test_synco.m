function evaluation_matrix = test_synco(midiDir,audioDir, window_size)


wavFiles = dir(strcat(audioDir,'*.wav'));
syncperbar_bassm = [];
syncperbar_snarem = [];
syncperbar_hihatm = [];
syncperbar_bass_snarem = [];
syncperbar_basst = [];
syncperbar_snaret = [];
syncperbar_hihatt = [];
syncperbar_bass_snaret = [];
Fb = [];
Fs = [];
Fh = [];
sb = [];
ss = [];
sh = [];

%midiFiles = dir(strcat(midiDir,'*.mid'));
%for k = 1
for k = 1:length(wavFiles)
    [bassm,snarem,hihatm,bass_snarem,basst,snaret,hihatt,bass_snaret,...
    F_b,F_s,F_h,sync_b,sync_s,sync_h] = get_synco(wavFiles(k).name, midiDir, audioDir, window_size);
    
    syncperbar_bassm = vertcat(syncperbar_bassm,bassm);
    syncperbar_snarem = vertcat(syncperbar_snarem,snarem);
    syncperbar_hihatm = vertcat(syncperbar_hihatm,hihatm);
    syncperbar_bass_snarem = vertcat(syncperbar_bass_snarem,bass_snarem);
    syncperbar_basst = vertcat(syncperbar_basst,basst);
    syncperbar_snaret = vertcat(syncperbar_snaret,snaret);
    syncperbar_hihatt = vertcat(syncperbar_hihatt,hihatt);
    syncperbar_bass_snaret = vertcat(syncperbar_bass_snaret,bass_snaret);
    Fb = vertcat(Fb, F_b);
    Fs = vertcat(Fs, F_s);
    Fh = vertcat(Fh, F_h);
    sb = vertcat(sb, sync_b);
    ss = vertcat(ss, sync_s);
    sh = vertcat(sh, sync_h);
   
end
% length(syncperbar_hihatm)
% figure
% plot(syncperbar_hihatm,syncperbar_hihatt,'*');
% xlabel('Delay time from the actual onset (ms)');
% ylabel('Number of onsets(ms)');
Fb
sb
bass = [mean(sb) mean(syncperbar_bassm) mean(syncperbar_basst)]
snare = [mean(ss) mean(syncperbar_snarem) mean(syncperbar_snaret)]
hihat = [mean(sb) mean(syncperbar_hihatm) mean(syncperbar_hihatt)]
figure
scatter(Fb,sb,'*');
figure
scatter(syncperbar_bassm,syncperbar_basst);

cbd = corrcoef(syncperbar_bassm,syncperbar_basst)
csd = corrcoef(syncperbar_snarem,syncperbar_snaret)
chh = corrcoef(syncperbar_hihatm,syncperbar_hihatt)
%cbsd = corrcoef(syncperbar_bass_snarem,syncperbar_bass_snaret)

%cfb = corrcoef(Fb, sb)
%cfs = corrcoef(Fs, ss)
%cfh = corrcoef(Fh, sh)

%count=hist2d(data,-1:0.1:1,-1:0.1:1); 
%imagesc(count);

end

function [syncperbar_bassm,syncperbar_snarem,syncperbar_hihatm,syncperbar_bass_snarem,...
    syncperbar_basst,syncperbar_snaret,syncperbar_hihatt,syncperbar_bass_snaret,...
    F_b,F_s,F_h,sync_b,sync_s,sync_h] = get_synco(audiofile, midiDir, audioDir, window_size)

midiFile = strcat(strrep(audiofile, '.wav', ''));
midiFile = strcat(strrep(midiFile, '.mid', ''), '.mid');
%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
len = ceil(nmat(end,1))/0.0625;
%nmatm = quantize(readmidi_java(strcat(midiDir,midiFile)),1/16,1/16,1/16);
%nmatt = quantize(readmidi_java(strcat(transDir,transFile)),1/16,1/16,1/16);

% nmat_bass = nmat((nmat(:,4) == 35) | (nmat(:,4) == 36));
% nmat_snare = nmat((nmat(:,4) == 38) | (nmat(:,4) == 40));
% nmat_hihat = nmat((nmat(:,4) == 44) | (nmat(:,4) == 46) ...
%     | (nmat(:,4) == 49) | (nmat(:,4) == 51) ...
%     | (nmat(:,4) == 52) | (nmat(:,4) == 55) ...
%     | (nmat(:,4) == 53) | (nmat(:,4) == 42) ...
%     | (nmat(:,4) == 57) | (nmat(:,4) == 59));
% nmat_bass_snare = nmat((nmat(:,4) == 35) | (nmat(:,4) == 36) ...
%     | (nmat(:,4) == 38) | (nmat(:,4) == 40));
% idx1 = [false;diff(nmat_bass(:,1))<(2*(10^-2))]; 
% nmat_bass(:,idx1) = [];
% idx2 = [false;diff(nmat_snare(:,1))<(2*(10^-2))]; 
% nmat_snare(:,idx2) = [];
% idx3 = [false;diff(nmat_hihat(:,1))<(2*(10^-2))];
% nmat_hihat(:,idx3) = [];

% syncperbar_bassm = compute_synco_midi(nmat_bass,len);
% syncperbar_snarem = compute_synco_midi(nmat_snare,len);
% syncperbar_hihatm = compute_synco_midi(nmat_hihat,len);
% syncperbar_bass_snarem = compute_synco_midi(nmat_bass_snare,len);

drums = nmat;
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
syncperbar_bassm = compute_synco_time(nmat, m_bass,len);
syncperbar_snarem = compute_synco_time(nmat, m_snare,len);
syncperbar_hihatm = compute_synco_time(nmat, m_hihat,len);
syncperbar_bass_snarem = compute_synco_time(nmat, union(m_bass,m_snare),len);

%load transcription
bass = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_bassf.txt'), ' ')';
snare = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_snaref.txt'), ' ')';
hihat = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_hihatf.txt'), ' ')';
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

syncperbar_basst = compute_synco_time(nmat, bass,len);
syncperbar_snaret = compute_synco_time(nmat, snare,len);
syncperbar_hihatt = compute_synco_time(nmat, hihat,len);
syncperbar_bass_snaret = compute_synco_time(nmat, union(bass,snare),len);

if ( length(syncperbar_basst) > length(syncperbar_bassm) ) 
    syncperbar_basst = syncperbar_basst(1:length(syncperbar_bassm));
end
if ( length(syncperbar_snaret) > length(syncperbar_snarem) ) 
    syncperbar_snaret = syncperbar_snaret(1:length(syncperbar_snarem));  
end
if ( length(syncperbar_hihatt) > length(syncperbar_hihatm) ) 
    syncperbar_hihatt = syncperbar_hihatt(1:length(syncperbar_hihatm)); 
end

sync_b = mean(abs(syncperbar_basst-syncperbar_bassm));
sync_s = mean(abs(syncperbar_snaret-syncperbar_snarem));
sync_h = mean(abs(syncperbar_hihatt-syncperbar_hihatm));

[true_positive_b,false_positive_b,false_negative_b] = evaluate_instrument(m_bass, bass, window_size);
[true_positive_s,false_positive_s,false_negative_s] = evaluate_instrument(m_snare, snare, window_size);
[true_positive_h,false_positive_h,false_negative_h] = evaluate_instrument(m_hihat, hihat, window_size);

[F_b,precision_b,recall_b] = evaluate_measures(true_positive_b,false_positive_b,false_negative_b);
[F_s,precision_s,recall_s] = evaluate_measures(true_positive_s,false_positive_s,false_negative_s);
[F_h,precision_h,recall_h] = evaluate_measures(true_positive_h,false_positive_h,false_negative_h);

if (isnan(F_b)) F_b = 0;end
if (isnan(F_s)) F_s = 0;end
if (isnan(F_h)) F_h = 0;end

if ((F_b>0.9) && (sync_b>0)) display(midiFile);end

end

function syncperbar = compute_synco_midi(nmat,len)
allpattern = zeros(1,len);
onesmat = round(nmat(:,1)/0.0625)+1;
allpattern(onesmat) = 1;
usualweights = [0 -4 -3 -4  -2 -4 -3 -4  -1 -4 -3 -4  -2 -4 -3 -3]';
[syncperbar,numEvents,syncall] = INESC_SyncopPattern(allpattern,usualweights,1);
%length(syncperbar)
end

function syncperbar = compute_synco_time(nmat,onsets,len)
allpattern = zeros(1,len);
quantize_step = 15/gettempo(nmat)/4; %quantize step in seconds
onesmat = round(onsets/quantize_step)+1;
allpattern(onesmat) = 1;
usualweights = [0 -4 -3 -4  -2 -4 -3 -4  -1 -4 -3 -4  -2 -4 -3 -3]';
[syncperbar,numEvents,syncall] = INESC_SyncopPattern(allpattern,usualweights,1);
%length(syncperbar)
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

% function [true_positive,false_positive,false_negative,nmatout] = evaluate_instrument(nmat, onset, window_size)
% 
% true_positive = 0;
% false_positive = 0;
% false_negative = 0;
% nmatout = nmat;
% for i = 1:length(onset)    
%     
%     if (size(nmat(:,1))~=0)
%         
%         %detect the closest element from the midi grountruth and remove it
%         %indices = find(abs(midi - onset(i))<window_size,1);
%         indices = find(nmat(:,1) < onset(i),1,'last');        
%         %if indices
%         if ((length(indices)>0) && ((onset(i) - nmat(indices(1),1))<window_size))          
%             %remove the element because it was detected
%             nmat(indices(1),1)=[];
%             true_positive = true_positive + 1;             
%         else
%             false_positive = false_positive + 1;
%             %add event to nmatout
%             nmatout = [nmatout(1:indices(1)-1,:); nmatout(indices(1),:); ...
%                 nmatout(indices(1):end,:)];
%             nmatout 
%             
%         end
%     
%     end
%     
% end
% 
% false_negative = length(nmat(:,1));
% %remove events from nmatout by substracting nmat
% 
% end