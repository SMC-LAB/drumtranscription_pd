function test_syncopation_new(midiDir,midisyncoDir,audioDir, window_size)

[syncperbar_bassm_quantized,syncperbar_snarem_quantized,syncperbar_bass_snarem_quantized,syncperbar_hihatm_quantized,...
    Fb_quantized,Fs_quantized,Fbs_quantized,Fh_quantized,tracks_quantized,bars_quantized] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'quantized');

[syncperbar_bassm_l_s_a,syncperbar_snarem_l_s_a,syncperbar_bass_snarem_l_s_a,syncperbar_hihatm_l_s_a,...
    Fb_l_s_a,Fs_l_s_a,Fbs_l_s_a,Fh_l_s_a,tracks_l_s_a,bars_l_s_a] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'l_s_a');

[syncperbar_bassm_h_s_a,syncperbar_snarem_h_s_a,syncperbar_bass_snarem_h_s_a,syncperbar_hihatm_h_s_a,...
    Fb_h_s_a,Fs_h_s_a,Fbs_h_s_a,Fh_h_s_a,tracks_h_s_a,bars_h_s_a] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'h_s_a');

[syncperbar_bassm_l_s_d,syncperbar_snarem_l_s_d,syncperbar_bass_snarem_l_s_d,syncperbar_hihatm_l_s_d,...
    Fb_l_s_d,Fs_l_s_d,Fbs_l_s_d,Fh_l_s_d,tracks_l_s_d,bars_l_s_d] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'l_s_d');

[syncperbar_bassm_h_s_d,syncperbar_snarem_h_s_d,syncperbar_bass_snarem_h_s_d,syncperbar_hihatm_h_s_d,...
    Fb_h_s_d,Fs_h_s_d,Fbs_h_s_d,Fh_h_s_d,tracks_h_s_d,bars_h_s_d] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'h_s_d');

[syncperbar_bassm_l_e_a.mid,syncperbar_snarem_l_e_a.mid,syncperbar_bass_snarem_l_e_a.mid,syncperbar_hihatm_l_e_a.mid,...
    Fb_l_e_a,Fs_l_e_a,Fbs_l_e_a,Fh_l_e_a,tracks_l_e_a,bars_l_e_a] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'l_e_a');

[syncperbar_bassm_h_e_a,syncperbar_snarem_h_e_a,syncperbar_bass_snarem_h_e_a,syncperbar_hihatm_h_e_a,...
    Fb_h_e_a,Fs_h_e_a,Fbs_h_e_a,Fh_h_e_a,tracks_h_e_a,bars_h_e_a] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'h_e_a');

[syncperbar_bassm_l_e_d,syncperbar_snarem_l_e_d,syncperbar_bass_snarem_l_e_d,syncperbar_hihatm_l_e_d,...
    Fb_l_e_d,Fs_l_e_d,Fbs_l_e_d,Fh_l_e_d,tracks_l_e_d,bars_l_e_d] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'l_e_d');

[syncperbar_bassm_h_e_d,syncperbar_snarem_h_e_d,syncperbar_bass_snarem_h_e_d,syncperbar_hihatm_h_e_d,...
    Fb_h_e_d,Fs_h_e_d,Fbs_h_e_d,Fh_h_e_d,tracks_h_e_d,bars_h_e_d] = syncopation(midiDir,midisyncoDir,audioDir, window_size, 'h_e_d');

figure
subplot(2,2,1)
scatter(Fb_quantized,Fb_l_s_a);
subplot(2,2,2)
scatter(Fs_quantized,Fs_l_s_a);
subplot(2,2,3)
scatter(Fbs_quantized,Fbs_l_s_a);
subplot(2,2,4)
scatter(Fh_quantized,Fh_l_s_a);

keyboard

end

function [syncperbar_bassm,syncperbar_snarem,syncperbar_bass_snarem,syncperbar_hihatm,...
    Fb,Fs,Fbs,Fh,tracks,bars] = syncopation(midiDir,midisyncoDir,audioDir, window_size, sufix)

midiFiles = dir(strcat(midiDir,'*.mid'));
syncperbar_bassm = [];
maxsyncperbar_bassm = [];
syncperbar_snarem = [];
maxsyncperbar_snarem = [];
syncperbar_hihatm = [];
syncperbar_bass_snarem = [];
syncperbar_basst = [];
maxsyncperbar_basst = [];
syncperbar_snaret = [];
maxsyncperbar_snaret = [];
syncperbar_hihatt = [];
syncperbar_bass_snaret = [];
Fb = [];
maxFb = [];
Fs = [];
Fh = [];
Fbs = [];
tracks = [];
bars =[];


