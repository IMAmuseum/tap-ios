//
//  AudioStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//
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
        
        TAPAsset *image = [[stop getAssetsByUsage:@"image"] objectAtIndex:0];
        if (image != nil) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[image source] anyObject] uri]]];
            [imageView setFrame:CGRectMake(0, 64, imageView.frame.size.width, imageView.frame.size.height)];
            [self.moviePlayer.backgroundView addSubview:imageView];
            [imageView release];
        }
    }
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    [_audioStop release];
    [super dealloc];
}

@end