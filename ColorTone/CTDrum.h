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
@property (nonatomic, readwrite) NSTimeInterval decayT;
@property (nonatomic, readwrite) NSTimeInterval releaseT;

+ (instancetype)drumWithFrequency:(float)frequency;

- (void)hitAtDistanceFromCenter:(float)distance;
- (void)hitRelease;

@end
