//
//  AudioStop.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "AudioStop.h"
#import "AppDelegate.h"
#import "AudioStopViewController.h"

@implementation AudioStop

- (NSURL *)getAudioURL
{
    TAPAsset *asset = [[self.model getAssetsByUsage:@"audio"] objectAtIndex:0];
    NSString *audioPath = [[[asset source] anyObject] uri];
    return [NSURL fileURLWithPath:audioPath];
}

# pragma mark BaseStop Implementation

- (NSString *)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-audio" ofType:@"png"];
}

-(BOOL)providesViewController
{
	return NO;
}

- (BOOL)loadStopViewForViewController:(UIViewController *)viewController
{
    AudioStopViewController *audioViewController = [[AudioStopViewController alloc] initWithStop:self];
    [viewController.navigationController presentMoviePlayerViewControllerAnimated:audioViewController];
	return YES;
}

@end
