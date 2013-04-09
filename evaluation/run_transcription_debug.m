function run_transcription_debug(step)
k=0;
for i=-2:step:1 
    evaluation_matrix = test_transcription_debug('/Users/mmiron/Documents/INESC/drum_transcription/audio_midi_database/midi/','/Users/mmiron/Documents/INESC/drum_transcription/audio_midi_database/audio/',0.060,i,0,i,0,i,0);
    k = k + 1;
    F_b(k) = evaluation_matrix(1,1);
    F_s(k) = evaluation_matrix(2,1);
    F_h(k) = evaluation_matrix(3,1);
end
k=0;
for i=-2:step:1 
    evaluation_matrix = test_transcription_debug('/Users/mmiron/Documents/INESC/drum_transcription/audio_midi_database/midi/','/Users/mmiron/Documents/INESC/drum_transcription/audio_midi_database/audio/',0.060,0,i,0,i,0,i);
    k = k + 1;
    F_bn(k) = evaluation_matrix(1,1);
    F_sn(k) = evaluation_matrix(2,1);
    F_hn(k) = evaluation_matrix(3,1);
end

[C_b,i_b] = max(F_b)
[C_bn,i_bn] = max(F_bn)
[C_s,i_s] = max(F_s)
[C_sn,i_sn] = max(F_sn)
[C_h,i_h] = max(F_h)
[C_hn,i_hn] = max(F_hn)

figure
x = -2:step:1;
h(1) = subplot(1,3,1); 
plot(x,F_b,'Color','r','DisplayName','threshold bass'); hold on;
plot(x,F_bn,'Color','b','DisplayName','threshold non-bass'); hold off;
xlabel('Threshold');
ylabel('F-measure');
legend(gca,'show');
h(2) = subplot(1,3,2); 
plot(x,F_s,'Color','r','DisplayName','threshold snare'); hold on;
plot(x,F_sn,'Color','b','DisplayName','threshold non-snare'); hold off;
xlabel('Threshold');
ylabel('F-measure');
legend(gca,'show');
h(3) = subplot(1,3,3); 
plot(x,F_h,'Color','r','DisplayName','threshold hihat'); hold on;
plot(x,F_hn,'Color','b','DisplayName','threshold non-hihat'); hold off;
xlabel('Threshold');
ylabel('F-measure');
legend(gca,'show');
end