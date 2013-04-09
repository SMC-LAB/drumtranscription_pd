function evaluation_matrix = test_transcription_values(midiDir,audioDir, window_size)

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
inb = [0.1e-10:0.1e-10:0.49e-9];
ins = [0.1e-10:0.1e-10:0.49e-9];
inh = [0.1e-10:0.1e-10:0.49e-9];

for k = 1:length(wavFiles)   
    
    [detection_matrix,featb,feats,feath]  = get_transcription(wavFiles(k).name, midiDir, audioDir, window_size);
    true_positive_b = true_positive_b + detection_matrix(1,1);
    false_positive_b = false_positive_b + detection_matrix(1,2);
    false_negative_b = false_negative_b + detection_matrix(1,3);
    true_positive_s = true_positive_s + detection_matrix(2,1);
    false_positive_s = false_positive_s + detection_matrix(2,2);
    false_negative_s = false_negative_s + detection_matrix(2,3);
    true_positive_h = true_positive_h + detection_matrix(3,1);
    false_positive_h = false_positive_h + detection_matrix(3,2);
    false_negative_h = false_negative_h + detection_matrix(3,3);
    
    inb = [ inb ; featb];
    ins = [ ins ; feats];
    inh = [ inh ; feath];
    
    %true_positive_o = true_positive_o + detection_matrix(4,1);
    %false_positive_o = false_positive_o + detection_matrix(4,2);
    %false_negative_o = false_negative_o + detection_matrix(4,3);
end

inb = inb(2:end,:);
ins = ins(2:end,:);
inh = inh(2:end,:);
length(inb(:,1))
length(ins(:,1))
length(inh(:,1))
%outb = ICC(3,'single',inb)
%outs = ICC(3,'single',ins)
%outh = ICC(3,'single',inh)
outb = ICC(3,'single',inb)
outs = ICC(3,'single',ins)
outh = ICC(3,'single',inh)

[F_b,precision_b,recall_b] = evaluate_measures(true_positive_b,false_positive_b,false_negative_b);
[F_s,precision_s,recall_s] = evaluate_measures(true_positive_s,false_positive_s,false_negative_s);
[F_h,precision_h,recall_h] = evaluate_measures(true_positive_h,false_positive_h,false_negative_h);
%[F_o,precision_o,recall_o] = evaluate_measures(true_positive_o,false_positive_o,false_negative_o)

[true_positive_b,false_positive_b,false_negative_b];
[true_positive_s,false_positive_s,false_negative_s];
[true_positive_h,false_positive_h,false_negative_h];
%[true_positive_o,false_positive_o,false_negative_o]

evaluation_matrix = vertcat([F_b,precision_b,recall_b],...
    [F_s,precision_s,recall_s],...
    [F_h,precision_h,recall_h]);

end

function [detection_matrix,featb,feats,feath] = get_transcription(audiofile, midiDir, audioDir, window_size)

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
bassd = textread(strcat(audioDir,strrep(audiofile, '.wav', ''),'_bassvf.txt'), '%s', 'delimiter', ' ', 'whitespace', '');
snared = textread(strcat(audioDir,strrep(audiofile, '.wav', ''),'_snarevf.txt'), '%s', 'delimiter', ' ', 'whitespace', '');
hihatd = textread(strcat(audioDir,strrep(audiofile, '.wav', ''),'_hihatvf.txt'), '%s', 'delimiter', ' ', 'whitespace', '');

[bass,featb]=parse_data(bassd);
[snare,feats]=parse_data(snared);
[hihat,feath]=parse_data(hihatd);
%form_data(bassd,strcat(audioDir,strrep(audiofile, '.wav', ''),'_dbass.txt')); 
%form_data(snared,strcat(audioDir,strrep(audiofile, '.wav', ''),'_dsnare.txt')); 
%form_data(hihatd,strcat(audioDir,strrep(audiofile, '.wav', ''),'_dhihat.txt')); 

%csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_mdbass.txt'),m_bass); 
%csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_mdsnare.txt'),m_snare); 
%csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_mdhihat.txt'),m_hihat); 

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


function [onsets,features]=parse_data(data)
onsets = []; features = [0.1e-10:0.1e-10:0.49e-9];
i=0;
for k = 2:length(data) 
    parts = strread(char(data(k))','%s','delimiter','_');
    type = str2num(char(parts(1)));
    time = str2num(char(parts(2)));
    feat = 1e4*str2double(parts(3:end))';
    if (type == 0)
        if (i<1)
            i = i + 1;
            onsets(i) = time;
            features(i,:) = feat;
        else
        if (onset(i) > onset(i-1))
            i = i + 1;
            onsets(i) = time;
            features(i,:) = feat;
        else
            display('gotcha')
            onsets(i-1) = time;
            features(i-1,:) = feat;
        end            
        end
    end
end
if (length(features(:,1)) == 1)  
    features = [];
end

end
