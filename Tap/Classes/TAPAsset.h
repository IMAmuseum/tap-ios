//
//  TAPAsset.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAssetRef, TAPContent, TAPProperty, TAPSource;

@interface TAPAsset : NSManagedObject

@property (nonatomic, retain) NSString * copyright;
@property (nonatomic, retain) NSString * creditLine;
@property (nonatomic, retain) NSDate * expiration;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * machineRights;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) TAPAssetRef *assetRef;
@property (nonatomic, retain) NSSet *content;
@property (nonatomic, retain) NSSet *propertySet;
@property (nonatomic, retain) NSSet *source;
@property (nonatomic, retain) TAPAssetRef *watermark;

- (NSArray *)getContentsByPart:(NSString *)part;
- (NSArray *)getSourcesByPart:(NSString *)part;

@end

@interface TAPAsset (CoreDataGeneratedAccessors)

- (void)addContentObject:(TAPContent *)value;
- (void)removeContentObject:(TAPContent *)value;
- (void)addContent:(NSSet *)values;
- (void)removeContent:(NSSet *)values;
- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;
- (void)addSourceObject:(TAPSource *)value;
- (void)removeSourceObject:(TAPSource *)value;
- (void)addSource:(NSSet *)values;
- (void)removeSource:(NSSet *)values;
@end
