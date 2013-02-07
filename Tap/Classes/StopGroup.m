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

- (UIImageView *)getHeaderImage
{
    NSArray *headerAssets = [self.model getAssetsByUsage:@"header_image"];
    if ([headerAssets count]) {
        TAPAsset *headerAsset = [headerAssets objectAtIndex:0];
        if (headerAsset != nil) {
            NSString *headerImageSrc = [[[headerAsset source] anyObject] uri];
            return [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:headerImageSrc]];
        }
    }
    return nil;
}

#pragma mark BaseStop Implementation

- (NSString *)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-list" ofType:@"png"];
}

-(BOOL)providesViewController
{
	return YES;
}

-(UIViewController*)newViewController
{
	return [[StopGroupViewController alloc] initWithStop:self];
}

@end
