function generate_syncopation_new(midiDir,newDir)

midiFiles = dir(strcat(midiDir,'*.mid'));
%for k = 1
for k = 1:length(midiFiles)    
%for k = 100:100    
%     if (strcmp(wavFiles(k).name,'125FunkRock03b.mid.wav'))
%         k
%     end
    generate_synco(midiFiles(k).name, midiDir, newDir); 
   
end

end

function generate_synco(audiofile, midiDir, newDir)

midiFile = strcat(strrep(audiofile, '.mid', ''));
midioutFile = strrep(midiFile, '.mid', '');
midiFile = strcat(strrep(midiFile, '.mid', ''), '.mid');

%load midi
%nmat = readmidi(midiFile);
nmat = readmidi_java(strcat(midiDir,midiFile));
nmat = quantize(nmat,1/16,1/16,1/16);
tempo = gettempo(nmat);

nmat_bass = nmat((nmat(:,4) == 35) | (nmat(:,4) == 36),:);
nmat_snare = nmat((nmat(:,4) == 38) | (nmat(:,4) == 40),:);
nmat_hihat = nmat((nmat(:,4) == 44) | (nmat(:,4) == 46) ...
    | (nmat(:,4) == 49) | (nmat(:,4) == 51) ...
    | (nmat(:,4) == 52) | (nmat(:,4) == 55) ...
    | (nmat(:,4) == 53) | (nmat(:,4) == 42) ...
    | (nmat(:,4) == 57) | (nmat(:,4) == 59),:);
idx1 = [false;diff(nmat_bass(:,6))<(2*(10^-2))]; 
nmat_bass(idx1,:) = [];
idx2 = [false;diff(nmat_snare(:,6))<(2*(10^-2))]; 
nmat_snare(idx2,:) = [];
idx3 = [false;diff(nmat_hihat(:,6))<(2*(10^-2))];
nmat_hihat(idx3,:) = [];

nmatout = sortrows([nmat_bass;nmat_snare;nmat_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_quantized.mid'),120, tempo,4,4);
%writemidi(nmatout,midioutFile,120, tempo,4,4);

%anticipate events by 1/16
%delay events by 1/16

%1
nmatout_bass = syncopate(nmat_bass, tempo, -2); 
nmatout_snare = syncopate(nmat_snare, tempo, -2); 
nmatout = sortrows([nmatout_bass;nmatout_snare;nmat_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_l_s_a.mid'),120, tempo,4,4);

%2
nmatout_hihat = syncopate(nmat_hihat, tempo, -2); 
nmatout = sortrows([nmat_bass;nmat_snare;nmatout_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_h_s_a.mid'),120, tempo,4,4);

%3
nmatout_bass = syncopate(nmat_bass, tempo, 2); 
nmatout_snare = syncopate(nmat_snare, tempo, 2); 
nmatout = sortrows([nmatout_bass;nmatout_snare;nmat_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_l_s_d.mid'),120, tempo,4,4);

%4
nmatout_hihat = syncopate(nmat_hihat, tempo, 2); 
nmatout = sortrows([nmat_bass;nmat_snare;nmatout_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_h_s_d.mid'),120, tempo,4,4);

%5
nmatout_bass = syncopate(nmat_bass, tempo, -1);
nmatout_snare = syncopate(nmat_snare, tempo, -1); 
nmatout = sortrows([nmatout_bass;nmatout_snare;nmat_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_l_e_a.mid'),120, tempo,4,4);

%6
nmatout_hihat = syncopate(nmat_hihat, tempo, -1);
nmatout = sortrows([nmat_bass;nmat_snare;nmatout_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_h_e_a.mid'),120, tempo,4,4);

%7
nmatout_bass = syncopate(nmat_bass, tempo, 1);
nmatout_snare = syncopate(nmat_snare, tempo, 1); 
nmatout = sortrows([nmatout_bass;nmatout_snare;nmat_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_l_e_d.mid'),120, tempo,4,4);

%8
nmatout_hihat = syncopate(nmat_hihat, tempo, 1); 
nmatout = sortrows([nmat_bass;nmat_snare;nmatout_hihat],1);
writemidi_java(nmatout,strcat(newDir,strcat(midioutFile), '_h_e_d.mid'),120, tempo,4,4);

end

%division positive: delay, negative: anticipate; 1: 8th note, 2: 16th note
function nmatout = syncopate(nmat, tempo, division) 
    nmatstrong = nmat(floor(nmat(:,1))==nmat(:,1),:);
    nmatweak = nmat(floor(nmat(:,1))~=nmat(:,1),:);
    for i = 1:size(nmatweak,1) 
        if ((nmatweak(i,1) - 0.250/division) > floor(nmatweak(i,1)))
            nmatweak(i,1) = nmatweak(i,1) - 0.250/division; 
            nmatweak(i,6) = nmatweak(i,6) - 30/tempo/division; 
        end
    end
    nmatout = sortrows([nmatstrong;nmatweak],1);
end