for k = 1:length(midiFiles)   
    file = strcat(strrep(midiFiles(k).name, '.mid', '_'),sufix);
    [bassm,snarem,hihatm,bass_snarem,basst,snaret,hihatt,bass_snaret,...
    F_b,F_s,F_h,F_bs] = get_synco(file,midisyncoDir, audioDir, window_size);
    
    syncperbar_bassm = [syncperbar_bassm bassm];
    syncperbar_snarem = [syncperbar_snarem snarem];
    syncperbar_hihatm = [syncperbar_hihatm hihatm];
    syncperbar_bass_snarem = [syncperbar_bass_snarem bass_snarem];
    syncperbar_basst = [syncperbar_basst basst];
    syncperbar_snaret = [syncperbar_snaret snaret];
    syncperbar_hihatt = [syncperbar_hihatt hihatt];
    syncperbar_bass_snaret = [syncperbar_bass_snaret bass_snaret];
    Fb = [Fb F_b];
    Fs = [Fs F_s];
    Fh = [Fh F_h];
    Fbs = [Fbs F_bs];
    
    tr=[];
    for i = 1:length(F_b) tr(i)=k; end
    tracks = [tracks tr];
    br=[1:1:length(F_b)];
    bars=[bars br];
    
    [maxs, imax] = max(bassm);
    maxsyncperbar_bassm = [maxsyncperbar_bassm maxs(1)];
    maxFb = [maxFb F_b(imax(1))];
    maxsyncperbar_basst = [maxsyncperbar_basst basst(imax(1))];
   
   
end

end

function [sync_m_b,sync_m_s,sync_m_h,sync_m_bs,sync_t_b,sync_t_s,sync_t_h,sync_t_bs,...
    F_b,F_s,F_h,F_bs] = get_synco(midfile, midiDir, audioDir, window_size)

midiFile = strcat(midfile, '.mid');
midioutFile = strcat(midfile, '_out.mid');
%midiFile = strcat(strrep(midiFile, '.mid', ''), '.mid');
%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
tempo = gettempo(nmat);

%nmatm = quantize(readmidi_java(strcat(midiDir,midiFile)),1/16,1/16,1/16);
%nmatt = quantize(readmidi_java(strcat(transDir,transFile)),1/16,1/16,1/16);
nmat_bass = nmat((nmat(:,4) == 35) | (nmat(:,4) == 36),:);
nmat_snare = nmat((nmat(:,4) == 38) | (nmat(:,4) == 40),:);
nmat_hihat = nmat((nmat(:,4) == 44) | (nmat(:,4) == 46) ...
    | (nmat(:,4) == 49) | (nmat(:,4) == 51) ...
    | (nmat(:,4) == 52) | (nmat(:,4) == 55) ...
    | (nmat(:,4) == 53) | (nmat(:,4) == 42) ...
    | (nmat(:,4) == 57) | (nmat(:,4) == 59),:);
nmat_bass_snare = nmat((nmat(:,4) == 35) | (nmat(:,4) == 36) ...
    | (nmat(:,4) == 38) | (nmat(:,4) == 40),:);
idx1 = [false;diff(nmat_bass(:,6))<(2*(10^-2))]; 
nmat_bass(idx1,:) = [];
idx2 = [false;diff(nmat_snare(:,6))<(2*(10^-2))]; 
nmat_snare(idx2,:) = [];
idx3 = [false;diff(nmat_hihat(:,6))<(2*(10^-2))];
nmat_hihat(idx3,:) = [];


%load transcription
bass = importdata(strcat(audioDir,midiFile,'_bassf.txt'), ' ')';
snare = importdata(strcat(audioDir,midiFile,'_snaref.txt'), ' ')';
hihat = importdata(strcat(audioDir,midiFile,'_hihatf.txt'), ' ')';
idx12 = [false;diff(bass)<(5*(10^-3))]; 
bass(idx12) = [];
idx22 = [false;diff(snare)<(5*(10^-3))]; 
snare(idx22) = [];
idx32 = [false;diff(hihat)<(3*(10^-3))]; 
hihat(idx32) = [];
basssnare = union(bass,snare);
idx12 = [false;diff(basssnare)<(5*(10^-3))]; 
basssnare(idx12) = [];

