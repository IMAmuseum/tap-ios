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
#import "TAPAsset.h"
#import "TAPContent.h"
#import "GDataXMLNode.h"
#import "TapBeaconManager.h"
#import "TapBeacon.h"

@interface BeaconTableViewController ()

@property (nonatomic) BOOL displayBeaconData;

@end

@implementation BeaconTableViewController

-(id)init
{
    self = [super init];
    if(self) {
        [self setTitle:NSLocalizedString(@"Artwork Nearby", @"")];
        [self.tabBarItem setTitle:NSLocalizedString(@"Nearby", @"")];
        [self.tabBarItem setImage:[UIImage imageNamed:@"near"]];
        
        TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapBeaconRanged:)
                                                     name:@"TAPBeaconRanged"
                                                   object:beaconManager];
        
        self.displayBeaconData = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // retrieve the current tour's stops
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(propertySet, $ps, $ps.name = 'beacon_id' AND $ps.value != nil AND ($ps.language == %@ OR $ps.language == nil)).@count > 0", appDelegate.language];
    NSSet *filteredStops = [[NSSet alloc] initWithSet:[appDelegate.currentTour.stop filteredSetUsingPredicate:predicate]];
    self.stops = [[NSArray alloc] initWithArray:[filteredStops allObjects]];
    
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    [beaconManager startLocationServicesForTour:appDelegate.currentTour];
    
    self.displayStops = [[NSMutableDictionary alloc] init];
    [self.displayStops setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:CLProximityImmediate]];
    [self.displayStops setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:CLProximityNear]];

    [self.displayStops setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:CLProximityFar]];
    [self.displayStops setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:CLProximityUnknown]];
    
    self.beaconData = [[NSMutableDictionary alloc] init];
    
    [self.stopListTable reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    [beaconManager startMonitoringAndRangingBeacons];
    
    // Deselect anything from the table
	[self.stopListTable deselectRowAtIndexPath:[self.stopListTable indexPathForSelectedRow] animated:animated];
    
    // reload the table with the correct tour data
    [self.stopListTable reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    [beaconManager stopLocationServicesForTour:appDelegate.currentTour];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    [beaconManager stopLocationServicesForTour:appDelegate.currentTour];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.displayStops.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionValues = [self.displayStops allValues];
    return [sectionValues[section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSArray *sectionKeys = [self.displayStops allKeys];
    
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
    NSNumber *sectionKey = [self.displayStops allKeys][indexPath.section];
    
    if (cell == nil) {
		// Create a new reusable table cell
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"];
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
    
    // populate the cell
    if ([self.displayStops[sectionKey] count] > 0){
        TAPStop *stop = self.displayStops[sectionKey][indexPath.row];
        [[cell textLabel] setText:(NSString *)stop.title];
        
        if (self.displayBeaconData) {
            BOOL foundBeacon = NO;
            for (id tbId in self.beaconData) {
                TapBeacon *tb = [self.beaconData objectForKey:tbId];
                if ([tb.stopIds containsObject:stop.id]) {
                    
                    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"prox: %@ | acc: %f | rssi: %ld", [tb proximityToString], tb.beacon.accuracy, (long)tb.beacon.rssi]];
                    foundBeacon = YES;
                    break;
                }
            }
            
            if (!foundBeacon) {
                [[cell detailTextLabel] setText:@"Not in range"];
            }
        }
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;

    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *sectionKey = [self.displayStops allKeys][indexPath.section];
    TAPStop *stop = self.displayStops[sectionKey][indexPath.row];
    
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    if (beaconManager.sendAnalytics) {
        [beaconManager sendBeaconInteractionData:@"entered" stopId:stop.id];
    }
    
    [self loadStop:stop];
}

- (void)tapBeaconRanged:(NSNotification *)notification {
    if ([notification.userInfo count]) {
        for (id key in self.displayStops) {
            [[self.displayStops objectForKey:key] removeAllObjects];
        }
        
        [self.beaconData addEntriesFromDictionary:notification.userInfo];
        
//        self.beaconData = notification.userInfo;
        
        for (TAPStop *stop in self.stops) {
            NSArray *stopBeaconIds = [stop getPropertyValuesByName:@"beacon_id"];
            BOOL foundBeacon = NO;
            for (NSString *stopBeaconId in stopBeaconIds) {
                TapBeacon *tb = [self.beaconData objectForKey:[NSNumber numberWithInteger:[stopBeaconId integerValue]]];
                if (tb != nil) {
                    [[self.displayStops objectForKey:[NSNumber numberWithInteger:tb.beacon.proximity]] addObject:stop];
                    foundBeacon = YES;
                    break;
                }
            }
            
            if (!foundBeacon) {
                [[self.displayStops objectForKey:[NSNumber numberWithInteger:CLProximityUnknown]] addObject:stop];
            }
        }
        
        [self.stopListTable reloadData];
    }
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

