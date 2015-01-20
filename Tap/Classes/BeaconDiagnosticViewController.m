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

@property (nonatomic, strong) NSMutableDictionary *regionStatus;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapEnteredRegion:)
                                                     name:@"TAPEnteredRegion"
                                                   object:beaconManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapExitedRegion:)
                                                     name:@"TAPExitedRegion"
                                                   object:beaconManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapDeterminedRegionState:)
                                                     name:@"TAPDeterminedRegionState"
                                                   object:beaconManager];
        
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    
    self.regionStatus = [[NSMutableDictionary alloc] init];
    for (CLBeaconRegion *br in beaconManager.regions) {
        [self.regionStatus setObject:@"unknown" forKey:[NSString stringWithFormat:@"%@-%@", [br.proximityUUID UUIDString], br.major]];
    }
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
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    return [beaconManager.regions count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    return [[beaconManager getBeaconsForRegion:[beaconManager.regions objectAtIndex:section]] count];
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
    }
    
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    TapBeacon *beacon = [[beaconManager getBeaconsForRegion:[beaconManager.regions objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    // populate the cell
    [[cell textLabel] setText:beacon.name];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"prox: %@ | acc: %f | rssi: %ld", [beacon proximityToString], beacon.beacon.accuracy, (long)beacon.beacon.rssi]];
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Region %ld", (long)section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TapBeaconManager *beaconManager = [TapBeaconManager sharedInstance];
    CLBeaconRegion *br = [beaconManager.regions objectAtIndex:section];
    NSString *status = [self.regionStatus objectForKey:[NSString stringWithFormat:@"%@-%@", [[br proximityUUID] UUIDString], br.major]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 36)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 6, tableView.frame.size.width - 15, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    NSString *string = [NSString stringWithFormat:@"Region %ld", (long)section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 26, tableView.frame.size.width - 15, 18)];
    [statusLabel setFont:[UIFont systemFontOfSize:12]];
    
    NSString *statusText = [NSString stringWithFormat:@"Status: %@", status];
    /* Section header is in 0th index... */
    [statusLabel setText:statusText];
    [view addSubview:statusLabel];
    
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tapBeaconRanged:(NSNotification *)notification
{
    if ([notification.userInfo count]) {
        [self.tableView reloadData];
    }
}

- (void)tapEnteredRegion:(NSNotification *)notification
{
    if ([notification.userInfo count]) {
        CLBeaconRegion *region = (CLBeaconRegion *)[notification.userInfo objectForKey:@"region"];
        NSString *updateId = [NSString stringWithFormat:@"%@-%@", [region.proximityUUID UUIDString], region.major];
        
        for (NSString *regionId in self.regionStatus) {
            if ([regionId isEqualToString:updateId]) {
                [self.regionStatus setObject:@"Entered" forKey:regionId];
                break;
            }
        }
        [self.tableView reloadData];
    }
}

- (void)tapExitedRegion:(NSNotification *)notification
{
    if ([notification.userInfo count]) {
        CLBeaconRegion *region = (CLBeaconRegion *)[notification.userInfo objectForKey:@"region"];
        NSString *updateId = [NSString stringWithFormat:@"%@-%@", [region.proximityUUID UUIDString], region.major];
        
        for (NSString *regionId in self.regionStatus) {
            if ([regionId isEqualToString:updateId]) {
                [self.regionStatus setObject:@"Exited" forKey:regionId];
                break;
            }
        }
        [self.tableView reloadData];
    }
}

- (void)tapDeterminedRegionState:(NSNotification *)notification
{
    if ([notification.userInfo count]) {
        CLBeaconRegion *region = (CLBeaconRegion *)[notification.userInfo objectForKey:@"region"];
        NSString *updateId = [NSString stringWithFormat:@"%@-%@", [region.proximityUUID UUIDString], region.major];
        
        for (NSString *regionId in self.regionStatus) {
            if ([regionId isEqualToString:updateId]) {
                [self.regionStatus setObject:[notification.userInfo objectForKey:@"state"] forKey:regionId];
                break;
            }
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
