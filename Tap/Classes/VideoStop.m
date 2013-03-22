//
//  VideoStop.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "VideoStop.h"
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

- (BOOL)loadStopViewForViewController:(UIViewController *)viewController
{
    VideoStopViewController *videoViewController = [[VideoStopViewController alloc] initWithStop:self];
    [viewController.navigationController presentMoviePlayerViewControllerAnimated:videoViewController];
	return YES;
}

@end
