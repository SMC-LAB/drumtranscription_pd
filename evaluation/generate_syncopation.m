function generate_delay(newDir)

tempo = 120;
duration = 100;

%kicks
generate1(36, duration, newDir, tempo);

%snares
generate1(38, duration, newDir, tempo);

%hihats
generate1(42, duration, newDir, tempo);

%kicks snares
generate2(36, duration, 38, duration, newDir, tempo);

%kicks hihats
generate2(36, duration, 42, duration, newDir, tempo);

%snares kicks
generate2(38, duration, 36, duration, newDir, tempo);

%snares hihats
generate2(38, duration, 42, duration, newDir, tempo);

%hihats kicks
generate2(42, duration, 36, duration, newDir, tempo);

%hihats snares
generate2(42, duration, 38, duration, newDir, tempo);

%kicks snares hihats kicks
generate3(36, duration, 38, duration, 42, duration, newDir, tempo);

%kicks hihats snares kicks
generate3(36, duration, 42, duration, 38, duration, newDir, tempo);

%snares kicks hihats snares
generate3(38, duration, 36, duration, 42, duration, newDir, tempo);

%snares hihats kicks snare
generate3(38, duration, 42, duration, 36, duration, newDir, tempo);

%hihats kicks snares hihats
generate3(42, duration, 36, duration, 38, duration, newDir, tempo);

%hihats snares kicks hihats
generate3(42, duration, 38, duration, 36, duration, newDir, tempo);


end

function generate1(in1, d1, newDir, tempo) 
duration1 = d1/1000;
delays=[120 90 70 50 30 20 10 0 -10 -20 -30 -50 -70 -90];
for i=1:numel(delays)
    delay = delays(i)/1000;
    note1 = [tempo/60*0 tempo/60*duration1 10 in1 100 0 duration1];  
    note2 = [tempo/60*(duration1+delay) tempo/60*duration1 10 in1 100 (duration1+delay) duration1]; 
    note3 = [tempo/60*2*(duration1+delay) tempo/60*duration1 10 in1 100 2*(duration1+delay) duration1]; 
    note4 = [tempo/60*3*(duration1+delay) tempo/60*duration1 10 in1 100 3*(duration1+delay) duration1];
    note5 = [tempo/60*4*(duration1+delay) tempo/60*duration1 10 in1 100 4*(duration1+delay) duration1];
    note6 = [tempo/60*5*(duration1+delay) tempo/60*duration1 10 in1 100 5*(duration1+delay) duration1];
    nmatout = [note1; note2; note3; note4; note5; note6];
    writemidi_java(nmatout,strcat(newDir, int2str(in1), 'd', int2str(delays(i)), '_l', int2str(d1), '.mid'),120, tempo,4,4);
end
end

function generate2(in1, d1, in2, d2, newDir, tempo) 
duration1 = d1/1000;
duration2 = d2/1000;
delays=[120 90 70 50 30 20 10 0 -10 -20 -30 -50 -70 -90];
for i=1:numel(delays)
    delay = delays(i)/1000;
    note1 = [tempo/60*0 tempo/60*duration1 10 in1 100 0 duration1];  
    note2 = [tempo/60*(duration1+delay) tempo/60*duration2 10 in2 100 (duration1+delay) duration2]; 
    note3 = [tempo/60*(duration1+2*delay+duration2) tempo/60*duration1 10 in1 100 (duration1+2*delay+duration2) duration1];
    note4 = [tempo/60*(2*duration1+3*delay+duration2) tempo/60*duration2 10 in2 100 (2*duration1+3*delay+duration2) duration2];
    note5 = [tempo/60*(2*duration1+4*delay+2*duration2) tempo/60*duration1 10 in1 100 (2*duration1+4*delay+2*duration2) duration1];
    note6 = [tempo/60*(3*duration1+5*delay+2*duration2) tempo/60*duration2 10 in2 100 (3*duration1+5*delay+2*duration2) duration2];
    nmatout = [note1; note2; note3; note4; note5; note6];
    writemidi_java(nmatout,strcat(newDir, int2str(in1), '_', int2str(in2), 'd', int2str(delays(i)), '_l', int2str(d1), '.mid'),120, tempo,4,4);
end
end

function generate3(in1, d1, in2, d2, in3, d3, newDir, tempo) 
delays=[120 90 70 50 30 20 10 0 -10 -20 -30 -50 -70 -90];
duration1 = d1/1000;
duration2 = d2/1000;
duration3 = d3/1000;
for i=1:numel(delays)
    delay = delays(i)/1000;
    note1 = [tempo/60*0 tempo/60*duration1 10 in1 100 0 duration1];  
    note2 = [tempo/60*(duration1+delay) tempo/60*duration2 10 in2 100 (duration1+delay) duration2]; 
    note3 = [tempo/60*(duration1+2*delay+duration2) tempo/60*duration3 10 in3 100 (duration1+2*delay+duration2) duration3];
    note4 = [tempo/60*(duration1+3*delay+duration2+duration3) tempo/60*duration1 10 in1 100 (duration1+3*delay+duration2+duration3) duration1];
    note5 = [tempo/60*(2*duration1+4*delay+duration2+duration3) tempo/60*duration2 10 in2 100 (2*duration1+4*delay+duration2+duration3) duration2];
    note6 = [tempo/60*(2*duration1+5*delay+2*duration2+duration3) tempo/60*duration3 10 in3 100 (2*duration1+5*delay+2*duration2+duration3) duration3];
    note7 = [tempo/60*(2*duration1+6*delay+2*duration2+2*duration3) tempo/60*duration1 10 in1 100 (2*duration1+6*delay+2*duration2+2*duration3) duration1];
    note8 = [tempo/60*(3*duration1+7*delay+2*duration2+2*duration3) tempo/60*duration2 10 in2 100 (3*duration1+7*delay+2*duration2+2*duration3) duration2];
    note9 = [tempo/60*(3*duration1+8*delay+3*duration2+2*duration3) tempo/60*duration3 10 in3 100 (3*duration1+8*delay+3*duration2+2*duration3) duration3];
    nmatout = [note1; note2; note3; note4; note5; note6; note7; note8; note9];
    writemidi_java(nmatout,strcat(newDir, int2str(in1), '_', int2str(in2), '_', int2str(in3), 'd', int2str(delays(i)), '_l', int2str(d1),'.mid'),120, tempo,4,4);
end
end




