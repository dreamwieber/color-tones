//
//  ADSR.m
//  ShapedNoise
//
//  Created by Gregory Wieber on 1/25/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "ADSR.h"
#import <Accelerate/Accelerate.h>

typedef NS_ENUM(NSInteger, ADSRPhase) {
    ADSRPhaseNone,
    ADSRPhaseAttack,
    ADSRPhaseDecay,
    ADSRPhaseSustain,
    ADSRPhaseRelease
};

@interface ADSR () {
    @public
    ADSRPhase _phase; // whether we're currently attacking, decaying, etc
    double _amplitude; // what the audio is multiplied by.
    float _scratchBuffer[4096];
    // times in samples
    double _currentPhaseElapsedTime; //e.g., how long we've been attacking, decaying, etc
    // how much each phase increments/decrements per sample
    double _attackIncrement;
    double _decayDecrement;
    double _releaseDecrement;
    
    Float64 _lastRenderTime;
    
}

@end

@implementation ADSR

+ (id)ADSRWithAttack:(NSTimeInterval)attack
               decay:(NSTimeInterval)decay
             sustain:(float)sustain
             release:(NSTimeInterval)release
{
    ADSR *adsr = [ADSR new];
    
    if (adsr) {
        
        adsr->_amplitude = 0;
        adsr->_phase = ADSRPhaseNone;
        adsr->_currentPhaseElapsedTime = 0;
        adsr->_lastRenderTime = 0;
        bzero(adsr->_scratchBuffer, sizeof(float) * 4096);
        adsr.attackT = attack;
        adsr.decayT = decay;
        adsr.sustain = sustain;
        adsr.releaseT = release;
        
        [adsr createProcessBlock];
        
    }
    
    return adsr;
}

- (void)createProcessBlock
{
    __weak ADSR *weakSelf = self;
    
    self.processBlock = ^(const AudioTimeStamp *time, UInt32 frames, float *audio) {
       
        ADSR *adsr = weakSelf; // strongify
    
        if (time->mSampleTime <= adsr->_lastRenderTime ) {
            vDSP_vmul(audio, 1, adsr->_scratchBuffer, 1, audio, 1, frames);
            adsr->_lastRenderTime = time->mSampleTime;
            return;
        }
        
        for (int i = 0; i < frames; i++) {
            
            // if the gate was closed, goto the release phase
            if (adsr->_phase != ADSRPhaseRelease && !adsr->_gateOpen) {
                adsr->_phase = ADSRPhaseRelease;
            } else if (adsr->_gateOpen && (adsr->_phase == ADSRPhaseRelease || adsr->_phase == ADSRPhaseNone)) {
                // gate was re-opened
                adsr->_phase = ADSRPhaseAttack;
                adsr->_currentPhaseElapsedTime = 0.0;
            }

            switch (adsr->_phase) {
                    
                case ADSRPhaseAttack: {
                    
                    if (adsr->_currentPhaseElapsedTime >= (adsr->_attackT * 44100.0)) {
                        adsr->_amplitude = 1.0;
                        adsr->_currentPhaseElapsedTime = 0.0;
                        adsr->_phase++;
                        break;
                    }
                    
                    adsr->_amplitude+= adsr->_attackIncrement;
                    adsr->_currentPhaseElapsedTime++;
                    break;
                }
                    
                case ADSRPhaseDecay: {
                    
                    if (adsr->_currentPhaseElapsedTime >= (adsr->_decayT * 44100.0)) {
                        adsr->_currentPhaseElapsedTime = 0.0;
                        adsr->_phase++;
                        break;
                    }
                    adsr->_amplitude-= adsr->_decayDecrement;
                    adsr->_currentPhaseElapsedTime++;

                    break;
                }
                
                case ADSRPhaseSustain:
                    break;
                
                case ADSRPhaseRelease: {
                    
                    if (adsr->_amplitude <=0) {
                        adsr->_amplitude = 0.0;
                        adsr->_phase = ADSRPhaseNone;
                        adsr->_currentPhaseElapsedTime = 0.0;
                        break;
                    }
                    
                    adsr->_amplitude-= adsr->_releaseDecrement;
                    adsr->_currentPhaseElapsedTime++;
        
                    break;
                }
                default:
                    adsr->_amplitude = 0.0;
                    break;
            }
        
            adsr->_scratchBuffer[i] = fminf(1.0, adsr->_amplitude);
        }
        
        vDSP_vmul(audio, 1, adsr->_scratchBuffer, 1, audio, 1, frames);
        adsr->_lastRenderTime = time->mSampleTime;
    };
}

- (void)setAttackT:(NSTimeInterval)attackT
{
    _attackT = attackT;
    if (attackT == 0) {
        _attackIncrement = 1.0;
        return;
    }
    _attackIncrement = 1.0 / (attackT * 44100.0);
    
}

- (void)setDecayT:(NSTimeInterval)decayT
{
    _decayT = decayT;
    _decayDecrement = (double)(1.0 - self.sustain) / (decayT * 44100.0);
    if (_decayDecrement == 0) _decayDecrement = 1.0;
}


- (void)setReleaseT:(NSTimeInterval)releaseT
{
    _releaseT = releaseT;
    _releaseDecrement = 1.0f / (releaseT * 44100.0);
    if (_releaseDecrement == 0) _releaseDecrement = 1.0;
}

@end
