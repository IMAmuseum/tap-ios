//
//  AudioStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "AudioStopController.h"
#import "TAPStop.h"
#import "TAPProperty.h"
#import "TAPAssetRef.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"

@implementation AudioStopController

@synthesize audioStop = _audioStop;

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if(self) {
        [self setAudioStop:stop];
        
        TAPAsset *asset = [[stop getAssetsByUsage:@"tour_audio"] objectAtIndex:0];
        NSString *audioPath = [[[asset source] anyObject] uri];
        NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
        [[self moviePlayer] setContentURL:audioURL];
        [[self moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
    }
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void)dealloc
{
    [_audioStop release];
    [super dealloc];
}

@end