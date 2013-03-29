//
//  VideoStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "VideoStopViewController.h"
#import "VideoStop.h"
#import "Flurry.h"

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
        
        [self.view setBackgroundColor:[UIColor blackColor]];
    }
	return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark - Notification handler

- (void)moviePlayerPlayStateChanged:(NSNotification *)notification
{
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self.videoStop getTitle], @"Video Stop", nil];
        [Flurry logEvent:@"Video_Play" withParameters:params timed:YES];
    } else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self.videoStop getTitle], @"Video Stop", nil];
        [Flurry logEvent:@"Video_Pause" withParameters:params];
    }
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self.videoStop getTitle], @"Video Stop", nil];
    [Flurry logEvent:@"Video_Play" withParameters:params];
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight|UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown;
}

@end