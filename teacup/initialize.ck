/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  initialize.ck                                                  *
 *  A Teacup Sits On A Table In the Middle of A Plain White Room   *
 *                                                                 *
 *  Transmissions                                                  *
 *  May 2018                                                       *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

//  Stores the filepaths for each individual ChucK file
//  used to create the track
me.dir() + "/iwato_bar.ck" => string bar_path;
me.dir() + "/lo_drones.ck" => string drone_path;
me.dir() + "/vox_drones.ck" => string mel_path;

//  Creates the track structure by executing
//  the files when specified
Machine.add(bar_path);
30::second => now;
Machine.add(drone_path) => int droneID;
60::second => now;
Machine.add(drone_path) => droneID;
Machine.add(mel_path);