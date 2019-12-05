/* * * * * * * * * * * * * * * *  
 *  line.ck                    *
 *  Following A Straight Line  *
 *  inspired by La Monte Young *
 *  Transmissions              *
 *  January 2018               *
 * * * * * * * * * * * * * * * */

Gain master => dac;
0.5 => master.gain;

//  Patch for the underlying tone
SinOsc vibrato => SinOsc straightLine => ResonZ rez => Dyno gate => master;
2 => straightLine.sync;
0.2 => straightLine.gain;
4.0 => vibrato.freq;
450.0 => rez.freq;
25 => rez.Q;
gate.limit();

//  Moog UGen patch
Moog moog => gate => Pan2 pan => master;
moog => Delay del => Gain feedback => del;
del => master;
0.7 => moog.gain;
0.8 => float tempo;

//  Delay parameters
tempo::second => del.max;
tempo::second => del.delay;
0.2 => feedback.gain;

//  A Dorian Mode
[71, 72, 74, 76, 78, 79, 81] @=> int aDorian[];

//  Plays a sustained A note
Std.mtof(69) => straightLine.freq;      
0.1 => straightLine.gain;
20::second => now;

while (true) {
    followIt();
    second => now;
}

fun void followIt() {
    //  Randomizes the note to play, the sustain, the panning
    //  and the Moog UGen methods
    Math.random2(0, aDorian.cap() - 1) => int note;
    Math.random2f(0.125, 1.0) => float sustain;
    Math.random2f(-0.9, 0.9) => pan.pan;
    Math.random2f(0, 1) => moog.filterQ;
    Math.random2f(0, 1) => moog.filterSweepRate;
    Math.random2f(0, 1) => moog.lfoSpeed;
    Math.random2f(0, 0.0125) => moog.lfoDepth;
    
    //  Plays a melody
    Std.mtof(aDorian[note]) => moog.freq;
    1 => moog.noteOn;
    (Math.random2f(0.25, 1.0) * sustain)::second => now;
    if (note == aDorian.cap() - 1) {
       Std.mtof(aDorian[note - 2]) => moog.freq;
        1 => moog.noteOn;
       (Math.random2f(0.25, 0.50) * sustain)::second => now;
        1 => moog.noteOff;
    } else if (note == aDorian.cap() - 2) {
        Std.mtof(aDorian[note - 3]) => moog.freq;
        1 => moog.noteOn;
        (Math.random2f(0.25, 0.50) * sustain)::second => now;
        1 => moog.noteOff;
    } else {
        Std.mtof(aDorian[note + 1]) => moog.freq;
        1 => moog.noteOn;
        (Math.random2f(0.25, 1.0) * sustain)::second => now;
        Std.mtof(aDorian[note + 2]) => moog.freq;
        1 => moog.noteOn;
        (Math.random2f(0.25, 1.0) * sustain)::second => now;
        1 => moog.noteOff;
    }
    (Math.random2f(0.25, 0.50) * sustain)::second => now;
    followIt();
}