if (numel(bass)>2) 
    while (bass(1)>bass(2)) bass = bass(2:end);end 
end
if (numel(snare)>2) 
    while (snare(1)>snare(2)) snare = snare(2:end);end 
end
if (numel(hihat)>2) 
    while (hihat(1)>hihat(2)) hihat = hihat(2:end);end 
end
if (numel(basssnare)>2) 
    while (basssnare(1)>basssnare(2)) basssnare = basssnare(2:end);end 
end



[F_b,p_b,r_b,sync_m_b,sync_t_b,bass_nm] = evaluate_instrument(nmat_bass, bass, window_size, tempo, 36);
[F_s,p_s,r_s,sync_m_s,sync_t_s,snare_nm] = evaluate_instrument(nmat_snare, snare, window_size, tempo, 38);
[F_h,p_h,r_h,sync_m_h,sync_t_h,hihat_nm] = evaluate_instrument(nmat_hihat, hihat, window_size, tempo, 42);
[F_bs,p_bs,r_bs,sync_m_bs,sync_t_bs,snarebass_nm] = evaluate_instrument(nmat_bass_snare, basssnare, window_size, tempo, 36);

nmatout = sortrows([bass_nm;snare_nm;hihat_nm],1);
writemidi_java(nmatout,strcat(midiDir,midioutFile),120, tempo,4,4);
%writemidi(nmatout,midioutFile,120, tempo,4,4);

if (strcmp(midiFile,'132Funky01.mid'))
    nmat_bass
    bass
    nmat_snare
    snare
    F_b
end

end

function [F,precision,recall,sync_m,sync_t,nmatout] = evaluate_instrument(nmat, onset, window_size, tempo, ch)
%this needs to happen per bar rather than for the entire midi file
%also compute the f measure per bar 
%also generate the midi file for the transcription
nmatout = [];
if (size(nmat(:,6))~=0)
vel = mean(nmat(:,5));
%for each bar
for k = 1:floor(nmat(end,1)/4)+1 %4 beats/quarter notes per bar
    true_positive(k) = 0;
    false_positive(k) = 0;
    false_negative(k) = 0;
    F(k)=0;precision(k)=0;recall(k)=0;
    nmat_m = nmat((nmat(:,1) >= (k-1)*4) & (nmat(:,1) < k*4),:);
    nmat_t = zeros(1,7);    
    sync_t(k)=0;
    if (size(nmat_m(:,6))~=0)
        %compute syncopation for this bar
        sync_m(k)=compute_synco_midi(nmat_m,16,k);
        
        %filter the transcription just for this bar
        %time_span = nmat(((nmat_m(:,6)>=4*(k-1)*60/tempo) & (nmat_m(:,6)<4*k*60/tempo)),6);
        %onset_t = onset((onset>(time_span(1)-window_size)) & (onset<(time_span(end)+window_size)))        
        onset_t = onset((onset>=(4*(k-1)*60/tempo)) & (onset<(4*k*60/tempo+window_size)));
        duration = min(nmat(:,2));
        for i = 1:length(onset_t)   
            indices = find(nmat_m(:,6) < onset_t(i),1,'last');   
            if ((length(indices)>0) && ((onset_t(i) - nmat_m(indices(1),6))<window_size))          
                %add element to new vector and remove it from namt because it was detected
                if (nmat_t(1,4)==0) nmat_t = nmat_m(indices(1),:);
                else nmat_t = [nmat_t;nmat_m(indices(1),:)]; end
                nmat_m(indices(1),:)=[];
                true_positive(k) = true_positive(k) + 1;             
            else
                %add element(false positive) to new vector
                note = [tempo/60*onset_t(i) 0.12 10 ch vel onset_t(i) 15/tempo/2];                
                if (nmat_t(1,4)==0) nmat_t = note;
                else nmat_t = [nmat_t;note]; end
                false_positive(k) = false_positive(k) + 1;
            end
            onset = onset(find(onset~=onset_t(i)));
        end        
        false_negative(k) = length(nmat_m(:,1));
        nmat_m = nmat((nmat(:,1) >= (k-1)*4) & (nmat(:,1) < k*4),:);       
                
    else %the midi for this bar is empty but we might have false positives in the transcription
        nmat_m = zeros(1,7);
        nmat_t = zeros(1,7);
        true_positive(k) = 0;
        false_negative(k) = 0;
        false_positive(k) = 0;
        %syncopation is zero because the bar is empty for the midi
        sync_m(k)=0;
        onset_t = onset((onset>=(4*(k-1)*60/tempo)) & (onset<(4*k*60/tempo+window_size)));
        for i = 1:length(onset_t) 
            note = [tempo/60*onset_t(i) 0.12 10 ch 80 onset_t(i) 15/tempo/2];  
            if (nmat_t(1,4)==0) nmat_t = note;
            else nmat_t = [nmat_t;note]; end
            false_positive(k) = false_positive(k) + 1;
        end
    end
    
    %compute syncopation for the transcription of this bar
    if (nmat_t(1,4)~=0)
       sync_t(k)=compute_synco_midi(nmat_t,16,k);     
    end
    
    %update the transcription nmat
    if (nmat_t(1,4)~=0) nmatout = [nmatout;nmat_t]; end
    
    %compute the f measure for this bar
    [F(k),precision(k),recall(k)] = evaluate_measures(true_positive(k),false_positive(k),false_negative(k));    
    if ((true_positive(k)==0) && (false_positive(k)==0) && (false_negative(k)==0))
        F(k)=1;precision(k)=1;recall(k)=1;
    else 
        if ((true_positive(k)==0) && (false_positive(k)~=0))
            F(k)=0;precision(k)=0;
        else
            if ((true_positive(k)==0) && (false_negative(k)~=0))
                F(k)=0;recall(k)=0;
            end
        end
    end
    
    %reset the matrices
    nmat_m = [];
    nmat_t = [];
