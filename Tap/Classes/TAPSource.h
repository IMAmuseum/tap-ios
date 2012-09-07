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

@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain) NSString *part;
@property (nonatomic, retain, getter = uri) NSString *uri;
@property (nonatomic, retain) NSSet *propertySet;
@property (nonatomic, retain) TAPAsset *relationship;
@end

@interface TAPSource (CoreDataGeneratedAccessors)

- (void)addPropertySetObject:(TAPProperty *)value;
- (void)removePropertySetObject:(TAPProperty *)value;
- (void)addPropertySet:(NSSet *)values;
- (void)removePropertySet:(NSSet *)values;
@end
