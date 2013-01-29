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

@property (nonatomic, strong) NSString * copyright;
@property (nonatomic, strong) NSString * creditLine;
@property (nonatomic, strong) NSDate * expiration;
@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * machineRights;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) TAPAssetRef *assetRef;
@property (nonatomic, strong) NSSet *content;
@property (nonatomic, strong) NSSet *propertySet;
@property (nonatomic, strong) NSSet *source;
@property (nonatomic, strong) TAPAssetRef *watermark;

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
