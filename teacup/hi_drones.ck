/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * hi_drones.ck                                                 *
 * A Teacup Sits On A Table In the Middle of A Plain White Room  *
 *                                                               *
 * Uses & modifies some code from the ChucK                      *
 * examples/stk directory                                        *
 *                                                               *
 * Transmissions                                                 *
 * May 2018                                                      *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 

//  Main patch
VoicForm vox => Pan2 voxPan => JCRev rev => Echo a => Echo b => Echo c => dac;
0.0 => float voxGain;
0.02 => vox.vibratoGain;
0.25 => vox.loudness;
0.8 => rev.gain;
0.2 => rev.mix;

//  Note durations
0.8::second => dur whole;
(whole / 2) => dur quarter;
(quarter / 2) => dur eighth;
(eighth / 2) => dur sixteenth;

//  Iwato scale array
[59, 60, 64, 65, 69, 71] @=> int iwato[];
iwato.cap() - 1 => int scaleSize;

//  Echo settings
whole => a.max => b.max => c.max;
quarter => a.delay => b.delay => c.delay;
0.50 => a.mix => b.mix => c.mix;

// shred to modulate the mix
fun void modulate() {
    0.0 => float decider;
    0.0 => float mix;
    0.0 => float old;
    0.0 => float inc;
    0 => int n;

    // time loop
    while (true) {
        Math.random2f(0.0, 1.0) => decider;
        if (decider < .3) 0.0 => mix;
        else if (decider < .6) .08 => mix;
        else if (decider < .8) .5 => mix;
        else .15 => mix;

        // find the increment
        (mix - old) / 1000.0 => inc;
        1000 => n;
        while (n--) {
            old + inc => old;
            old => a.mix => b.mix => c.mix;
            1::ms => now;
        }
        mix => old;
        Math.random2(2, 6)::second => now;
    }
}

// let echo shred go
spork ~ modulate();

while (1) {
    2 * Math.random2(0, 2) => int bphon;
    bphon => vox.phonemeNum;
    melody();
    
    // note: Math.randomf() returns value between 0 and 1
    if (Math.randomf() > 0.85) {
        (quarter * Math.random2(1, 4)) => now;
    } else if (Math.randomf() > .85) {
        (quarter * Math.random2(1, 4)) => now;
    } else if (Math.randomf() > .1) {
        (quarter * Math.random2(1, 4)) => now;
    } else {
        0 => int i;
        4 * Math.random2(1, 4) => int pick;
        0 => int pick_dir;
        0.0 => float pluck;

        for (; i < pick; i++) {
            bphon + 1 * pick_dir => vox.phonemeNum;
            Math.random2f(.4, .6) + i * .035 => pluck;
            pluck + 0.0 * pick_dir => vox.noteOn;
            !pick_dir => pick_dir;
            (quarter * Math.random2(1, 4)) => now;
        }
    }  
}

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

//  Plays randomized musical phrases
fun void melody() {    
    while (true) {
        //  Randomly assigned pause parameter determines whether to end the phrase or not
        Math.random2(0, 1) => int pause;
        Math.random2f(-0.9, 0.9) => voxPan.pan;       
        Math.random2(3, scaleSize) => int phrase;
        
        for (0 => int i; i <= phrase; i++) {
            iwato[Math.random2(0, scaleSize)] => int note;
            Std.mtof(note) => vox.freq;
            1 => vox.noteOn;
            
            if (note == scaleSize) {
                Std.mtof(iwato[scaleSize - 1]) => vox.freq;
            } else if (note == scaleSize - 1) {
                Std.mtof(iwato[note - 2]) => vox.freq;
            } else if (note <= scaleSize - 2) {
                Std.mtof(iwato[note + 1]) => vox.freq;
                Std.mtof(iwato[note + 2]) => vox.freq;
            }
            
            while (voxGain <= 0.2) {
                0.001 +=> voxGain;
                voxGain => vox.gain;
                0.01::second => now;
            }
            noteLength();
        }
        
        (Math.random2(0, 4) * 0.4)::second => now;
        
        if (pause == 1) {
            resolve();
            while (voxGain >= 0.0) {
                0.001 -=> voxGain;
                voxGain => vox.gain;
                0.01::second => now;
            }
            1 => vox.noteOff;
            (whole * Math.random2(1, 16)) => now;
        }
    }
}

fun void resolve() {
    noteLength();
    
    //  Randomly assigned resolution parameter determines
    //  whether to resolve the phrase on the first or last
    //  note of the scale    
    Math.random2(0, 1) => int resolution;
    
    if (resolution == 0) {
        Std.mtof(iwato[2]) => vox.freq;
        1 => vox.noteOn;
        noteLength();
        1 => vox.noteOff;
        Std.mtof(iwato[1]) => vox.freq;
        1 => vox.noteOn;
        noteLength();
        1 => vox.noteOff;
        Std.mtof(iwato[0]) => vox.freq;
        1 => vox.noteOn;
        noteLength();
        1 => vox.noteOff;
    } else {
        Std.mtof(iwato[scaleSize - 2]) => vox.freq;
        1 => vox.noteOn;
        noteLength();
        1 => vox.noteOff;
        Std.mtof(iwato[scaleSize - 1]) => vox.freq;
        1 => vox.noteOn;
        noteLength();
        1 => vox.noteOff;
        Std.mtof(iwato[scaleSize]) => vox.freq;
        1 => vox.noteOn;
        noteLength();
        1 => vox.noteOff;
    }
}    