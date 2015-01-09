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
        
        TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapBeaconRanged:)
                                                     name:@"TAPBeaconRanged"
                                                   object:beaconManager];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    [beaconManager startLocationServicesForTour:appDelegate.currentTour];
    NSLog(@"Location!!!");
    

//    // initialize the timer
//    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
//                                                      selector: @selector(callAfterTenSecond:) userInfo: nil repeats: YES];
//    
//    [self.stopListTable reloadData];

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

- (void)tapBeaconRanged:(NSNotification *)notification {
    NSLog(@"Got the notification");
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

