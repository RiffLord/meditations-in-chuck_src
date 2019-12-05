/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * lo_drones.ck                                                  *
 * A Teacup Sits On A Table In the Middle of A Plain White Room  *
 *                                                               *
 * Uses & modifies some code from the ChucK                      *
 * examples/stk directory                                        *
 *                                                               *
 * Transmissions                                                 *
 * May 2018                                                      *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 

//  VoicForm UGen array
VoicForm drones[3];
//  Reverb & delay patch
JCRev rev => Echo a => Echo b => Echo c => dac;
.8 => rev.gain;
.2 => rev.mix;

//  VoicForm patch
for (0 => int i; i < drones.cap(); i++) {
    drones[i] => rev;
    (0.5 / drones.cap()) => drones[i].gain;
    1 => drones[i].noteOn;
}
0.02 => drones[0].vibratoGain => drones[1].vibratoGain => drones[2].vibratoGain;

//  Note lengths
0.8::second => dur whole;
(whole / 2) => dur quarter;
(quarter / 2) => dur eighth;
(eighth / 2) => dur sixteenth;

//  Reverb & delay parameters
whole => a.max => b.max => c.max;
quarter => a.delay => b.delay => c.delay;
0.5 => a.mix => b.mix => c.mix;

//  B Iwato scale
[59, 60, 64, 65, 69, 71] @=> int iwato[];

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
    bphon => drones[0].phonemeNum => drones[1].phonemeNum => drones[2].phonemeNum;
    
    // note: Math.randomf() returns value between 0 and 1
    if (Math.randomf() > 0.85) {
        (quarter * Math.random2(1, 4)) => now;
    } else if (Math.randomf() > 0.85) {
        (quarter * Math.random2(1, 4)) => now;
    } else if (Math.randomf() > 0.1) {
        (quarter * Math.random2(1, 4)) => now;
    } else {
        0 => int i;
        4 * Math.random2(1, 4) => int pick;
        0 => int pick_dir;
        0.0 => float pluck;

        for (; i < pick; i++) {
            bphon + 1 * pick_dir => drones[0].phonemeNum => drones[1].phonemeNum => drones[2].phonemeNum;
            Math.random2f(0.4, 0.6) + i * 0.035 => pluck;
            pluck + 0.0 * pick_dir => drones[0].noteOn => drones[1].noteOn => drones[2].noteOn;
            !pick_dir => pick_dir;
            (quarter * Math.random2(1, 4)) => now;
        }
    }
    
    //  The first VoicForm in the array plays a randomly selected
    //  note from the array, down an octave. Logic is then used to select 
    //  specific notes for the other VoicForms to play
    for (0 => int i; i < iwato.size(); i++) {
        iwato[Math.random2(0, iwato.size() - 1)] => int note;
        Std.mtof(note - 12) => drones[0].freq;
        if (note == iwato[0]) {
            Std.mtof(iwato[2] - 12) => drones[1].freq;
            Std.mtof(iwato[4] - 12) => drones[2].freq; 
        } else if (note == iwato[1]) {
            Std.mtof(iwato[2] - 12) => drones[1].freq;
            Std.mtof(iwato[4] - 12) => drones[2].freq; 
        } else if (note == iwato[2]) {
            Std.mtof(iwato[4] - 12) => drones[1].freq;
            Std.mtof(iwato[5] - 12) => drones[2].freq; 
        } else if (note == iwato[3]) {
            Std.mtof(iwato[4] - 12) => drones[1].freq;
            Std.mtof(iwato[5] - 12) => drones[2].freq; 
        } else if (note == iwato[4]) {
            Std.mtof(iwato[5] - 12) => drones[1].freq;
            Std.mtof(iwato[0] - 12) => drones[2].freq; 
        } else if (note == iwato[5]) {
            Std.mtof(iwato[0] - 12) => drones[1].freq;
            Std.mtof(iwato[2] - 12) => drones[2].freq; 
        }
        
        (quarter * Math.random2(1, 16)) => now;            
    }    
}