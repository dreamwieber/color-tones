//
//  TDHarmonicsGenerator.h
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "TDGenerator.h"
#import "TDSineGenerator.h"

#define TD_MAX_HARMONICS 8

@interface TDHarmonicsGenerator : TDGenerator {
    @public
    float _baseFrequency;
}

@property (nonatomic, readwrite) float baseFrequency;
@property (nonatomic, strong) NSArray *ratioAmpPairs;

// freqAmpPairs is an array of dictionaries where keys are a ratio
// and values are amplitudes. E.g., @[{@1 : @.5}, @{1.075, @.25}]
+ (instancetype)harmonicsGeneratorWithBaseFrequency:(float)baseFreq
                        ratioAmplitudePairs:(NSArray *)ratioAmpPairs;


@end
