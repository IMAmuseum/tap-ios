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
#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"

@interface TapBeaconManager ()

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic, strong) NSDictionary *config;

@end

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
        self.regions = [[NSMutableArray alloc] init];
        self.beaconStopMap = [[NSMutableDictionary alloc] init];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.isMonitoring = NO;
        
        //clear out any existing regions
        [self stopMonitoringAndRangingBeacons];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.config = [[appDelegate tapConfig] objectForKey:@"TapBeaconConfig"];
    }
    
    return self;
}

-(void)initBeaconsForTour:(TAPTour *)tour
{
    [self.regions removeAllObjects];
    [self.beacons removeAllObjects];
    
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
        GDataXMLDocument *beaconXml = (GDataXMLDocument *)[beacons getParsedData];
        NSMutableArray *beaconUUIDs = [[NSMutableArray alloc] init];
        for (GDataXMLElement *beacon in [beaconXml.rootElement elementsForName:@"beacon"]) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[[beacon attributeForName:@"uuid"] stringValue]];
            NSString *bId = [[beacon attributeForName:@"id"] stringValue];
            NSString *major = [[beacon attributeForName:@"major"] stringValue];
            NSString *minor = [[beacon attributeForName:@"minor"] stringValue];
            NSString *name = [[beacon attributeForName:@"name"] stringValue];
            
            TapBeacon *beacon = [[TapBeacon alloc] initWithId:bId
                                                         uuid:uuid
                                                        major:[major intValue]
                                                        minor:[minor intValue]
                                                         name:name];

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
                
                [self.regions addObject:region];
                [beaconUUIDs addObject:beacon_lookup];
            }
        }
    }
}

-(NSArray *)getBeaconsForRegion:(CLBeaconRegion *)region
{
    NSMutableArray *beacons = [[NSMutableArray alloc] init];
    for (TapBeacon *beacon in self.beacons) {
        if ([beacon.uuid isEqual:region.proximityUUID] && beacon.major == [region.major intValue]) {
            [beacons addObject:beacon];
        }
    }
    
    return beacons;
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
    [self stopMonitoringAndRangingBeacons];
    [self stopUpdatingLocation];
}

-(void)startMonitoringBeacons
{
    if (!self.isMonitoring) {
        for (CLBeaconRegion *region in self.regions) {
            [self.locationManager startMonitoringForRegion:region];
        }
    }
}

-(void)startRangingBeacons
{
    if (!self.isMonitoring) {
        for (CLBeaconRegion *region in self.regions) {
            [self.locationManager startRangingBeaconsInRegion:region];
        }
        
        self.isMonitoring = YES;
    }
}

-(void)startMonitoringAndRangingBeacons
{
    if (!self.isMonitoring) {
        for (CLBeaconRegion *region in self.regions) {
            [self.locationManager startMonitoringForRegion:region];
            [self.locationManager startRangingBeaconsInRegion:region];
        }
        
        self.isMonitoring = YES;
    }
}

-(void)stopMonitoringBeacons
{
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
    
    self.isMonitoring = NO;
}

