//
//  TAPStop.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAssetRef, TAPConnection, TAPProperty, TAPTour;

@interface TAPStop : NSManagedObject

@property (nonatomic, strong, getter = desc) NSDictionary *desc;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong, getter = title) NSDictionary *title;
@property (nonatomic, strong) NSString *view;
@property (nonatomic, strong) NSSet *assetRef;
@property (nonatomic, strong) NSSet *destinationConnection;
@property (nonatomic, strong) NSSet *propertySet;
@property (nonatomic, strong) NSSet *sourceConnection;
@property (nonatomic, strong) TAPTour *tour;
@property (nonatomic, strong) TAPTour *tourRootStop;

- (NSString *)getIconPath;
- (NSArray *)getAssets;
- (NSArray *)getAssetsByUsage:(NSString *)usage;
- (NSString *)getPropertyValueByName:(NSString *)name;
- (NSArray *)getPropertyValuesByName:(NSString *)name;
- (NSComparisonResult)compareByKeycode:(TAPStop *)otherObject;

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
