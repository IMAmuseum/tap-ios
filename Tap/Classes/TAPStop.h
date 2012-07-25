//
//  TAPStop.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAssetRef, TAPConnection, TAPProperty, TAPTour;

@interface TAPStop : NSManagedObject

@property (nonatomic, retain, getter = desc) NSDictionary *desc;
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain, getter = title) NSDictionary *title;
@property (nonatomic, retain) NSString *view;
@property (nonatomic, retain) NSSet *assetRef;
@property (nonatomic, retain) NSSet *destinationConnection;
@property (nonatomic, retain) NSSet *propertySet;
@property (nonatomic, retain) NSSet *sourceConnection;
@property (nonatomic, retain) TAPTour *tour;
@property (nonatomic, retain) TAPTour *tourRootStop;

- (NSString *)getIconPath;
- (NSArray *)getAssets;
- (NSArray *)getAssetsByUsage:(NSString *)usage;

@end

@interface TAPStop (CoreDataGeneratedAccessors)

- (void)addAssetRefObject:(TAPAssetRef *)value;
- (void)removeAssetRefObject:(TAPAssetRef *)value;
- (void)addAssetRef:(NSSet *)values;
- (void)removeAssetRef:(NSSet *)values;
- (void)addDestinationConnectionObject:(TAPConnection *)value;
- (void)removeDestinationConnectionObject:(TAPConnection *)value;
- (void)addDestinationConnection:(NSSet *)values;
- (void)removeDestinationConnection:(NSSet *)values;
- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;
- (void)addSourceConnectionObject:(TAPConnection *)value;
- (void)removeSourceConnectionObject:(TAPConnection *)value;
- (void)addSourceConnection:(NSSet *)values;
- (void)removeSourceConnection:(NSSet *)values;

@end
