//
//  TAPContent.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAsset, TAPProperty;

@interface TAPContent : NSManagedObject

@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *part;
@property (nonatomic, strong) TAPAsset *asset;
@property (nonatomic, strong) NSSet *propertySet;

- (NSObject *)getParsedData;

@end

@interface TAPContent (CoreDataGeneratedAccessors)

- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;

@end
