/* * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  arpeggio.ck                                        *
 *  Suspended In Mid-Air                               *
 *                                                     *
 *  Arpeggiates the chord with a Rhodey UGen           *
 *                                                     *
 *  Transmissions                                      *
 *  February 2018                                      *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * */

//  Main patch
Rhodey rhodes => JCRev r => Echo a => Echo b => Echo c => dac;
0.7 => rhodes.gain;
0.8 => r.gain;
0.2 => r.mix;
1000::ms => a.max => b.max => c.max;
250::ms => a.delay => b.delay => c.delay;
0.5 => a.mix => b.mix => c.mix;

//  G Major 7/#11 Chord
[67, 78, 83, 85] @=> int chord[];

while (true) arpeggio();

//  Plays the notes of the chord in ascending and descending order
fun void arpeggio() {
    for (0 => int i; i < chord.cap(); i++) {
        Std.mtof(chord[i] - 12) => rhodes.freq;
        1 => rhodes.noteOn;
        500::ms => now;
        1 => rhodes.noteOff;
    }
    
    for ((chord.cap() - 1) => int i; i >= 0; i--) {
        Std.mtof(chord[i] - 12) => rhodes.freq;
        1 => rhodes.noteOn;
        500::ms => now;
        1 => rhodes.noteOff;
    }
}