function add_silence_start(midiDirIn,midiDirOut)

midiFiles = dir(strcat(midiDirIn,'*.mid'));
for k = 1:length(midiFiles)
    nmat = readmidi_java(strcat(midiDirIn,midiFiles(k).name));
    nm = shift(nmat,'onset',2); 
    writemidi_java(nm,strcat(midiDirOut,midiFiles(k).name));
end

end