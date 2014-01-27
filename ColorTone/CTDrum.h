//
//  CTDrum.h
//  ColorTone
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "TDGenerator.h"

@interface CTDrum : TDGenerator

@property (nonatomic, readwrite) float frequency;

+ (instancetype)drumWithFrequency:(float)frequency;

- (void)hitAtDistanceFromCenter:(float)distance;
- (void)hitRelease;

@end
