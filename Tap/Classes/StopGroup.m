//
//  StopGroup.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "StopGroup.h"
#import "StopGroupViewController.h"

@implementation StopGroup

#pragma mark BaseStop

-(BOOL)providesViewController
{
	return YES;
}

-(UIViewController*)newViewController
{
	return [[StopGroupViewController alloc] initWithStop:self];
}

@end
