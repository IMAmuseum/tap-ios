//
//  TourNavigationTabBarControllerViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 3/20/13.
//
//

#import "TourTabBarViewController.h"
#import "StopNavigationViewController.h"
#import "AppDelegate.h"
#import "TAPTour.h"

@interface TourTabBarViewController ()
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation TourTabBarViewController

- (id)init
{
    self = [super init];
    if(self) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

        NSMutableArray *tabBarControllers = [[NSMutableArray alloc] init];
        
        NSDictionary *tourConfig = [appDelegate.tapConfig objectForKey:@"TourConfig"];
        NSDictionary *currentTourConfig = [tourConfig objectForKey:appDelegate.currentTour.id];
        NSArray *availableStopControllers = [currentTourConfig objectForKey:@"EnabledViewControllers"];
        for (NSString *className in availableStopControllers) {
            StopNavigationViewController *viewController = [[NSClassFromString(className) alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [tabBarControllers addObject:navigationController];
        }
        
        self.tabBarController = [[UITabBarController alloc] init];
        [self.tabBarController setDelegate:self];
        [self.tabBarController setViewControllers:tabBarControllers];
        [self.view addSubview:self.tabBarController.view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
