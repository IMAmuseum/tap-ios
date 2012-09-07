//
//  TAPConnection.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPStop;

@interface TAPConnection : NSManagedObject

@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSString *usage;
@property (nonatomic, retain) TAPStop *destinationStop;
@property (nonatomic, retain) TAPStop *sourceStop;

@end
