//
//  TAPAsset.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TAPAsset.h"
#import "TAPAssetRef.h"
#import "TAPContent.h"
#import "TAPProperty.h"
#import "TAPSource.h"


@implementation TAPAsset

@dynamic copyright;
@dynamic creditLine;
@dynamic expiration;
@dynamic id;
@dynamic machineRights;
@dynamic type;
@dynamic assetRef;
@dynamic content;
@dynamic propertySet;
@dynamic source;
@dynamic watermark;

- (NSArray *)getContentsByPart:(NSString *)part
{
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    for (TAPContent *content in [self.content allObjects]) {
        if ([content.part isEqualToString:part]) {
            [contents addObject:content];
        }
    }
    if ([contents count]) {
        return [NSArray arrayWithArray:contents];
    } else {
        return nil;
    }
}

- (NSArray *)getSourcesByPart:(NSString *)part
{
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    for (TAPSource *source in self.content) {
        if ([source.part isEqualToString:part]) {
            [sources addObject:source];
        }
    }
    if ([sources count]) {
        return [NSArray arrayWithArray:sources];
    } else {
        return nil;
    }
}

@end
