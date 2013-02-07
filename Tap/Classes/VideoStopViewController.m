//
//  VideoStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "VideoStopViewController.h"
#import "VideoStop.h"

@implementation VideoStopViewController

- (id)initWithStop:(VideoStop *)stop
{
    self = [super init];
    if(self) {
        [self setVideoStop:stop];
        
        NSURL *videoURL = [self.videoStop getVideoURL];
        
        [[self moviePlayer] setContentURL:videoURL];
        [[self moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
    }
	return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end