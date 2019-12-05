/* * * * * * * * * * * * * * * * * * * * * * * * *
 *  currents.ck                                  *
 *  On the Currents of An Ocean of Endless Calm  *
 *                                               * 
 *  Inspired by La Monte Young                   *
 *                                               *
 *  Transmissions                                *
 *  January 2018                                 *
 * * * * * * * * * * * * * * * * * * * * * * * * */

//  Master gain to digital-to-analog converter
Gain master => dac; 
0.8 => master.gain;

//  Secondary gain used to control the instruments' volumes
0.0 => float currentGain; 

//  Reverb
NRev rev => master;
0.4 => rev.mix; 

//  Six instruments organized in two arrays:
//  Three Bowed UGens & three sinewave oscillators
Bowed bow[3];
SinOsc sin[3];

//  Pan for each instrument
Pan2 pan1 => dac;
Pan2 pan2 => dac;
Pan2 pan3 => dac;
Pan2 pan4 => dac;
Pan2 pan5 => dac;
Pan2 pan6 => dac;
bow[0] => pan1;
bow[1] => pan2;
bow[2] => pan3;
sin[0] => pan4;
sin[1] => pan5;
sin[2] => pan6;

//  Random panning for each instrument within the specified parameters
pan1.pan(Math.random2f(-1.0, 0.0));
pan2.pan(Math.random2f(-0.5, 0.5));
pan3.pan(Math.random2f(0.0, 1.0));
pan4.pan(Math.random2f(-1.0, 1.0));
pan5.pan(Math.random2f(-1.0, -0.5));
pan6.pan(Math.random2f(0.5, 1.0));

//  MIDI note values array for a B#sus4 chord
[48, 53, 55] @=> int notes[];
//  Global tempo parameter
0.2 => float tempo;

//  Bowed UGens parameter setup & patches
for (0 => int i; i < bow.cap(); i++) {    
    .05 => bow[i].bowPressure;
    1.0 => bow[i].bowPosition;
    .01 => bow[i].vibratoGain;                   
    bow[i] => rev;
    
    //  Converts the MIDI note value to the corresponding frequency
    Std.mtof(notes[i]) => bow[i].freq;     
    1 => bow[i].noteOn;
    
    //  Assigns the current gain to the instrument
    currentGain => bow[i].gain;                    
}

//  Sinewave Oscillator patches
for (0 => int i; i < sin.cap(); i++) {
    sin[i] => rev;
    
    //  The Sinewave assigned to the F note plays it an octave above
    if (i == 1) {
        Std.mtof(notes[i] + 12) => sin[i].freq;
    } else Std.mtof(notes[i]) => sin[i].freq;
    currentGain => sin[i].gain;                 
}

//  Selection parameter used to assign variations in gain and vibrato to an instrument
int select;

//  currentGain increased by 0.001 units per 0.01 seconds and assigned to each instrument
while (currentGain <= 0.20) {
    0.001 +=> currentGain;
    currentGain =>  bow[0].gain => bow[1].gain => bow[2].gain => sin[0].gain => sin[1].gain => sin[2].gain;
    0.01::second => now;
}

5::second => now;

//  Infinite loop, allowing the track to play indefinitely
while (true) {
    //  Random values within the specified parameters assigned to select, pressure & position
    Math.random2(0, 5) => select;
    Math.random2f(0.0, 0.9) => float pressure;
    Math.random2f(0.0, 0.9) => float position;
    
    //  Calls the flux function for different instruments depending on the value of select
    //  If the instrument is a bowed UGen, it also randomizes that instrument's bow pressure,
    //  bow position & vibrato values
    if (select == 0) {
        Math.random2f(1.1, 3.3) => bow[0].vibratoFreq;  
        flux(bow[0], currentGain);
        pressure => bow[0].bowPressure;
        position => bow[0].bowPosition;
    } else if (select == 1) {
        Math.random2f(1.1, 3.3) => bow[1].vibratoFreq;
        flux(bow[1], currentGain);
        pressure => bow[1].bowPressure;
        position => bow[1].bowPosition;
    } else if (select == 2) {
        flux(sin[0], currentGain);
    } else if (select == 3) {
        flux(sin[1], currentGain);
    } else if (select == 4) {
        flux(sin[2], currentGain);
    } else if (select == 5) {
        Math.random2f(1.1, 3.3) => bow[2].vibratoFreq;
        flux(bow[2], currentGain);
        pressure => bow[2].bowPressure;
        position => bow[2].bowPosition;
    }
}

//  Generates fluctuations within the basic drone by decreasing the gain of an instrument to zero
//  and waiting for a certain amount of time before raising it again
fun void flux(UGen osc, float vol) {
    //  Random value between the specified parameters assigned to pause
    Math.random2f(1.0, 5.0) => float pause;
    
    //  Gain lowered to 0
    while (vol >= 0.0) {
        0.001 -=> vol;
        vol => osc.gain;
        0.01::second => now;  
    }
    
    //  Determines the amount of time to pass before the gain is increased
    (0.5 * tempo)::(second * pause) => now;
    
    //  Gain increased to 0.20
    while (vol <= 0.20) {
        0.001 +=> vol;
        vol => osc.gain;
        0.01::second => now;  
    }
    
    //  Determines the amount of time to pass before the function is called again
    (0.5 * tempo)::(second * pause) => now;
}