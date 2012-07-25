//
//  TAPProperty.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAsset, TAPContent, TAPSource, TAPStop, TAPTour;

@interface TAPProperty : NSManagedObject

@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) TAPAsset *assetPropertySet;
@property (nonatomic, retain) TAPContent *contentPropertySet;
@property (nonatomic, retain) TAPSource *sourcePropertySet;
@property (nonatomic, retain) TAPStop *stopPropertySet;
@property (nonatomic, retain) TAPTour *tourPropertySet;

@end
