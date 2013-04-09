function detection_matrix = get_transcription1(midiFile, audiofile, midiDir, audioDir, window_size)

%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
drums = nmat(nmat(:,3) == 10,:);
drums = nmat;
m_bass = drums(((drums(:,4) == 35) | (drums(:,4) == 36)), 6);
m_snare = drums((drums(:,4) == 38) | (drums(:,4) == 40), 6);
m_hihat = drums((drums(:,4) == 44) | (drums(:,4) == 46) ...
    | (drums(:,4) == 49) | (drums(:,4) == 51) ...
    | (drums(:,4) == 52) | (drums(:,4) == 55) ...
    | (drums(:,4) == 53) | (drums(:,4) == 42) ...
    | (drums(:,4) == 57) | (drums(:,4) == 59), 6);
drumhits=[35,36,38,40,42,44,46,49,51,52,53,55,57,59];
m_onset = unique(drums(:,6))

%load transcription
bass = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_bass.txt'), ' ');
snare = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_snare.txt'), ' ');
hihat = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_hihat.txt'), ' ');
onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_onset.txt'), ' ');

[true_positive_b,false_positive_b,true_negative_b,false_negative_b] = evaluate_instrument1(m_bass, bass', window_size);
[true_positive_s,false_positive_s,true_negative_s,false_negative_s] = evaluate_instrument1(m_snare, snare', window_size);
[true_positive_h,false_positive_h,true_negative_h,false_negative_h] = evaluate_instrument1(m_hihat, hihat', window_size);
[true_positive_o,false_positive_o,true_negative_o,false_negative_o] = evaluate_instrument1(m_onset, onset', window_size)

detection_matrix = vertcat([true_positive_b,false_positive_b,true_negative_b,false_negative_b],...
    [true_positive_s,false_positive_s,true_negative_s,false_negative_s],...
    [true_positive_h,false_positive_h,true_negative_h,false_negative_h],...
    [true_positive_o,false_positive_o,true_negative_o,false_negative_o]);

end

function [true_positive,false_positive,true_negative,false_negative] = evaluate_instrument1(midi, onset, window_size)

true_positive = 0;
true_negative = 0;
false_positive = 0;
false_negative = 0;

for i = 1:size(onset)    
    
    if (size(midi)~=0)
        
        %detect the closest element from the midi grountruth and remove it  
        indices = find(abs(midi-onset(i))<window_size,1);
        %[min_difference, array_position] = min(abs(midi - onset(i)));
        if indices
            midi(indices(1))=[];
            true_positive = true_positive + 1;  
        else
            false_positive = false_positive + 1;
        end
    
    end
    
end

false_negative = size(midi,1);
true_negative = abs(size(onset,2) - true_positive);

end