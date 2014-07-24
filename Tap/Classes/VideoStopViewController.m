//
//  VideoStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "VideoStopViewController.h"
#import "VideoStop.h"

@interface VideoStopViewController()
@property (nonatomic, strong) VideoStop *videoStop;
@end

@implementation VideoStopViewController

- (id)initWithStop:(VideoStop *)stop
{
    self = [super init];
    if(self) {
        [self setVideoStop:stop];
        
        NSURL *videoURL = [self.videoStop getVideoURL];
        
        [self.moviePlayer setContentURL:videoURL];
        [self.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlayStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    }
	return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark - Notification handler

- (void)moviePlayerPlayStateChanged:(NSNotification *)notification
{
    // TODO: add new tracking code
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        // log event video played
    } else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        // log event video paused
    }
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    // TODO: add new tracking code
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end