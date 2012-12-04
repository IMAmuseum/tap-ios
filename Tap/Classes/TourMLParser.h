//
//  TourMLParser.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 IMA Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "TAPStop.h"
#import "TAPConnection.h"
#import "TAPAsset.h"
#import "TAPContent.h"
#import "TAPTour.h"
#import "TAPProperty.h"
#import "TAPSource.h"
#import "TAPAssetRef.h"

@interface TourMLParser : NSObject

+ (void)loadTours;

@end

@interface TourMLParser ()

+ (void)getExternalTourMLDoc:(NSString *)tourMLRef;
+ (void)parseTourMLDoc:(GDataXMLDocument *)doc;
+ (NSSet *)processStops:(GDataXMLElement *)element fromRoot:(GDataXMLElement *)root withContext:(NSManagedObjectContext *)context;
+ (NSSet *)processAssets:(NSArray *)elements fromRoot:(GDataXMLElement *)root withContext:(NSManagedObjectContext *)context;
+ (NSDictionary *)processTitle:(NSArray *)elements withContext:(NSManagedObjectContext *)context;
+ (NSDictionary *)processDescription:(NSArray *)elements withContext:(NSManagedObjectContext *)context;
+ (NSSet *)processPropertySet:(GDataXMLElement *)element withContext:(NSManagedObjectContext *)context;
+ (NSDate *)convertStringToDate:(NSString *)dateString;

@end
