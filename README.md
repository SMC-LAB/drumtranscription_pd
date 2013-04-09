drumtranscription_pd
====================

An open-source streaming drum transcription system for Pure Data

We implemented in Pure Data (PD) an audio drum transcription algorithm, which can transcribe live audio from drum performances or drum loops. You can use the already existing DEMOS, but if you can also build your own system by choosing different versions of the patches.

The research behind this system is documented in an ICASSP 2013 paper:
http://www.icassp2013.com/Papers/ViewPapers.asp?PaperNum=4116

The algorithm comprises three different stages: onset detection, feature computation and classification. We implemented patches several versions for each of the stages.
- onset detection - you can use a faster onset detector or the slower one with better resolution
- you can use the faster feature computation which takes just the first 56 ms, or you can use the "best" patch which overlaps 10 frames summing 136 ms of analysis
- you can choose between a trained KNN classifier or a sequential K-means classifier



The overlapping sounds database can be downloaded from: 
http://www.mediafire.com/download.php?q8nl199bnz7g68n
OR
https://www.dropbox.com/s/6ykurx3lr9s0lj5/overlapping_sounds_db.zip