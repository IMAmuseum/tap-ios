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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlayStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];        
    }
	return self;
}

#pragma mark - Notification handler

- (void)moviePlayerPlayStateChanged:(NSNotification *)notification
{
    // TODO: add new tracking code
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        // log event Audio play
    } else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        // log event Audio pause
    }
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    // TODO: add new tracking code
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end