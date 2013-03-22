//
//  MapViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 3/21/13.
//
//

#import "MapViewController.h"
#import "MKMapView+ZoomLevel.h"

@interface MapViewController ()
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@""];
        [self.tabBarItem setTitle:NSLocalizedString(@"Map", @"")];
        [self.tabBarItem setImage:[UIImage imageNamed:@"map"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(39.8273, -86.1892) zoomLevel:16 animated:YES];
    [self.view addSubview:self.mapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
