//
//  NonSelectingTextView.m
//  Tap
//
//  Created by Daniel Cervantes on 7/22/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "NonSelectableTextView.h"

@implementation NonSelectableTextView

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

@end
