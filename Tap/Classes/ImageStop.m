//
//  ImageStop.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "ImageStop.h"
#import "ImageGalleryViewController.h"

@implementation ImageStop

#pragma mark BaseStop Implementation

- (NSString *)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-image" ofType:@"png"];
}

-(BOOL)providesViewController
{
	return YES;
}

-(UIViewController*)newViewController
{
	return [[ImageGalleryViewController alloc] initWithStop:self];
}

@end
