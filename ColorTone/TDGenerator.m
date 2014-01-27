//
//  TDSine.m
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "TDGenerator.h"

@implementation TDGenerator

- (id)init
{
    if (self == [super init]) {
        self->_lastRenderTime = 0;
        bzero(self->_scratchBuffer, sizeof(float) * TD_SCRATCH_BUFFER_SIZE);
    }
    
    return self;
}

@end
