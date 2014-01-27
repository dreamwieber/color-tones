//
//  CTDrum.m
//  ColorTone
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "CTDrum.h"
#import "TDHarmonicsGenerator.h"
#import "ADSR.h"
#import <Accelerate/Accelerate.h>

@interface CTDrum ()

@property (nonatomic, strong) TDHarmonicsGenerator *harmonicsGenerator;
@property (nonatomic, strong) ADSR *adsr;

@end

@implementation CTDrum

+ (CTDrum *)drumWithFrequency:(float)frequency
{
    CTDrum *drum = [CTDrum new];
    drum.frequency = frequency;
    // harmonic ratio/amplitude pairs, taken from a Indian Mridangam
    NSArray *ratioAmplitudePairs = @[ @{@1.075 : @.16}, @{@2 : @1.0}, @{@3 : @.2076}, @{@4.025 : @.5254}, @{@5.075 : @.1525}];
    drum.harmonicsGenerator = [TDHarmonicsGenerator harmonicsGeneratorWithBaseFrequency:frequency ratioAmplitudePairs:ratioAmplitudePairs];
    drum.adsr = [ADSR ADSRWithAttack:.001 decay:.2 sustain:0 release:.6];
    
    [drum setupProcessBlock];
    
    return drum;
}

- (void)setupProcessBlock
{
    __weak CTDrum *weakSelf = self;
    self.processBlock = ^(const AudioTimeStamp *time, UInt32 frames, float *audio) {

        CTDrum *strongSelf = weakSelf;
        
        if (strongSelf->_harmonicsGenerator->_processBlock) {
            strongSelf->_harmonicsGenerator->_processBlock(time, frames, strongSelf->_scratchBuffer);
        }
        
        if (strongSelf->_adsr->_processBlock) {
            strongSelf->_adsr->_processBlock(time, frames,  strongSelf->_scratchBuffer);
        }
        
        vDSP_vadd(strongSelf->_scratchBuffer, 1, audio, 1, audio, 1, frames);
        
    };
}

- (void)hitAtDistanceFromCenter:(float)distance
{
    self.adsr.gateOpen = YES;
    
    // distance from center could be used to do something like...
    
    // pitch up as the hits are closer to the edge of the drum
    //loat pitch = 40 + distNormalized * 2;
    //self.harmonicsGenerator.baseFrequency = pitch;
    
    // ring out more if it's hit in the center
    //self.adsr.decayT = CT_MAX_DECAY - (CT_MAX_DECAY - CT_MIN_DECAY) * distNormalized;
    //self.adsr.releaseT = CT_MAX_RELEASE - (CT_MAX_RELEASE - CT_MIN_RELEASE) * distNormalized;
}

- (void)hitRelease
{
    self.adsr.gateOpen = NO;
}

@end
