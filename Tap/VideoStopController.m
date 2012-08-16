//
//  VideoStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/14/12.
//
//

#import "VideoStopController.h"
#import "TAPStop.h"
#import "TAPProperty.h"
#import "TAPAssetRef.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"

@implementation VideoStopController

@synthesize videoStop = _videoStop;

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if(self) {
        [self setVideoStop:stop];
        
        TAPAsset *asset = [[stop getAssetsByUsage:@"tour_video"] objectAtIndex:0];
        NSString *videoPath = [[[asset source] anyObject] uri];
        NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
        [[self moviePlayer] setContentURL:videoURL];
        [[self moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
    }
	return self;
}

- (void)dealloc
{
    [_videoStop release];
    [super dealloc];
}

@end