-(void)stopRangingBeacons
{
    for (CLBeaconRegion *region in self.locationManager.rangedRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    
    self.isMonitoring = NO;
}

-(void)stopMonitoringAndRangingBeacons
{
    [self stopMonitoringBeacons];
    [self stopRangingBeacons];
    
    self.isMonitoring = NO;
}

-(void)requestPermissions
{
    if ([[self.config objectForKey:@"PermissionLevelAlways"] boolValue]) {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    } else {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
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
    if ([beacons count] == 0) {
        return;
    }
    
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

    if ([[self.config objectForKey:@"CollectAnalytics"] boolValue] && [beaconData count] > 0) {
        NSDictionary *event = [self createBeaconEvent:@"ranged" withBeacons:beaconData];
        [self sendBeaconEventData:@[event]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSDictionary *data = @{@"region": region};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TAPEnteredRegion"
                                                        object:self
                                                      userInfo:data];
    
    if ([[self.config objectForKey:@"CollectAnalytics"] boolValue]) {
        CLBeaconRegion *r = (CLBeaconRegion *) region;
        NSArray *beacons = [self getBeaconsForRegion:r];
        
        NSDictionary *event = [self createBeaconEvent:@"entered_region" withBeacons:beacons];
        [self sendBeaconEventData:@[event]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSDictionary *data = @{@"region": region};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TAPExitedRegion"
                                                        object:self
                                                      userInfo:data];
    
    if ([[self.config objectForKey:@"CollectAnalytics"] boolValue]) {
        CLBeaconRegion *r = (CLBeaconRegion *) region;
        NSArray *beacons = [self getBeaconsForRegion:r];
        
        NSDictionary *event = [self createBeaconEvent:@"exited_region" withBeacons:beacons];
        [self sendBeaconEventData:@[event]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *stateText = @"unknown";
    switch (state) {
        case CLRegionStateInside:
            stateText = @"inside";
            break;
            
        case CLRegionStateOutside:
            stateText = @"outside";
            break;
            
        default:
            break;
    }
    
    NSDictionary *data = @{@"region": region, @"state": stateText};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TAPDeterminedRegionState"
                                                        object:self
                                                      userInfo:data];
    
    //TODO: Determine if sending this data would be useful
    //    if (self.sendAnalytics) {
    //        CLBeaconRegion *r = (CLBeaconRegion *) region;
    //        NSArray *beacons = [self getBeaconsForRegion:r];
    //        
    //        NSDictionary *event = [self createBeaconEvent:@"exited_region" withBeacons:beacons];
    //        [self sendBeaconEventData:@[event]];
    //    }
}

//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//    NSLog(@"didStartMonitoringForRegion");
//}

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

- (void)sendBeaconEventData:(NSArray *)events {
    if (![[self.config objectForKey:@"CollectAnalytics"] boolValue]) {
        return;
    }
    
    NSDictionary *sendData = @{@"token": [self.config objectForKey:@"BeaconAnalyticsToken"],
                               @"events": events};

    NSString *data;
    if ([NSJSONSerialization isValidJSONObject:sendData])
    {
        // Serialize the dictionary
        NSData *json;
        NSError *jsonError = nil;
        json = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:&jsonError];
        
        if (json != nil && jsonError == nil) {
            data = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        }
    }
    
    if (data != nil) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"data": data};
        NSString *endpoint = [NSString stringWithFormat:@"%@beacons", [self.config objectForKey:@"BeaconAnalyticsEndpoint"]];
        [manager POST:endpoint parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"Send ranged data");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
        }];
    }
}

- (NSDictionary *)createBeaconEvent:(NSString *)event withBeacons:(NSArray *)beacons
{
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSNumber *timestamp = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] integerValue]];
    NSMutableArray *beaconData = [[NSMutableArray alloc] init];
    
    for (TapBeacon *beacon in beacons) {
        [beaconData addObject:@{@"beacon_id":beacon.bId,
                                @"beacon_tx_power":[NSNumber numberWithInteger:beacon.beacon.rssi],
                                @"beacon_range":[beacon proximityToString],
                                @"beacon_accuracy":[NSNumber numberWithDouble:beacon.beacon.accuracy]}];
    }
    
    NSDictionary *eventData = @{@"event": event,
                                @"mobile_device_id": device_id,
                                @"timestamp": timestamp,
                                @"beacons":beaconData};
    
    return eventData;
}

- (void)sendBeaconInteractionData:(NSString *)event stopId:(NSString *)stopId {
    if (![[self.config objectForKey:@"CollectAnalytics"] boolValue]) {
        return;
    }
    
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSNumber *timestamp = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] integerValue]];
    
    
    NSArray *interactions = @[@{@"event": event,
                                @"stop_id": stopId,
                                @"mobile_device_id": device_id,
                                @"timestamp": timestamp}];
    
    NSDictionary *sendData = @{@"token": [self.config objectForKey:@"BeaconAnalyticsToken"],
                               @"events": interactions};
    
    NSString *data;
    if ([NSJSONSerialization isValidJSONObject:sendData])
    {
        // Serialize the dictionary
        NSData *json;
        NSError *jsonError = nil;
        json = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:&jsonError];
        
        if (json != nil && jsonError == nil) {
            data = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        }
    }
    
    if (data != nil) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"data": data};
        NSString *endpoint = [NSString stringWithFormat:@"%@content", [self.config objectForKey:@"BeaconAnalyticsEndpoint"]];
        [manager POST:endpoint parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        NSLog(@"Send ranged data");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        NSLog(@"Error: %@", error);
        }];
    }
}

- (BOOL)diagnosticModeEnabled
{
    return [[self.config objectForKey:@"EnableDiagnostics"] boolValue];
}

@end
