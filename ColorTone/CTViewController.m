//
//  CTViewController.m
//  ColorTone
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "CTViewController.h"
#import <TheAmazingAudioEngine.h>
#import "ADSR.h"
#import "CTDrum.h"
#import "CTRoundButton.h"

@interface CTViewController () {
    @public
    CTDrum *_drumVoices[13]; // many generators, for polyphony
    NSUInteger _currentVoice;

}

@property (nonatomic, strong) AEAudioController *audioController; // The Amazing Audio Engine
@property (nonatomic, strong) AEBlockChannel *drumChannel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

// for polyphony
@property (nonatomic, strong) NSMutableDictionary *voiceButtonBindings;

@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 0; i < 13; i++) {
        _drumVoices[i] = [CTDrum drumWithFrequency:40];
    }
    
    self.voiceButtonBindings = [NSMutableDictionary new];
    
    AudioStreamBasicDescription audioFormat = [AEAudioController nonInterleavedFloatStereoAudioDescription];
    
    // Setup the Amazing Audio Engine:
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:audioFormat];
    
    __weak CTViewController *weakSelf = self;
    AEBlockChannel *drumChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        CTViewController *strongSelf = weakSelf;
        
        UInt32 numberOfBuffers = audio->mNumberBuffers;
        
        // copy the sine wave from the scratch buffer to the output buffers
        for (int i = 0; i < numberOfBuffers; i++) {
            audio->mBuffers[i].mDataByteSize = frames * sizeof(float);
            
            float *output = (float *)audio->mBuffers[i].mData;
            
            for (int i = 0; i < 13; i++) {
                CTDrum *drum = strongSelf->_drumVoices[i];
                
                if (drum->_processBlock) {
                    drum->_processBlock(time, frames, output);
                }
            }
        }
    }];
    
    [drumChannel setVolume:.25];
    
    // Add the channel to the audio controller
    [self.audioController addChannels:@[drumChannel]];
    
    // Hold onto the noiseChannel
    self.drumChannel = drumChannel;
    
    // Turn on the audio controller
    NSError *error = NULL;
    [self.audioController start:&error];
    
    if (error) {
        NSLog(@"There was an error starting the controller: %@", error);
    }
    
    
    // layout buttons
    for (int i=0; i <7; i++) {
        for (int j=0; j < 7; j++) {
            CTRoundButton *button = [CTRoundButton buttonWithSize:CGSizeMake(44, 44) color:[UIColor blueColor]];
            
            CGFloat x, y;
            x = i * 44;
            x+= 22;
            y = j * 44;
            y+= 22;
            
            button.center = CGPointMake(x, y);
            
            button.tag = i + j;
            
            [button addTarget:self action:@selector(buttonDown:forEvent:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

            
            [self.containerView addSubview:button];

        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonDown:(CTRoundButton *)sender forEvent:(UIEvent *)event {
//    
//    // find how far from the center the drum was hit
//    UITouch *touch = [[event touchesForView:sender] anyObject];
//    CGPoint location = [touch locationInView:sender];
//    CGPoint center = CGPointMake(CGRectGetMidX(sender.bounds), CGRectGetMidY(sender.bounds));
//    CGFloat dx = location.x - center.x;
//    CGFloat dy = location.y - center.y;
//    CGFloat dist = sqrt(dx * dx + dy * dy);
//    float distNormalized = dist / CGRectGetMidX(sender.bounds);

    [self triggerDrumWithButton:sender];
    
    if ([sender isKindOfClass:[CTRoundButton class]]) {
        CTRoundButton *roundButton = (CTRoundButton *)sender;
        [roundButton animate];
    }
}

- (IBAction)buttonUp:(UIButton *)sender {
    NSNumber *key = @(sender.tag);
    CTDrum *drum = [self.voiceButtonBindings objectForKey:key];
    [drum hitRelease];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)triggerDrumWithButton:(CTRoundButton *)button
{

    NSNumber *key = @(button.tag);
    CTDrum *drum = [self nextAvaliableDrum];
    
    NSArray *allKeysForDrum = [self.voiceButtonBindings allKeysForObject:drum];
    if (allKeysForDrum.count) {
        [drum hitRelease];
        
        [self.voiceButtonBindings removeObjectsForKeys:allKeysForDrum];
    }

    [self.voiceButtonBindings setObject:drum forKey:key];
    
    [drum hitAtDistanceFromCenter:0];
    
}

- (CTDrum *)nextAvaliableDrum
{
    if (_currentVoice >= 13) {
        _currentVoice = 0;
    }
    CTDrum *drum = _drumVoices[_currentVoice];
    _currentVoice++;
    return drum;
}

@end
