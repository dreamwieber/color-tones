//
//  TDSine.h
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine.h>

#define TD_SCRATCH_BUFFER_SIZE 4096

// operates on audio in-place, shaping the amplitude
typedef void (^TDGeneratorBlock)(const AudioTimeStamp *time, UInt32 numFrames, float *audio);

@interface TDGenerator : NSObject {
    @public
    TDGeneratorBlock _processBlock;
    float _scratchBuffer[TD_SCRATCH_BUFFER_SIZE];
    Float64 _lastRenderTime;
    float _amplitude;
}

@property (nonatomic, readwrite) float amplitude;
@property (nonatomic, copy) TDGeneratorBlock processBlock;

@end
