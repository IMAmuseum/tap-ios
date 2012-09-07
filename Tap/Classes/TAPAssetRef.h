//
//  TAPAssetRef.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAsset, TAPStop, TAPTour;

@interface TAPAssetRef : NSManagedObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *usage;
@property (nonatomic, retain) TAPAsset *asset;
@property (nonatomic, retain) TAPStop *stop;
@property (nonatomic, retain) TAPTour *tour;
@property (nonatomic, retain) TAPAsset *watermark;

@end
