//
//  BeaconDiagnosticViewController.h
//  Tap
//
//  Created by Kyle Jaebker on 1/18/15.
//
//

#import <UIKit/UIKit.h>

@interface BeaconDiagnosticViewController : UITableViewController

@property (nonatomic, strong) NSMutableDictionary *beaconData;
@property (nonatomic, strong) NSMutableArray * displayBeacons;

@end
