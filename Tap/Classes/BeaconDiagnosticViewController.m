//
//  BeaconDiagnosticViewController.m
//  Tap
//
//  Created by Kyle Jaebker on 1/18/15.
//
//

#import "BeaconDiagnosticViewController.h"
#import "TapBeaconManager.h"
#import "TapBeacon.h"
#import "AppDelegate.h"

@interface BeaconDiagnosticViewController ()

@end

@implementation BeaconDiagnosticViewController

-(id)init
{
    self = [super init];
    if(self) {
        [self setTitle:NSLocalizedString(@"Beacons", @"")];
        [self.tabBarItem setTitle:NSLocalizedString(@"Beacons", @"")];
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
    
    self.beaconData = [[NSMutableDictionary alloc] init];
    self.displayBeacons = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    [beaconManager startMonitoringAndRangingBeacons];
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
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayBeacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        // Create a new reusable table cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"];
        
        [[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
        [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
        
//        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    TapBeacon *beacon = [self.displayBeacons objectAtIndex:indexPath.item];
    
    // populate the cell
    [[cell textLabel] setText:beacon.name];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"prox: %@ | acc: %f | rssi: %ld", [beacon proximityToString], beacon.beacon.accuracy, (long)beacon.beacon.rssi]];
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tapBeaconRanged:(NSNotification *)notification {
    if ([notification.userInfo count]) {
        [self.beaconData addEntriesFromDictionary:notification.userInfo];

        [self.displayBeacons removeAllObjects];
        
        for (id bId in self.beaconData) {
            [self.displayBeacons addObject:[self.beaconData objectForKey:bId]];
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
