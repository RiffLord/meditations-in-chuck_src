/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iwato_bar.ck                                                  *
 * A Teacup Sits On A Table In the Middle of A Plain White Room  *
 *                                                               *
 * Transmissions                                                 *
 * May 2018                                                      *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 
 
//  Main patch
ModalBar bar => JCRev rev => dac;
0.8 => rev.gain;
0.2 => rev.mix;

//  Note durations
0.8::second => dur whole;
(whole / 2) => dur quarter;
(quarter / 2) => dur eighth;
(eighth / 2) => dur sixteenth;

//  B Iwato scale
[59, 60, 64, 65, 69, 71] @=> int iwato[];

while (true) {
    //  Loops forward through the iwato array
    for (0 => int i; i < iwato.size(); i++) {
        //  Converts the MIDI value of the iwato scale to a frequency
        //  and assigns it to the Modal Bar
        Std.mtof(iwato[i]) => bar.freq;
        
        //  Chooses a random Modal Bar preset
        Math.random2(0, 8) => bar.preset;
        
        //  Chooses a random note length
        Math.random2(1, 4) => int pauseLength;
        
        //  Plays the note and pauses according to the value of noteLength  
        if (pauseLength == 1) {
            Math.random2f(0.6, 0.8) => bar.noteOn;
            whole => now;
        } else if (pauseLength == 2) {
            Math.random2f(0.6, 0.8) => bar.noteOn;
            quarter => now;
        } else if (pauseLength == 3) {
            Math.random2f(0.6, 0.8) => bar.noteOn;
            eighth => now;
        } else if (pauseLength == 4) {
            Math.random2f(0.6, 0.8) => bar.noteOn;
            sixteenth => now;
        }
    }
}  