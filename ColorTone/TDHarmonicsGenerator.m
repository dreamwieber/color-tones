//
//  TDHarmonicsGenerator.m
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "TDHarmonicsGenerator.h"

@interface TDHarmonicsGenerator () {
    @public
    TDSineGenerator *_harmonicGenerators[TD_MAX_HARMONICS];
    float _frequencies[TD_MAX_HARMONICS];
    float _amplitudes[TD_MAX_HARMONICS];
    NSUInteger _nHarmonics;
}

@end

@implementation TDHarmonicsGenerator

+ (instancetype)harmonicsGeneratorWithBaseFrequency:(float)baseFreq
                                ratioAmplitudePairs:(NSArray *)ratioAmpPairs
{
 
    TDHarmonicsGenerator *harmGen = [TDHarmonicsGenerator new];
    harmGen.baseFrequency = baseFreq;
    harmGen->_lastRenderTime = 0;
    bzero(harmGen->_scratchBuffer, sizeof(float) * TD_SCRATCH_BUFFER_SIZE);
    
    // create a series of sine wave generators
    for (int i = 0; i < TD_MAX_HARMONICS; i++) {
        TDSineGenerator *sineGen = [TDSineGenerator generatorWithFrequency:0 amplitude:0];
        sineGen->_lastRenderTime = DBL_MAX; // makes generator inactive by default
        harmGen->_harmonicGenerators[i] = sineGen;
    }

    harmGen.ratioAmpPairs = ratioAmpPairs;
   
    [harmGen setupProcessBlock];
    
    return harmGen;
}

- (void)setupProcessBlock
{
    __weak TDHarmonicsGenerator *weakSelf = self;
    
    self.processBlock = ^(const AudioTimeStamp *time, UInt32 frames, float *audio) {
        
        TDHarmonicsGenerator *strongSelf = weakSelf;
        
        if (time->mSampleTime <= strongSelf->_lastRenderTime) {
            memcpy(audio, strongSelf->_scratchBuffer, sizeof(float) * frames);
            return;
        }
        
        bzero(strongSelf->_scratchBuffer, sizeof(float) * TD_SCRATCH_BUFFER_SIZE);
        
        
        for (int i = 0; i < strongSelf->_nHarmonics; i++) {
            TDSineGenerator *sineGen = strongSelf->_harmonicGenerators[i];
            sineGen->_processBlock(time, frames, strongSelf->_scratchBuffer);
        }
        
        memcpy(audio, strongSelf->_scratchBuffer, sizeof(float) * frames);
        strongSelf->_lastRenderTime = time->mSampleTime;
    };
    
}

- (void)setRatioAmpPairs:(NSArray *)ratioAmpPairs
{
    _ratioAmpPairs = ratioAmpPairs;
    
    if (!self->_harmonicGenerators[0]) return;
    
    // intialize the base generator
    self->_harmonicGenerators[0].frequency = self.baseFrequency;
    self->_harmonicGenerators[0].amplitude = 1.0;
    self->_harmonicGenerators[0]->_lastRenderTime = 0.0;
    
    self->_nHarmonics = ratioAmpPairs.count + 1;
    // initialize the harmonic generators
    // these are ratios of the base frequency, with varying amplitudes
    // ratioAmpPairs is an array of {ratio => amplitude} pairs
    int index = 0;
    for (NSDictionary *ratioPair in ratioAmpPairs) {
        if (index >= TD_MAX_HARMONICS) break;
        NSNumber *ratio = [[ratioPair allKeys] firstObject];
        NSNumber *amplitude = [ratioPair objectForKey:ratio];
        
        TDSineGenerator *sineGen = self->_harmonicGenerators[index + 1];
        
        // configure the harmonic sine wave with a freq relative to the
        // base freq
        sineGen.frequency = ratio.floatValue * self.baseFrequency;
        sineGen.amplitude = amplitude.floatValue;
        
        sineGen->_lastRenderTime = 0; // make the generator active
        index++;
    }
 
}

- (void)setBaseFrequency:(float)baseFrequency
{
    _baseFrequency = baseFrequency;
    NSArray *ratioAmpPairs = self.ratioAmpPairs;
    self.ratioAmpPairs = ratioAmpPairs;
}

@end
