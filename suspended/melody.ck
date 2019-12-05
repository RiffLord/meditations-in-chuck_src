/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  melody.ck                                                  *
 *  Suspended In Mid-Air                                       *
 *                                                             *
 *  Plays chords in the same way as in chords.ck               *
 *  adding a Moog UGen to play melodies as well                *
 *                                                             *
 *  Transmissions                                              *
 *  February 2018                                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

//  G Major 7/#11 Chord
[67, 78, 83, 85] @=> int chord[];
//  A Mixolydian mode
[57, 59, 61, 62, 64, 66, 67, 69] @=> int mixolydian[];
mixolydian.cap() - 1 => int scaleSize;

//  Note durations
1::second => dur whole;
(whole / 2) => dur quarter;
(quarter / 2) => dur eighth;
(eighth / 2) => dur sixteenth;

//  Main patch
JCRev r => Echo a => Echo b => Echo c => dac;
0.8 => r.gain;
0.2 => r.mix;
whole => a.max => b.max => c.max;
eighth => a.delay => b.delay => c.delay;
0.5 => a.mix => b.mix => c.mix;

//  Patches for the instruments
Moog bass => Pan2 pan => r => dac;
0.6 => bass.gain;

Moog moog[4];
moog[0] => dac.left;
moog[1] => dac;
moog[2] => dac;
moog[3] => dac.right;

for (0 => int i; i < chord.cap(); i++) {
    moog[i] => r;
    Std.mtof(chord[i] - 12) => moog[i].freq;
    0.3 => moog[i].gain;
}

//  Chord & melody functions executed in separate shreds
spork ~ playChord();
spork ~ play(mixolydian);

//  Main loop
while (1) second => now;
    
//  Randomly chooses the length for a particular note to be played
fun void noteLength() {
    Math.random2(0, 3) => int l;    
    if (l == 0) {
        (2 * whole) => now;
    } else if (l == 1) {
        (2 * quarter) => now;
    } else if (l == 2) {
        (2 * eighth) => now;
    } else if (l == 3) {
        (2 * sixteenth) => now;
    }
}

fun void playChord() {
    while (true) {
        //  Randomization of the Moog UGen parameters
        for (0 => int i; i < moog.size() - 1; i++) {
            Math.random2f(0, 1) => moog[i].filterQ;
            Math.random2f(0, 1) => moog[i].filterSweepRate;
            Math.random2f(0, 1) => moog[i].lfoSpeed;
            Math.random2f(0, 0.0125) => moog[i].lfoDepth;
        }
        
        1 => moog[0].noteOn;
        1 => moog[1].noteOn;
        1 => moog[2].noteOn;
        1 => moog[3].noteOn;
        (Math.random2(1, 4) * whole) => now;
        1 => moog[0].noteOff;
        1 => moog[1].noteOff;
        1 => moog[2].noteOff;
        1 => moog[3].noteOff;
    }
}

fun void resolve(int scale[]) {
    noteLength();
    
    if (bass.freq() <= scale.cap() / 2) {
        Std.mtof(scale[2]) => bass.freq;
        1 => bass.noteOn;
        noteLength();
        Std.mtof(scale[1]) => bass.freq;
        noteLength();
        Std.mtof(scale[0]) => bass.freq;
        noteLength();
        1 => bass.noteOff;
    } else {
        Std.mtof(scale[scaleSize - 2]) => bass.freq;
        1 => bass.noteOn;
        noteLength();
        Std.mtof(scale[scaleSize - 1]) => bass.freq;
        noteLength();
        Std.mtof(scale[scaleSize]) => bass.freq;
        noteLength();
        1 => bass.noteOff;
    }  
}  

fun void play(int scale[]) {    
    while (true) {
        //  Randomization of the Moog UGen parameters
        Math.random2f(0, 1) => bass.filterQ;
        Math.random2f(0, 1) => bass.filterSweepRate;
        Math.random2f(0, 1) => bass.lfoSpeed;
        Math.random2f(0, 0.0125) => bass.lfoDepth;
        
        //  Determines whether to end the phrase or not depending on the value assigned
        Math.random2(0, 1) => int pause;
        Math.random2f(-0.9, 0.9) => pan.pan;
        //  Amount of notes to play in the phrase
        Math.random2(3, scaleSize * 2) => int phrase;
        
        //  Selects a note from the scale to play
        Math.random2(0, scale.cap() - 1) => int note;   
        
        //  Plays the selected note an octave down
        Std.mtof(scale[note] - 12) => bass.freq;
        1 => bass.noteOn;
        noteLength();

        if (pause == 1) {
            resolve(scale);
            1 => bass.noteOff;
            noteLength();
        }
    }
}