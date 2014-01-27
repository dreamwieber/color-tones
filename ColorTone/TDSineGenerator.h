//
//  TDSineGenerator.h
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "TDGenerator.h"

@interface TDSineGenerator : TDGenerator {
    @public
    float _frequency;
}

@property (nonatomic, readwrite) float frequency;

+ (instancetype)generatorWithFrequency:(float)frequency
                             amplitude:(float)amplitude;

@end
