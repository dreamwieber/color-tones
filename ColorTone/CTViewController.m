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
#import "CTMusicHelper.h"
#import "Colours.h"

@interface CTViewController () {
    @public
    CTDrum *_drumVoices[13]; // many generators, for polyphony
    NSUInteger _currentVoice;

}

// audio
@property (nonatomic, strong) AEAudioController *audioController; // The Amazing Audio Engine
@property (nonatomic, strong) AEBlockChannel *drumChannel;

// for polyphony
@property (nonatomic, strong) NSMutableDictionary *voiceButtonBindings;

// view
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSArray *colors;

@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a number of drum 'voices'. This pool of available
    // voices can be taken from whenever we need to generate a new tone.
    for (int i = 0; i < 13; i++) {
        _drumVoices[i] = [CTDrum drumWithFrequency:41];
    }

    // Keep track of which button triggered which voice
    self.voiceButtonBindings = [NSMutableDictionary new];

    self.colors = [[ColorClass robinEggColor] colorSchemeOfType:ColorSchemeComplementary];
    
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
            
            // Render the drum voices.
            for (int i = 0; i < 13; i++) {
                CTDrum *drum = strongSelf->_drumVoices[i];
                if (drum->_processBlock) {
                    drum->_processBlock(time, frames, output);
                }
            }
        }
    }];
    
    // Turn the volume down a bit to reduce chance of clipping
    [drumChannel setVolume:.4];
    
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
    
    
    int colorIndex = 0;
    
    // layout buttons
    for (int i=0; i <7; i++) {
        for (int j=0; j < 7; j++) {
            
            UIColor *buttonColor = [self.colors objectAtIndex:colorIndex];
            colorIndex++;
            if (colorIndex >= self.colors.count) colorIndex = 0;
            
            CTRoundButton *button = [CTRoundButton buttonWithSize:CGSizeMake(44, 44) color:buttonColor];
            
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
    
    NSInteger root = [CTMusicHelper midiKeyFromNote:@"e1"];
    NSString *scaleName = @"indian";
    NSUInteger midiNote = root + [CTMusicHelper nthInterval:key.integerValue inScale:scaleName];
    float freq = [CTMusicHelper frequencyForMidiNote:midiNote];
    drum.frequency = freq;
    
    // do some hack-y scaling to the envelope.
    // at higher pitches, the drum decay's very quickly,
    // and at lower pitches it rings out.
    drum.releaseT = .4 - ((float)key.integerValue/127.0 * 3);
    drum.decayT = .2 - ((float)key.integerValue/127.0 * 1.5);

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
