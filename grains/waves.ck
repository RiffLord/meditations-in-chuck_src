//  Granularizer

NRev nrev => SndBuf2 click => JCRev rev => Gain master => dac;

.8 => master.gain;
.8 => nrev.gain;
.1 => nrev.mix;
.8 => rev.gain;
.1 => rev.mix;

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

"C:/Users/Bruno/Desktop/Transmissions/Sea Copy.wav" => click.read;

fun void granularize(SndBuf myWav, int steps) {
    myWav.samples() / steps => int grain;
    Math.random2(0, myWav.samples() - grain) + grain => myWav.pos;
    grain::samp => now;
}

//  Main

while (true) {
    granularize(click, 150);
}