end
else %empty midi but we might have false positives
    display('empty');
     nmat_m = zeros(1,7);
     nmat_t = zeros(1,7);
     for i = 1:floor(tempo/4*60*onset(length(onset))) 
         F(i)=1;precision(i)=1;recall(i)=1;
         %syncopation is zero, we assume the transcription is also empty
         sync_m(i)=0;
         sync_t(i)=0;
     end
     for i = 1:length(onset) 
         k = floor(tempo/4*60*onset(i));
         note = [tempo/60*onset(i) 0.12 10 ch vel onset(i) 15/tempo/2];  
         if (nmat_t(1,4)==0) nmat_t = note;
         else nmat_t = [nmat_t;note]; end                     
     end     
     
     if (length(onset)>0)
         F(k)=0;precision(k)=0;recall(k)=0;  
         %onset
        %compute syncopation for the not empty transcription bars
        len = ceil(nmat_t(end,1))/0.0625
        sync_t = compute_synco_midi(nmat_t,len,1);
        %keyboard
        nmatout = nmat_t;
     else nmatout = [];
     end
     
end
end

function syncperbar = compute_synco_midi(nmat,len,bar)
nmat(:,1) = nmat(:,1) - (bar-1)*4; 
allpattern = zeros(1,len);
onesmat = round(nmat(:,1)*4)+1;
allpattern(onesmat) = 1;
usualweights = [0 -4 -3 -4  -2 -4 -3 -4  -1 -4 -3 -4  -2 -4 -3 -3]';
[syncperbar,numEvents,syncall] = INESC_SyncopPattern(allpattern,usualweights,1);
end

function [F,precision,recall] = evaluate_measures(true_positive,false_positive,false_negative)
%accuracy = ( true_positive + true_negative ) / ( true_positive + true_negative + false_positive + false_negative );
precision = true_positive / ( true_positive + false_positive );
recall = true_positive / ( true_positive + false_negative );
F = 2 * precision * recall / ( precision + recall );
end

function plotFS(F,s,n)
figure
subplot(2,2,1)
scatter(F,s,'*');
xlabel('F-measure')
ylabel('syncopation error')
%# our data
X = F;
Y = s;
%# bin centers (integers)
xi = linspace(floor(min(X)),ceil(max(X)),n);
yi = linspace(floor(min(Y)),ceil(max(Y)),n);

%# map X/Y values to bin indices
xr = interp1(xi, 1:numel(xi), X, 'nearest') ;
yr = interp1(yi, 1:numel(yi), Y, 'nearest') ;

%# limit indices to the range [1,numBins]
xr = max( min(xr,n), 1);
yr = max( min(yr,n), 1);

