//
//  BeaconTableViewController.m
//  Tap
//
//  Created by Sarah Xu on 7/25/14.
//
//

#import "BeaconTableViewController.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"

@interface BeaconTableViewController ()

@end

@implementation BeaconTableViewController

-(id)init
{
    self = [super init];
    if(self) {
        [self setTitle:NSLocalizedString(@"Artwork Nearby", @"")];
        [self.tabBarItem setTitle:NSLocalizedString(@"Nearby", @"")];
        [self.tabBarItem setImage:[UIImage imageNamed:@"near"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // retrieve the current tour's stops
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(propertySet, $ps, $ps.name = 'code' AND $ps.value != nil AND ($ps.language == %@ OR $ps.language == nil)).@count > 0", appDelegate.language];
    NSSet *filteredStops = [[NSSet alloc] initWithSet:[appDelegate.currentTour.stop filteredSetUsingPredicate:predicate]];
    NSArray *sortedArray = [[filteredStops allObjects] sortedArrayUsingSelector:@selector(compareByKeycode:)];
    self.stops = [[NSArray alloc] initWithArray:sortedArray];
    
    // initialize the location manager
    self.beacons = [[NSMutableDictionary alloc] init];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    // retrieve the UUID of the beacons
    NSArray *beaconUUID = [appDelegate.tapConfig objectForKey:@"BeaconUUID"];
    
    for (NSString *beaconID in beaconUUID)
    {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconID];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }
    
    // Start ranging
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
    }

    self.filteredStops = [[NSMutableDictionary alloc] init];
    
    
    // initialize the timer
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
                                                      selector: @selector(callAfterTenSecond:) userInfo: nil repeats: YES];
    
    [self.stopListTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Deselect anything from the table
	[self.stopListTable deselectRowAtIndexPath:[self.stopListTable indexPathForSelectedRow] animated:animated];
    
    // reload the table with the correct tour data
    [self.stopListTable reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.filteredStops = nil;
}

-(void) callAfterTenSecond:(NSTimer*) timex
{
    // update the data
    [self filterStops:self.beacons];
    [self.stopListTable reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.beacons.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionValues = [self.beacons allValues];
    return [sectionValues[section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSArray *sectionKeys = [self.beacons allKeys];
    
    // The table view will display artworks by proximity
    NSNumber *sectionKey = sectionKeys[section];
    
    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = NSLocalizedString(@"Closest", @"Immediate section header title");
            break;
            
        case CLProximityNear:
            title = NSLocalizedString(@"Near", @"Near section header title");
            break;
            
        case CLProximityFar:
            title = NSLocalizedString(@"Far", @"Far section header title");
            break;
            
        default:
            title = NSLocalizedString(@"Unknown", @"Unknown section header title");
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSNumber *sectionKey = [self.beacons allKeys][indexPath.section];
    
    if (cell == nil) {
		// Create a new reusable table cell
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"];
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
    
    // populate the cell
    if ([self.filteredStops[sectionKey] count]>0){
        TAPStop *stop;
        stop = self.filteredStops[sectionKey][indexPath.row];
        [[cell textLabel] setText:(NSString *)stop.title];
    }

    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *sectionKey = [self.beacons allKeys][indexPath.section];
    TAPStop *stop = self.filteredStops[sectionKey][indexPath.row];
    [self loadStop:stop];
}

#pragma mark Content Filtering

- (void)filterStops:(NSMutableDictionary*)beacons
{
    [self.filteredStops removeAllObjects];
    
    // add stops to the filteredStops dictionary by proximity
    for (NSNumber *range in @[@(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
    {
        // retrieve all beacons of a certain proximity
        NSArray *proximityBeacons = [beacons objectForKey:range];
        NSMutableArray *proximityStops = [NSMutableArray array];
        
        for (int i = 0; i < [proximityBeacons count]; i++)
        {
            CLBeacon *beacon = proximityBeacons[i];
            NSString *beaconMajor = [NSString stringWithFormat:@"%@",beacon.major];
            NSString *beaconMinor = [NSString stringWithFormat:@"%@",beacon.minor];
            
            // use major and minor value of the beacon to find artworks associated with the beacon
            for (TAPStop *stop in self.stops) {
                NSString *stopMajor = [stop getPropertyValueByName:@"beacon_major"];
                NSString *stopMinor = [stop getPropertyValueByName:@"beacon_minor"];
                if ([stopMajor isEqualToString:beaconMajor] && [stopMinor isEqualToString:beaconMinor] ){
                    [proximityStops addObject:stop];
                }
            }
        }
        
        // add the stops of the same proximity to the filteredStops dictionary
        if ([proximityStops count]>0){
            [self.filteredStops setObject:proximityStops forKey:range];
        }
    }
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // range beacons
    self.rangedRegions[region] = beacons;
    
    [self.beacons removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    // put all beacons into a dictionary by proximity
    for (NSNumber *range in @[@(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
    {
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        if([proximityBeacons count])
        {
            self.beacons[range] = proximityBeacons;
        }
    }
    
    if ([self.filteredStops count] == 0){
        [self filterStops:self.beacons];
        [self.stopListTable reloadData];
    }
    
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//#pragma mark determine current location methods
//
//// helper method for determining the closest beacon
//- (void) findClosestBeacon:(NSArray *)beacons
//{
//    NSInteger strongestSignal = -100;
//    CLBeacon *closest;
//    
//	for (CLBeacon *beacon in beacons) {
//        
//		if (beacon.rssi > strongestSignal && beacon.rssi != 0) {
//            // update strongest Signal
//            strongestSignal = beacon.rssi;
//            closest = beacon;
//		}
//	}
//    
//    self.closestBeacon = closest;
//    
//}
//
//// determine the current room the user is in
//- (void) getCurrentLocation:(NSArray *)beacons
//{
//    // first check to see if all values in the array of beacons are unique
//    // if so, use the closest beacon to determine the current location
//    NSSet *uniqueRooms = [NSSet setWithArray:[beacons valueForKey:@"major"]];
//    
//    // finds the closest beacon
//    [self findClosestBeacon:beacons];
//    
//    if ([uniqueRooms count] == [beacons count]) {
//        self.currentRoom = [self.closestBeacon.major stringValue];
//    } else {
//        // put the major values of the beacons into an array
//        NSMutableArray *majors = [NSMutableArray array];
//        for (CLBeacon *beacon in beacons) {
//            [majors addObject:beacon.major];
//        }
//        
//        // get the most common major (room number)
//        self.currentRoom = [[self mostCommonNumber:majors] stringValue];
//    }
//}
//
//// helper method to find the most common number in an array
//- (NSNumber*) mostCommonNumber:(NSMutableArray *) numbers
//{
//    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:numbers];
//    
//    NSNumber *mostOccurring;
//    NSUInteger highest = 0;
//    for (NSNumber *n in countedSet)
//    {
//        if ([countedSet countForObject:n] > highest)
//        {
//            highest = [countedSet countForObject:n];
//            mostOccurring = n;
//        }
//    }
//    
//    return mostOccurring;
//}

@end

