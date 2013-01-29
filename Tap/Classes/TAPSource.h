//
//  TAPSource.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPAsset, TAPProperty;

@interface TAPSource : NSManagedObject

@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSString *part;
@property (nonatomic, strong, getter = uri) NSString *uri;
@property (nonatomic, strong) NSSet *propertySet;
@property (nonatomic, strong) TAPAsset *relationship;
@end

@interface TAPSource (CoreDataGeneratedAccessors)

- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;
@end
