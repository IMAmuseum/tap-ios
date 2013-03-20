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

-(BOOL)loadStopView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AudioStopViewController *viewController = [[AudioStopViewController alloc] initWithStop:self];
    [appDelegate.rootViewController.navigationController presentMoviePlayerViewControllerAnimated:viewController];
	return YES;
}

@end