%# count number of elements in each bin
H = accumarray([yr(:) xr(:)], 1, [n n]);
subplot(2,2,2)
surf(H)
%axis([0 1 0 0.6]);
xlabel('F-measure')
ylabel('syncopation error')
[N,c] = hist(F,10);
subplot(2,2,3)
bar(c,N);
xlabel('F-measure,larger-better')
[M,d] = hist(s,8);
subplot(2,2,4)
bar(d,M);
xlabel('syncopation error,smaller-better')

mf(1) = mean(F( (s>=0) & (s<=(d(2)/2)) ));
sf(1) = std(F( (s<=(d(2)/2)) ));
lf(1) = length(F( (s<=(d(2)/2)) )) ;
for i = 2:length(d)-1 
    mf(i) = mean(F( (s>=(d(i-1)+(d(i)-d(i-1))/2)) & (s<=(d(i)+(d(i+1)-d(i))/2)) ));
    sf(i) = std(F( (s>=(d(i-1)+(d(i)-d(i-1))/2)) & (s<=(d(i)+(d(i+1)-d(i))/2)) ));
    lf(i) = length(F( (s>=(d(i-1)+(d(i)-d(i-1))/2)) & (s<=(d(i)+(d(i+1)-d(i))/2)) )) ;
end
mf(length(d)) = mean(F( (s>=(d(length(d)-1)+(d(length(d))-d(length(d)-1))/2))  ));
sf(length(d)) = std(F( (s>=(d(length(d)-1)+(d(length(d))-d(length(d)-1))/2))  ));
lf(length(d)) = length(F( (s>=(d(length(d)-1)+(d(length(d))-d(length(d)-1))/2))  )) ;
[d;lf;mf;sf]
waf = sum(d.*lf)/sum(lf)

% ms(1) = mean(s( (F>=0) & (F<=(c(2)/2)) ));
% ss(1) = std(s( (F<=(c(2)/2)) ));
% ls(1) = length(s( (F<=(c(2)/2)) )) ;
% for i = 2:length(c)-1 
%     ms(i) = mean(s( (F>=(c(i-1)+(c(i)-c(i-1))/2)) & (F<=(c(i)+(c(i+1)-c(i))/2)) ));
%     ss(i) = std(s( (F>=(c(i-1)+(c(i)-c(i-1))/2)) & (F<=(c(i)+(c(i+1)-c(i))/2)) ));
%     ls(i) = length(s( (F>=(c(i-1)+(c(i)-c(i-1))/2)) & (F<=(c(i)+(c(i+1)-c(i))/2)) )) ;
% end
% ms(length(c)) = mean(s( (F>=(c(length(c)-1)+(c(length(c))-c(length(c)-1))/2))  ));
% ss(length(c)) = std(s( (F>=(c(length(c)-1)+(c(length(c))-c(length(c)-1))/2))  ));
% ls(length(c)) = length(s( (F>=(c(length(c)-1)+(c(length(c))-c(length(c)-1))/2))  )) ;
% [c;ls;ms;ss]

end

function [ms_m,mF_m,ms_t,mF_t]=syncopation_rank(syncperbar_m,syncperbar_t,s,F,tracks,bars,wavFiles,first)
[Y,I] = sort(syncperbar_m,2,'descend');
im = I;
tracks_o_m = tracks(I);
bars_o_m = bars(I);
wavFiles(tracks_o_m(1:first)).name
bars_o_m(1:first)
ms_m = mean(s(I(1:first)))
mF_m = mean(F(I(1:first)))

[Y,I] = sort(syncperbar_t,2,'descend');
it = I;
tracks_o_t = tracks(I);
bars_o_t = bars(I);
wavFiles(tracks_o_t(1:first)).name
bars_o_t(1:first)
ms_t = mean(s(I(1:first)))
mF_t = mean(F(I(1:first)))

corrcoef(im,it)
figure
scatter(im,it);

end

function [ms_m,mF_m,ms_t,mF_t]=maxsyncopation_rank(syncperbar_m,syncperbar_t,s,F,wavFiles,first)
[Y,I] = sort(syncperbar_m,2,'descend');
im = I;
wavFiles(I(1:first)).name
F(I(1:first))
ms_m = mean(s(I(1:first)))
mF_m = mean(F(I(1:first)))

[Y,I] = sort(syncperbar_t,2,'descend');
it = I;
wavFiles(I(1:first)).name
ms_t = mean(s(I(1:first)))
mF_t = mean(F(I(1:first)))

corrcoef(im,it)
figure
subplot(1,2,1)
scatter(im,it);
subplot(1,2,2)
scatter3(im,it,F);

end

