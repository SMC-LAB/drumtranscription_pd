function test_onsets_values(audioDir)


wavFiles = dir(strcat(audioDir,'*.wav'));

for k = 1:length(wavFiles)
    get_transcription(wavFiles(k).name, audioDir);
end


end

function get_transcription(audiofile, audioDir)


%load transcription
onset = importdata(strcat(audioDir,strrep(audiofile, '.wav', ''),'_values.txt'), ' ');

%for i = 1:length(onsets)
%    onset_times(i) = i *1024/ (44100 * 512);
%end


csvwrite(strcat(audioDir,strrep(audiofile, '.wav', ''),'_valuesv.txt'),onset'); 


end
