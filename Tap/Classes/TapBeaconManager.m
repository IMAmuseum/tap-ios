//
//  TapBeaconManager.m
//  Tap
//
//  Created by Kyle Jaebker on 1/6/15.
//
//

#import "TapBeaconManager.h"
#import "TAPTour.h"
#import "TAPAsset.h"
#import "TAPContent.h"
#import "TAPProperty.h"
#import "TAPStop.h"
#import "GDataXMLNode.h"
#import "TapBeacon.h"

@implementation TapBeaconManager

+ (TapBeaconManager *)sharedInstance
{
    static TapBeaconManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[TapBeaconManager alloc] init];
    });
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.beacons = [[NSMutableArray alloc] init];
        self.regions = [[NSMutableDictionary alloc] init];
        self.beaconStopMap = [[NSMutableDictionary alloc] init];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    return self;
}

-(void)initBeaconsForTour:(TAPTour *)tour
{
    TAPAsset *tourBeacons = [[tour getAppResourcesByUsage:@"beacons"] objectAtIndex:0];
    if (tourBeacons != nil) {
        for (TAPStop *stop in [[tour stop] allObjects]) {
            NSArray *beaconIds = [stop getPropertyValuesByName:@"beacon_id"];
            if ([beaconIds count] > 0) {
                for (NSString *bId in beaconIds) {
                    if (![self.beaconStopMap objectForKey:bId]) {
                        [self.beaconStopMap setObject:[[NSMutableArray alloc] init] forKey:bId];
                    }
                    [[self.beaconStopMap objectForKey:bId] addObject:stop.id];
                }
            }
        }
        
        TAPContent *beacons = [[tourBeacons content] anyObject];
        GDataXMLDocument *beaconXml = [beacons getParsedData];
        NSMutableArray *beaconUUIDs = [[NSMutableArray alloc] init];
        for (GDataXMLElement *beacon in [beaconXml.rootElement elementsForName:@"beacon"]) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[[beacon attributeForName:@"uuid"] stringValue]];
            NSString *bId = [[beacon attributeForName:@"id"] stringValue];
            NSString *major = [[beacon attributeForName:@"major"] stringValue];
            NSString *minor = [[beacon attributeForName:@"minor"] stringValue];
            
            TapBeacon *beacon = [[TapBeacon alloc] initWithId:bId
                                                         uuid:uuid
                                                        major:[major intValue]
                                                        minor:[minor intValue]];

            beacon.stopIds = [self.beaconStopMap objectForKey:bId];
            
            [self.beacons addObject:beacon];
            
            NSString *beacon_lookup = [NSString stringWithFormat:@"%@-%d", [beacon.uuid UUIDString], beacon.major];
            if (![beaconUUIDs containsObject:beacon_lookup]) {
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                                 major:[major intValue]
                                                                            identifier:bId];
                
                region.notifyEntryStateOnDisplay = YES;
                region.notifyOnEntry = YES;
                region.notifyOnExit = YES;
                
                [self.regions setObject:region forKey:bId];
                [beaconUUIDs addObject:beacon_lookup];
            }
        }
    }
}

-(void)startLocationServicesForTour:(TAPTour *)tour
{
    [self initBeaconsForTour:tour];
    [self startMonitoringAndRangingBeacons];
    [self requestPermissions];
    [self startUpdatingLocation];
}

-(void)stopLocationServicesForTour:(TAPTour *)tour
{
    [self initBeaconsForTour:tour];
    [self stopMonitoringAndRangingBeacons];
    [self stopUpdatingLocation];
}

-(void)startMonitoringBeacons
{
    for (NSString *beaconId in self.regions) {
        CLBeaconRegion *region = [self.regions objectForKey:beaconId];
        [self.locationManager startMonitoringForRegion:region];
    }
}

-(void)startRangingBeacons
{
    for (NSString *beaconId in self.regions) {
        CLBeaconRegion *region = [self.regions objectForKey:beaconId];
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}

-(void)startMonitoringAndRangingBeacons
{
    for (NSString *beaconId in self.regions) {
        CLBeaconRegion *region = [self.regions objectForKey:beaconId];
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}

-(void)stopMonitoringBeacons
{
    for (NSString *beaconId in self.regions) {
        CLBeaconRegion *region = [self.regions objectForKey:beaconId];
        [self.locationManager stopMonitoringForRegion:region];
    }
}

-(void)stopRangingBeacons
{
    for (NSString *beaconId in self.regions) {
        CLBeaconRegion *region = [self.regions objectForKey:beaconId];
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

-(void)stopMonitoringAndRangingBeacons
{
    for (NSString *beaconId in self.regions) {
        CLBeaconRegion *region = [self.regions objectForKey:beaconId];
        [self.locationManager stopMonitoringForRegion:region];
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

-(void)requestPermissions
{
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
}

-(void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSMutableArray *beaconData = [[NSMutableArray alloc] init];
    NSMutableArray *beaconKeys = [[NSMutableArray alloc] init];
    
    for (CLBeacon *beacon in beacons) {
        for (TapBeacon *tapBeacon in self.beacons) {
            if (tapBeacon.major == [beacon.major intValue] &&
                tapBeacon.minor == [beacon.minor intValue] &&
                [tapBeacon.uuid isEqual:beacon.proximityUUID]) {
                
                tapBeacon.beacon = beacon;
                
                [beaconData addObject:tapBeacon];
                [beaconKeys addObject:[NSNumber numberWithInteger:[tapBeacon.bId integerValue]]];
                
                break;
            }
        }
    }
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:beaconData forKeys:beaconKeys];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TAPBeaconRanged"
                                                        object:self
                                                      userInfo:userInfo];
    
//    NSLog(@"Ranging - %lu", (unsigned long)[beacons count]);
//    NSLog(@"===============");
//    for (CLBeacon *beacon in beacons) {
//        NSLog(@"Beacon - %@ | %@ - %ld", beacon.major, beacon.minor, beacon.proximity);
//    }
    // range beacons
//    [self.beacons removeAllObjects];
//    
//    NSMutableArray *allBeacons = [NSMutableArray array];
//    
//    for (NSArray *regionResult in [self.rangedRegions allValues])
//    {
//        [allBeacons addObjectsFromArray:regionResult];
//    }
//    
//    // put all beacons into a dictionary by proximity
//    for (NSNumber *range in @[@(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
//    {
//        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
//        if([proximityBeacons count])
//        {
//            self.beacons[range] = proximityBeacons;
//        }
//    }
//    
//    if ([self.filteredStops count] == 0){
//        [self filterStops:self.beacons];
//        [self.stopListTable reloadData];
//    }
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Welcome to your beacon!";
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Are you forgetting something?";
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
     NSLog(@"Failed ranging region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}

@end
