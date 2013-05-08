drumtranscription_pd
=================================================================
An open-source streaming drum transcription system for Pure Data
=================================================================

We implemented an audio drum transcription algorithm in Pure Data (PD), which can transcribe kick, snare, and hi-hat from live drum performances. The software takes live audio or files as input and triggers events for each drum type as output.

The  Pure Data patches and the source code for some of the Pure Data externals are distributed under GPL license.


==========================================
QUICK START
==========================================

In order to use this application, you will need to have the visual programming environment Pd-extended installed. The software is free and can be downloaded from: http://puredata.info/downloads/pd-extended . We recommend using the latest version.

You can start using the software right away by loading the DEMO patches. The demos transcribe audio and offer simultaneous audio feedback if the resynthesis button is checked. Midi notes representing transcribed kick, snare or hi-hat can be sent to desired channels.  However, if you have some very basic Pure Data knowledge, you can adapt the patches to your needs by modifying them.

The algorithm sends quasi-real-time bang messages for each new kick, snare and hi-hat event. 

The application is modular and provides separate patches for different versions. You can build your own drum transcription system. For instance, you can opt for a more reliable transcription for kick and snare, and for a faster, more real-time transcription for hi-hats. Please see the DETAILED DESCRIPTION for more info.


======================================
WHO CAN USE THIS SOFTWARE?
======================================

This software can be used by musicians, visual artists, and researchers. Musicians can control their music performance using the live transcription from the drums. Artists can generate visuals based on the drum events. Scientists can reproduce and compare any part of the research. Furthermore, they can use this system in designing better systems for machine listening or music interaction.

Some Pure Data knowledge is required if you plan to make serious modifications to the patches.


======================================
TROUBLESHOOTING
======================================

The error messages are displayed in the Pure Data window. The most common errors are related to external patches missing, to using PD Vanilla instead of PD-extended, or using a very old version of Pure Data.

If you receive the "not found" error in the message window, then make sure that you are using the version which corresponds to your operating system, and that you are using the PD-extended.  


====================================
DETAILED DESCRIPTION
====================================

The research behind this system is documented in an ICASSP 2013 paper:
http://www.icassp2013.com/Papers/ViewPapers.asp?PaperNum=4116

The algorithm comprises three different stages: onset detection, feature computation and classification. We implemented patches several versions for each of the stages.
- onset detection - you can use a faster onset detector or the slower one with better resolution
- you can use the faster feature computation which takes just the first 56 ms, or you can use the "best" patch which overlaps 10 frames summing 136 ms of analysis
- you can choose between a trained KNN classifier or a sequential K-means classifier

In the src directory you can find the C source code for the Pure Data externals. 

The overlapping sounds database can be downloaded from: 
http://www.mediafire.com/download.php?q8nl199bnz7g68n
OR
https://www.dropbox.com/s/6ykurx3lr9s0lj5/overlapping_sounds_db.zip

This work is supported by the ERDF – European Regional Development Fund through the COMPETE Programme (operational programme for competitiveness) and by National Funds through the FCT – Fundacao para a Ciencia e a Tecnologia (Portuguese Foundation for Science and Technology) within project Shake-it, Grant PTDC/EAT-MMU/ 112255/2009. Part of this research was supported by the CASA project with reference PTDC/EIA-CCO/111050/2009 (FCT), and by the MAT project funded by ON.2.


=============================
RESEARCH REPRODUCIBILITY 
=============================

Part of the research is reproducible. We are using a drum loops generated with samples from Groove Monkee library, which can't be made available because of license restrictions. However we made available the overlapping sounds database.

1. First you need to download the overlapping sounds database: 
http://www.mediafire.com/download.php?q8nl199bnz7g68n
OR
https://www.dropbox.com/s/6ykurx3lr9s0lj5/overlapping_sounds_db.zip

2. Provided that you have Pure Data extended installed and you downloaded the binary for drum transcription, you can use the test_rt_batch.pd from command line to transcribe each audio file from the database. 
a) You need to copy the .wav files to be transcribed in the `audio_to_transcribe` folder, or modify this path in the batch_file.pd
b) You would need to call Pure Data from command line and use the batch option:
/Applications/Pd-extended.app/Contents/Resources/bin/pdextended -batch /path-to-drum-transcription/test_rt_batch.pd
Modify the /path-to-drum-transcription/ to the actual path where you have downloaded the software.
c) The transcription will generate text files with the drum onset times, for each of the kick, snare or hi-hat. 

3. In the `evaluation` folder you find the Matlab scripts to compare the transcription with the midi ground truth.
a) test_transcription.m [test_transcription(midiDir,audioDir, window_size)] takes as input the midi folder and the audio folder, as well as the desired maximum delay from the actual onset (window_size). This script will give you the F-measure, precision and recall across all classes. 
b) test_delay.m [test_delay(midiDir,audioDir, window_size)] will plot the F_measure across the overlapping intervals, so you would see how the system performs depending of the overlapping rate between two consecutive events.

=============================
PURE DATA DEVELOPERS
=============================
You can modify the patches as you want under the GPL license. The demos take audio as input and trigger bangs for kick, snare or hi-hat. 

You can use the modular architecture to choose between different versions of onset detection (best or fast), feature computation(best or fast), or classification (k-means or knn). 

Feel free to use the k-means classifier(onlineClusterKNN) to build systems that can classify data without prior training. 

If you want to use the knn classifier from the timbre-id library, then you can re-train it by calling the train_rt_batch_best.pd or train_rt_batch_fast.pd from the command line: 
/Applications/Pd-extended.app/Contents/Resources/bin/pdextended -batch /path-to-drum-transcription/train_rt_batch_best.pd

Modify the /path-to-drum-transcription/ to the actual path where you have downloaded the software. First you need to copy the drum sounds in the corresponding directories for the kick, snare, hi-hat and toms in the `audio_to_retrain` directory. 

=============================
DSP DEVELOPERS
=============================

If you plan to re-compile again the externals you would need to download the Pure Data framework and add the m_pd.h to the respective projects. We didn't include the m_pd.h in the actual source code, because we want to encourage people to use the latest Pure Data framework and source code. 

More info on how to write and compile an external can be found here: http://pdstatic.iem.at/externals-HOWTO/


=============================
FUTURE WORK
=============================

We plan to implement an external which will take a buffer of audio samples and will separate the sound in two streams: harmonic and percussive. In this way, we can transcribe drums from polyphonic audio, and not only from audio comprising solely drum sounds. 


=============================
HELP
=============================

For any questions email miron.marius [at] gmail [dot] com .