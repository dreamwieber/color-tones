//
//  ADSR.h
//  ShapedNoise
//
//  Created by Gregory Wieber on 1/25/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine.h>
// operates on audio in-place, shaping the amplitude
typedef void (^ADSRBlock)(const AudioTimeStamp *time, UInt32 numFrames, float *audio);

@interface ADSR : NSObject {
    @public
    ADSRBlock _processBlock;
    BOOL _gateOpen;
}

// all times assume a sample rate of 44100
@property (nonatomic, readwrite) NSTimeInterval attackT;
@property (nonatomic, readwrite) NSTimeInterval decayT;
@property (nonatomic, readwrite) float sustain;
@property (nonatomic, readwrite) NSTimeInterval releaseT;

@property (nonatomic, readwrite) BOOL gateOpen; // i.e., user is holding a key down

// this block performs the main function of the ADSR, shaping the audio in-place
@property (nonatomic, copy) ADSRBlock processBlock;

+ (instancetype)ADSRWithAttack:(NSTimeInterval)attack
                                decay:(NSTimeInterval)decay
                              sustain:(float)sustain
                       release:(NSTimeInterval)release;

@end
