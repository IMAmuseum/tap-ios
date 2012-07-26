//
//  TAPStop.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPStop.h"
#import "TAPAssetRef.h"
#import "TAPConnection.h"
#import "TAPProperty.h"
#import "TAPTour.h"
#import "AppDelegate.h"


@implementation TAPStop

@dynamic desc;
@dynamic id;
@dynamic title;
@dynamic view;
@dynamic assetRef;
@dynamic destinationConnection;
@dynamic propertySet;
@dynamic sourceConnection;
@dynamic tour;
@dynamic tourRootStop;

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
 * Retrieve the stops icon path
 */
- (NSString *)getIconPath
{
    // look for icon named like [view]-icon-image
    NSString *icon = [NSString stringWithFormat:@"icon-%@", self.view];
    NSString *path = [[NSBundle mainBundle] pathForResource:icon ofType:@"png"];
    
    // default case
    if (path == nil) {
        return [[NSBundle mainBundle] pathForResource:@"icon-webpage" ofType:@"png"];
    }
    return path;
}

/**
 * Convenience method for retrieving all assets for a stop
 */
- (NSArray *)getAssets
{
    NSMutableArray *assets = [[[NSMutableArray alloc] init] autorelease];
    for (TAPAssetRef *assetRef in [self.assetRef allObjects]) {
        [assets addObject:assetRef.asset];
    }
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [assets sortedArrayUsingDescriptors:sortDescriptors];
}

/**
 * Convenience method for retrieving all assets with a particular usage
 */
- (NSArray *)getAssetsByUsage:(NSString *)usage
{
    NSMutableArray *assets = [[[NSMutableArray alloc] init] autorelease];
    for (TAPAssetRef *assetRef in [self.assetRef allObjects]) {
        if ([assetRef.usage isEqualToString:usage]) {
            [assets addObject:assetRef.asset];
        }
    }
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [assets sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSString *)getPropertyValueByName:(NSString *)name
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND value != nil AND (language == %@ OR language == nil)", name, appDelegate.language];
    TAPProperty *property = [[self.propertySet filteredSetUsingPredicate:predicate] anyObject];
    return property.value;
}

- (NSComparisonResult)compareByKeycode:(TAPStop *)otherObject 
{
    TAPStop *stop = (TAPStop *)self;
    return [[stop getPropertyValueByName:@"code"] compare:[otherObject getPropertyValueByName:@"code"]];
}

@end
