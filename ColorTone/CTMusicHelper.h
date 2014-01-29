//
//  CTMusicHelper.h
//  ColorTones
//
//  Created by Gregory Wieber on 11/14/13.
//  Copyright (c) 2013 Apposite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTMusicHelper : NSObject

+ (NSInteger)midiKeyFromNote:(NSString *)note;
+ (NSArray *)midiKeysForScale:(NSString *)scaleName withRoot:(NSString *)rootNote length:(NSUInteger)length;
+ (NSInteger)nthInterval:(NSInteger)n inScale:(NSString *)scaleName;
+ (NSDictionary *)scales;
+ (float)frequencyForMidiNote:(NSUInteger)note;
@end
