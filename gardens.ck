/* * * * * * * * * * * * * * * * * * * * *
 *  gardens.ck                           *
 *  Towards Gardens of Everlasting Bliss *
 *                                       *
 *  Inspired by the music of Terry Riley *
 *                                       * 
 *  Builds upon listing 6.15 of          *
 *  Programming for Musicians and        *
 *  Digital Artists: Creating Music with *
 *  ChucK (Kapur, Cook, Salazar,         *
 *  Wang, 2015), p.137                   *
 *                                       *
 *  Transmissions                        *
 *  January 2018                         *
 * * * * * * * * * * * * * * * * * * * * */

//  Main Patches
ModalBar bar => Pan2 barPan => Gain master => dac;
BeeThree organ => Pan2 organPan => Gain slave => dac;
Moog moog => Pan2 moogPan => slave;

//  Volumes
0.5 => bar.gain;
0.0 => float moogGain;
0.0 => float organGain;
0.9 => slave.gain;
0.8 => master.gain;

//  Delays for the Modal Bar
Delay del[3];
master => del[0] => dac.left;
master => del[1] => dac;
master => del[2] => dac.right;

//  Delay parameters
for (0 => int i; i < 3; i++) {
    del[i] => del[i];
    0.4 => del[i].gain;
    (0.8 + i * 0.5)::second => del[i].max => del[i].delay;
}

//  MIDI values array used by the ModalBar and Moog UGens
[60, 64, 65, 67, 70, 72] @=> int notes[];
//  C Major scale array used by the BeeThree UGen
[60, 62, 64, 65, 67, 69, 70, 72] @=> int cMajor[];
//  Array sizes
notes.cap() - 1 => int numNotes;
cMajor.cap() - 1 => int scaleSize;

//  Note durations
0.8::second => dur whole;
(whole / 2) => dur quarter;
(quarter / 2) => dur eighth;
(eighth / 2) => dur sixteenth;

//  The functions are called and coordinated through concurrency
//  First child shred, playing rhythmic ModalBar hits
spork ~ barHits();

30::second => now;

 //  Second child shred, playing random sustained tones with the Moog UGen
spork ~ harmonize();

60::second => now;

//  Final child shred, playing randomized organ phrases
spork ~ melody();

//  Parent shred, simply advances time while the various shred generate music
while (1) whole => now;

//  Chooses a random Modal Bar preset
//  and plays a random quarter note from the notes array
fun void barHits() {
    while (true) {
        Math.random2(0, 8) => bar.preset;
        Math.random2f(-0.9, 0.9) => barPan.pan;
        Std.mtof(notes[Math.random2(0, numNotes)]) => bar.freq;
        1 => bar.noteOn;    
        quarter => now;
    }
}

//  Plays random extended notes from the notes array with the Bowed UGen
//  gradually increasing and decreasing the gain
fun void harmonize() {
    while (true) {
        Math.random2f(-0.9, 0.9) => moogPan.pan;
        Math.random2f(0, 1) => moog.filterQ;
        Math.random2f(0, 1) => moog.filterSweepRate;
        Math.random2f(0, 1) => moog.lfoSpeed;
        Math.random2f(0, 0.0125) => moog.lfoDepth;
        
        //  Random note
        notes[Math.random2(0, numNotes)] => int note;
        Std.mtof(note) => moog.freq;    
        1 => moog.noteOn;
        
        //  Gradual volume swell
        while (moogGain <= 0.30) {        
            0.001 +=> moogGain;
            moogGain => moog.gain;
            0.01::second => now;
        }
        
        //  Sustain time for the note
        (whole * Math.random2(1, 16)) => now;
        
        //  Gradual downward volume swell
        while (moogGain >= 0.0) {        
            0.001 -=> moogGain;
            moogGain => moog.gain;
            0.01::second => now;
        }
    }    
}
    
//  Randomly chooses note length
fun void noteLength() {
    Math.random2(0, 3) => int l;    
    if (l == 0) {
        whole => now;
    } else if (l == 1) {
        quarter => now;
    } else if (l == 2) {
        eighth => now;
    } else if (l == 3) {
        sixteenth => now;
    }
}  

//  Plays randomized musical phrases with the BeeThree organ UGen
fun void melody() {    
    while (true) {
        //  Used to determine whether to end the phrase or not
        Math.random2(0, 1) => int pause;
        
        //   Random panning
        Math.random2f(-0.9, 0.9) => organPan.pan;

        //  Number of notes to compose the phrase from
        Math.random2(3, scaleSize * 4) => int phrase;
        
        //  Plays the phrase according to the established parameters
        for (0 => int i; i <= phrase; i++) {
            cMajor[Math.random2(0, scaleSize)] => int note;
            Std.mtof(note) => organ.freq;
            1 => organ.noteOn;
            
            if (note == scaleSize) {
                Std.mtof(cMajor[scaleSize - 1]) => organ.freq;
            } else if (note == scaleSize - 1) {
                Std.mtof(cMajor[note - 2]) => organ.freq;
            } else if (note <= scaleSize - 2) {
                Std.mtof(cMajor[note + 1]) => organ.freq;
                Std.mtof(cMajor[note + 2]) => organ.freq;
            }
            
            while (organGain <= 0.16) {
                0.001 +=> organGain;
                organGain => organ.gain;
                0.01::second => now;
            }
            noteLength();
        }
        
        (Math.random2(0, 4) * 0.4)::second => now;
        
        //  Ends the phrase on the high or low C
        if (pause == 1) {
            resolve();
            while (organGain >= 0.0) {
                0.001 -=> organGain;
                organGain => organ.gain;
                0.01::second => now;
            }
            1 => organ.noteOff;
            (whole * Math.random2(1, 16)) => now;
        }
    }
}

//  Plays the high or low C depending on the
//  note currently played by the organ UGen
fun void resolve() {
    noteLength();    
    if (organ.freq() >= Std.mtof(cMajor.cap() / 2)) {
        Std.mtof(cMajor[2]) => organ.freq;
        1 => organ.noteOn;
        noteLength();
        Std.mtof(cMajor[1]) => organ.freq;
        noteLength();
        Std.mtof(cMajor[0]) => organ.freq;
        noteLength();
        1 => organ.noteOff;
    } else {
        Std.mtof(cMajor[scaleSize - 2]) => organ.freq;
        1 => organ.noteOn;
        noteLength();
        Std.mtof(cMajor[scaleSize - 1]) => organ.freq;
        noteLength();
        Std.mtof(cMajor[scaleSize]) => organ.freq;
        noteLength();
        1 => organ.noteOff;
    }
}    