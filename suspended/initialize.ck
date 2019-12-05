/* * * * * * * * * * * * * * * 
 *  initialize.ck            *
 *  Suspended In Mid-Air     *
 *                           *
 *  Transmissions            *
 *  February 2018            *
 * * * * * * * * * * * * * * */

//  Stores the filepaths for each individual ChucK file
//  used to create the track
me.dir() + "/chords.ck" => string chordPath;
me.dir() + "/melody.ck" => string melodyPath;
me.dir() + "/arpeggio.ck" => string arpPath;

//  Adds and executes the files in 
//  the specified order to create the track structure
Machine.add(chordPath) => int chordID;
30::second => now;
Machine.replace(chordID, melodyPath) => int melodyID;
30::second => now;
Machine.add(arpPath)=> int arpID;
1::minute => now;
Machine.replace(melodyID, chordPath) => chordID;
1::minute => now;
Machine.replace(chordID, melodyPath) => melodyID;
1::minute => now;
Machine.replace(melodyID, chordPath);