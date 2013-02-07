//
//  AudioStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "AudioStopViewController.h"
#import "AudioStop.h"

@implementation AudioStopViewController

- (id)initWithStop:(AudioStop *)stop
{
    self = [super init];
    if(self) {
        [self setAudioStop:stop];
        
        NSURL *audioURL = [self.audioStop getAudioURL];
        [[self moviePlayer] setContentURL:audioURL];
        [[self moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
    }
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end