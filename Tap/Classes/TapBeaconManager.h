//
//  TapBeaconManager.h
//  Tap
//
//  Created by Kyle Jaebker on 1/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TAPTour.h"

@interface TapBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *beacons;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *regions;
@property (nonatomic, strong) NSMutableDictionary *beaconStopMap;

@property (nonatomic, strong) CLBeacon *closestBeacon;

- (void)initBeaconsForTour:(TAPTour *)tour;
- (void)startMonitoringBeacons;
- (void)startRangingBeacons;
- (void)startMonitoringAndRangingBeacons;
- (void)stopMonitoringBeacons;
- (void)stopRangingBeacons;
- (void)stopMonitoringAndRangingBeacons;
- (void)requestPermissions;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)startLocationServicesForTour:(TAPTour *)tour;
- (void)stopLocationServicesForTour:(TAPTour *)tour;


+ (TapBeaconManager *)sharedInstance;

@end
