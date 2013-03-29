//
//  TAPTour.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAssetRef, TAPProperty, TAPStop;

@interface TAPTour : NSManagedObject

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *bundlePath;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSDate *publishDate;
@property (nonatomic, strong, getter = title) NSDictionary *title;
@property (nonatomic, strong, getter = desc) NSDictionary *desc;
@property (nonatomic, strong) NSSet *appResource;
@property (nonatomic, strong) NSSet *propertySet;
@property (nonatomic, strong) TAPStop *rootStopRef;
@property (nonatomic, strong) NSSet *stop;

- (NSArray *)getAppResources;
- (NSArray *)getAppResourcesByUsage:(NSString *)usage;
- (NSString *)getPropertyValueByName:(NSString *)name;
- (TAPStop *)stopFromKeycode:(NSString *)keycode;
- (TAPStop *)stopFromId:(NSString *)id;

@end

@interface TAPTour (CoreDataGeneratedAccessors)

- (void)addAppResourceObject:(TAPAssetRef *)value;
- (void)removeAppResourceObject:(TAPAssetRef *)value;
- (void)addAppResource:(NSSet *)values;
- (void)removeAppResource:(NSSet *)values;
- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;
- (void)addStopObject:(TAPStop *)value;
- (void)removeStopObject:(TAPStop *)value;
- (void)addStop:(NSSet *)values;
- (void)removeStop:(NSSet *)values;

@end
