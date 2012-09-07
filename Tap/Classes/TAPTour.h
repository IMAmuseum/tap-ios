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

@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *bundlePath;
@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain) NSDate *publishDate;
@property (nonatomic, retain, getter = title) NSDictionary *title;
@property (nonatomic, retain, getter = desc) NSDictionary *desc;
@property (nonatomic, retain) NSSet *appResource;
@property (nonatomic, retain) NSSet *propertySet;
@property (nonatomic, retain) TAPStop *rootStopRef;
@property (nonatomic, retain) NSSet *stop;

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
