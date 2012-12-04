//
//  TAPContent.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 IMA Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAsset, TAPProperty;

@interface TAPContent : NSManagedObject

@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *part;
@property (nonatomic, retain) TAPAsset *asset;
@property (nonatomic, retain) NSSet *propertySet;
@end

@interface TAPContent (CoreDataGeneratedAccessors)

- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;
@end
