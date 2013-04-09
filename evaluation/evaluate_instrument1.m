function [true_positive,false_positive,false_negative] = evaluate_instrument1(midi, onset, window_size)

true_positive = 0;
false_positive = 0;
false_negative = 0;

for i = 1:length(onset)    
    onset(i)
    if (size(midi)~=0)
        
        %detect the closest element from the midi grountruth and remove it  
        indices = find(abs(midi-onset(i))<=window_size,1);
        %[min_difference, array_position] = min(abs(midi - onset(i)));
        if indices
            midi(indices(1))=[];
            true_positive = true_positive + 1  
        else
            false_positive = false_positive + 1
        end
    end
    
end
midi
false_negative = length(midi);

end