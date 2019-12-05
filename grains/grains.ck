/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *   grains.ck                                                   *
 *   A Million and One Grains of Sand Forever Falling Upwards    *
 *                                                               *
 *   Uses the granularize function                               *
 *   from listing 5.9 of Programming For Musicians               *
 *   and Digital Artists (Kapur, Cook, Salazar, Wang, 2015),     *
 *   p.102                                                       *
 *                                                               *
 *   Transmissions                                               *
 *   January 2018                                                *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

//  Main patch
NRev nrev => SndBuf2 click => JCRev rev => Gain master => dac;
0.5 => master.gain;
0.8 => nrev.gain;
0.1 => nrev.mix;
0.8 => rev.gain;
0.1 => rev.mix;

Delay del[3];
click => del[0] => dac.left;
click => del[1] => dac;
click => del[2] => dac.right;
//  Delay parameters
for (0 => int i; i < 3; i++) {
    del[i] => del[i];
    0.3 => del[i].gain;
    (0.3 + i * 0.5)::second => del[i].max => del[i].delay;
}

//  Opens the file to granularize
me.dir() + "/Riley.wav" => click.read;

fun void granularize(SndBuf myWav, int steps) {
    //  Creates a number of grains
    myWav.samples() / steps => int grain;
    
    //  Selects a random position of the file to play
    Math.random2(0, myWav.samples() - grain) + grain => myWav.pos;
    
    //  Advances time by the length of a grain
    grain::samp => now;
}

while (true) {
    granularize(click, 45);
}