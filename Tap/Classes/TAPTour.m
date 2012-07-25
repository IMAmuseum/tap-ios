//
//  TAPTour.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPTour.h"
#import "TAPAssetRef.h"
#import "TAPProperty.h"
#import "TAPStop.h"
#import "AppDelegate.h"

@implementation TAPTour

@dynamic author;
@dynamic id;
@dynamic bundlePath;
@dynamic lastModified;
@dynamic publishDate;
@dynamic title;
@dynamic desc;
@dynamic appResource;
@dynamic propertySet;
@dynamic rootStopRef;
@dynamic stop;

/**
 * Overriden getter that returns the localized title
 */
- (NSString *)title 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self willAccessValueForKey:@"title"];
    NSDictionary *title = [self primitiveValueForKey:@"title"];
    [self didAccessValueForKey:@"title"];
    
    if ([title objectForKey:[appDelegate language]]) {
        return [title objectForKey:[appDelegate language]];
    } else {
        return [title objectForKey:@""];
    }
}

/**
 * Overriden getter that returns the localized description
 */
- (NSString *)desc 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self willAccessValueForKey:@"desc"];
    NSDictionary *description = [self primitiveValueForKey:@"desc"];
    [self didAccessValueForKey:@"desc"];
    
    if ([description objectForKey:[appDelegate language]]) {
        return [description objectForKey:[appDelegate language]];
    } else {
        return [description objectForKey:@""];
    }
}

/**
 * Retrieves the stop for a given keycode
 */
- (TAPStop *)stopForKeycode:(NSString *)keycode
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(propertySet, $ps, $ps.name = 'code' AND $ps.value = %@ AND ($ps.language == %@ OR $ps.language == nil)).@count > 0", 
                              keycode, appDelegate.language];
    TAPStop *newStop = [[self.stop filteredSetUsingPredicate:predicate] anyObject];
    return newStop;
}

@end
