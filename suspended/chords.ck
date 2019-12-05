/* * * * * * * * * * * * * * * * * * * * * * *
 *  chords.ck                                *
 *  Suspended In Mid-Air                     *
 *                                           *
 *  Uses and modifies some code contained    *
 *  in the ChucK examples/stk directory      *
 *                                           *
 *  Transmissions                            *
 *  February 2018                            *
 * * * * * * * * * * * * * * * * * * * * * * */

//  Note durations
1::second => dur whole;
(whole / 2) => dur quarter;
(quarter / 2) => dur eighth;
(eighth / 2) => dur sixteenth;

//  Reverb & Echo patch & parameter setup
JCRev r => Echo a => Echo b => Echo c => dac;
0.8 => r.gain;
0.2 => r.mix;
whole => a.max => b.max => c.max;
eighth => a.delay => b.delay => c.delay;
0.5 => a.mix => b.mix => c.mix;

//  Moog UGen patch
Moog moog[4];
moog[0] => dac.left;
moog[1] => dac;
moog[2] => dac;
moog[3] => dac.right;

//  G Major 7/#11 Chord
[67, 78, 83, 85] @=> int chord[];

//  Moog setup
for (0 => int i; i < chord.cap(); i++) {
    moog[i] => r;
    Std.mtof(chord[i] - 12) => moog[i].freq;
    0.3 => moog[i].gain;
}

while (1) {    
    playChord();
}

fun void playChord() {
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