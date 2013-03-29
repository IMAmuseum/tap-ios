//
//  StopListController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "StopListViewController.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"

@interface StopListViewController()
@property (nonatomic, unsafe_unretained) IBOutlet UITableView *stopListTable;
@property (nonatomic, strong) NSMutableArray *filteredStops;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@end

@implementation StopListViewController

-(id)init 
{
    self = [super init];
    if(self) {
        [self setTitle:NSLocalizedString(@"Select a Stop", @"")];
        [self.tabBarItem setTitle:NSLocalizedString(@"Stop List", @"")];
        [self.tabBarItem setImage:[UIImage imageNamed:@"list"]];
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
    
    self.filteredStops = [NSMutableArray arrayWithCapacity:[self.stops count]];
    
    if (self.savedSearchTerm) {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];        
        self.savedSearchTerm = nil;
    }
    [self.stopListTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // reload the table with the correct tour data
    [self.stopListTable reloadData];
    
    // Deselect anything from the table
	[self.stopListTable deselectRowAtIndexPath:[self.stopListTable indexPathForSelectedRow] animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.filteredStops = nil;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredStops count];
    } else {
        return [self.stops count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stop-cell"];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"];
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    TAPStop *stop;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        stop = [self.filteredStops objectAtIndex:indexPath.row];
    } else {
        stop = [self.stops objectAtIndex:indexPath.row];
    }
    [[cell textLabel] setText:(NSString *)stop.title];
    
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self loadStop:[self.filteredStops objectAtIndex:indexPath.row]];
    } else {
        [self loadStop:[self.stops objectAtIndex:indexPath.row]];
    }
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.filteredStops removeAllObjects];
    
    for (TAPStop *stop in self.stops) {
        NSComparisonResult result = [(NSString *)stop.title compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame) {
            [self.filteredStops addObject:stop];
        }
    }
}

#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
