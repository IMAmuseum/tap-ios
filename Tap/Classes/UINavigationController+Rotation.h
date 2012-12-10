//
//  UINavigationController+Rotation.h
//  Tap
//
//  Created by Daniel Cervantes on 12/9/12.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation)

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
