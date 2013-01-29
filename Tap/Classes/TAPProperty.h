//
//  TAPProperty.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAsset, TAPContent, TAPSource, TAPStop, TAPTour;

@interface TAPProperty : NSManagedObject

@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) TAPAsset *assetPropertySet;
@property (nonatomic, strong) TAPContent *contentPropertySet;
@property (nonatomic, strong) TAPSource *sourcePropertySet;
@property (nonatomic, strong) TAPStop *stopPropertySet;
@property (nonatomic, strong) TAPTour *tourPropertySet;

@end
