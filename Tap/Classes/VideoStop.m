//
//  VideoStop.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "VideoStop.h"
#import "AppDelegate.h"
#import "VideoStopViewController.h"

@implementation VideoStop

- (NSURL *)getVideoURL
{
    TAPAsset *asset = [[self.model getAssetsByUsage:@"video"] objectAtIndex:0];
    NSString *videoPath = [[[asset source] anyObject] uri];
    return [NSURL fileURLWithPath:videoPath];
}

#pragma mark BaseStop Implementation

- (NSString *)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-video" ofType:@"png"];
}

-(BOOL)providesViewController
{
	return NO;
}

-(BOOL)loadStopView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    VideoStopViewController *viewController = [[VideoStopViewController alloc] initWithStop:self];
    [appDelegate.rootViewController.navigationController presentMoviePlayerViewControllerAnimated:viewController];
	return YES;
}

@end
