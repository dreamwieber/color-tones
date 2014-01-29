//
//  CTMusicHelper.m
//  ColorTones
//
//  Created by Gregory Wieber on 11/14/13.
//  Copyright (c) 2013 Apposite. All rights reserved.
//

// Musical data structures and functions based on the work of Jeff Rose, Sam Aaron & Marius Kempe
// on Overtone

#import "CTMusicHelper.h"
#import <OCTotallyLazy/OCTotallyLazy.h>

@implementation CTMusicHelper

+ (NSDictionary *)notes
{
    return  @{@"C" : @0, @"c" : @0,  @"b#" : @0,  @"B#" : @0,
              @"C#" : @1, @"c#" : @1, @"Db" : @1, @"db" : @1, @"DB" : @1, @"dB" : @1,
              @"D"  : @2, @"d" : @2,
              @"D#" : @3, @"d#" : @3, @"Eb" : @3, @"eb" : @3,  @"EB" : @3,  @"eB" : @3,
              @"E"  : @4, @"e" : @4,
              @"E#" : @5, @"e#" : @5, @"F" : @5, @"f" : @5,
              @"F#" : @6, @"f#" : @6, @"Gb" : @6, @"gb" : @6,  @"GB" : @6, @"gB" : @6,
              @"G"  : @7, @"g" : @7,
              @"G#" : @8, @"g#" : @8, @"Ab" : @8, @"ab" : @8,  @"AB" : @8, @"aB" : @8,
              @"A"  : @9, @"a" : @9,
              @"A#" : @10, @"a#" : @10, @"Bb" : @10, @"bb" : @10, @"BB" : @10, @"bB" : @10,
              @"B"  : @11, @"b" : @11, @"Cb" : @11, @"cb" : @11, @"CB" : @11, @"cB" : @11};
}

///
/// Various scale intervals in terms of steps on a piano, or midi note numbers
/// All sequences should add up to 12 - the number of semitones in an octave
///

+ (NSDictionary *)scales
{
    Sequence *ionianSequence = sequence(@2, @2, @1, @2, @2, @2, @1, nil);
    Sequence *hexSequence = sequence(@2, @2, @1, @2, @2, @3, nil);
    Sequence *pentatonicSequence = sequence(@3, @2, @2, @3, @2, nil);
    
    NSArray *(^rotate)(Sequence *, NSUInteger) = ^NSArray *(Sequence *sequence, NSUInteger offset) {
        int length = [[sequence asArray]count];
        return [[[[sequence cycle ]drop:(int)offset] take:length] asArray];
    };
    
    return @{@"ionian" : [ionianSequence asArray],
             @"diatonic" : [ionianSequence asArray],
             @"major" : [ionianSequence asArray],
             @"dorian" : rotate(ionianSequence, 1),
             @"phrygian" : rotate(ionianSequence, 2),
             @"lydian" : rotate(ionianSequence, 3),
             @"mixolydian" : rotate(ionianSequence, 4),
             @"aeolian" : rotate(ionianSequence, 5),
             @"minor" : rotate(ionianSequence, 5),
             @"locrian" : rotate(ionianSequence, 6),
             @"hexMajor6" : [hexSequence asArray],
             @"hexDorian" : rotate(hexSequence, 1),
             @"hexPhrygian" : rotate(hexSequence, 2),
             @"hexMajor7" : rotate(hexSequence, 3),
             @"hexSus" : rotate(hexSequence, 4),
             @"hexAeolian" : rotate(hexSequence, 5),
             @"minorPentatonic" : [pentatonicSequence asArray],
             @"majorPentatonic" : rotate(pentatonicSequence, 1),
             @"egyptian" : rotate(pentatonicSequence, 2),
             @"jiao" : rotate(pentatonicSequence, 3),
             @"pentatonic" : rotate(pentatonicSequence, 4),
             @"chromatic" : @[@1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1],
             @"wholeTone" : @[@2, @2, @2, @2, @2, @2],
             @"harmonicMinor" : @[@2, @1, @2, @2, @1, @3, @1,],
             @"diminished" : @[@1, @2, @1, @2, @1, @2, @1, @2,],
             @"prometheus" : @[@2, @2, @2, @5, @1],
             @"melodicMinor" : @[@2, @1, @2, @2, @2, @2, @1],
             @"bartok" : @[@2, @2, @1, @2, @1, @2, @2],
             @"spanish" : @[@1, @3, @1, @2, @1, @2, @2],
             @"indian" : @[@4, @1, @2, @3, @2],
             @"hirajoshi" : @[@2, @1, @4, @1, @4],
             @"kumoi" : @[@2, @1, @4, @2, @3]
             };
    
}


+ (NSInteger)noteWithOctave:(NSUInteger)octave andInterval:(NSUInteger)interval
{
    return (octave * 12) + interval + 12;
}

///
/// Takes a note in scientific pitch notation ("C4") and returns
/// a MIDI key value (60)
///

+ (NSInteger)midiKeyFromNote:(NSString *)note
{
    if (note == nil) return -1;
    
    NSScanner *scan = [NSScanner scannerWithString:note];
    NSString *pitch;
    [scan scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&pitch];
    
    // get octave from string
    NSInteger octave;
    [scan scanInteger:&octave];
    
    NSUInteger interval = [[[CTMusicHelper notes] objectForKey:pitch] integerValue];
        
    return [CTMusicHelper noteWithOctave:octave andInterval:interval];
}

+ (NSArray *)midiKeysForScale:(NSString *)scaleName withRoot:(NSString *)rootNote length:(NSUInteger)length
{
    NSInteger root = [CTMusicHelper midiKeyFromNote:rootNote];
    
    NSMutableArray *midiKeys = [NSMutableArray array];
    
    for (int i = 0; i < length; i++) {
        [midiKeys addObject:@(root + [CTMusicHelper nthInterval:i inScale:scaleName])];
    }
    
    return midiKeys;
}

+ (NSInteger)nthInterval:(NSInteger)n inScale:(NSString *)scaleName
{
    if (!scaleName) {
        scaleName = @"diatonic";
    }
    
    NSArray *scale = [CTMusicHelper scales][scaleName];

    Sequence *scaleSequence = [scale asSequence];
    
    NSNumber *nthInterval = [[[scaleSequence cycle]
                              take:(int)n]
                             reduce:^id(id accumulator, id interval) {
        return @([accumulator integerValue] + [interval integerValue]);
    }];
    
    return nthInterval.integerValue;
}

+ (float)frequencyForMidiNote:(NSUInteger)note;
{
    // thanks Fracisco Tufro
    return 440 * pow(2.0,(note-69.0)/12.0);
}

@end
