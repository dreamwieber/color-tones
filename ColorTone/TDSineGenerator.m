//
//  TDSineGenerator.m
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "TDSineGenerator.h"

@implementation TDSineGenerator

+ (instancetype)generatorWithFrequency:(float)frequency
                             amplitude:(float)amplitude
{
    TDSineGenerator *sineGen = [TDSineGenerator new];
    
    if (sineGen) {
        sineGen.frequency = frequency;
        sineGen.amplitude = amplitude;
        [sineGen createProcessBlock];
    }
    return sineGen;
}


- (void)createProcessBlock
{
    
    __weak TDSineGenerator *weakSelf = self;
    
    __block float angle = 0;
    
    self.processBlock = ^(const AudioTimeStamp *time, UInt32 frames, float *audio) {
        
        TDSineGenerator *strongSelf = weakSelf;
        
        if (time->mSampleTime <= strongSelf->_lastRenderTime) {
            memcpy(audio, strongSelf->_scratchBuffer, sizeof(float) * frames);
            return;
        }
        
        float increment = ((M_PI * 2) / 44100.f) * strongSelf->_frequency;
        
        for (int i = 0; i < frames; i++) {
            strongSelf->_scratchBuffer[i] = sinf(angle) * strongSelf->_amplitude;
            angle+=increment;
            if (angle > (M_PI * 2)) {
                angle-= (M_PI * 2);
            }
            
            audio[i]+= strongSelf->_scratchBuffer[i];
        }
        
        
        strongSelf->_lastRenderTime = time->mSampleTime;
        
    };
}

@end
