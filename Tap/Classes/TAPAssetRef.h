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

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *usage;
@property (nonatomic, strong) TAPAsset *asset;
@property (nonatomic, strong) TAPStop *stop;
@property (nonatomic, strong) TAPTour *tour;
@property (nonatomic, strong) TAPAsset *watermark;

@end
