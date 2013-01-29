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

@property (nonatomic, strong) NSNumber *priority;
@property (nonatomic, strong) NSString *usage;
@property (nonatomic, strong) TAPStop *destinationStop;
@property (nonatomic, strong) TAPStop *sourceStop;

@end
