//
//  BeaconTableViewController.h
//  Tap
//
//  Created by Sarah Xu on 7/25/14.
//
//

#import "StopNavigationViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BeaconTableViewController : StopNavigationViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *beacons;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *rangedRegions;

@property (nonatomic, strong) NSString *currentRoom;
@property (nonatomic, strong) CLBeacon *closestBeacon;

@property (nonatomic, unsafe_unretained) IBOutlet UITableView *stopListTable;

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSMutableDictionary *filteredStops;

@end