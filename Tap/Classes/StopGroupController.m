#import "StopGroupController.h"

#import "TapAppDelegate.h"

#define HEADER_IMAGE_VIEW_TAG	8637

@implementation StopGroupController

@synthesize stopTable;
@synthesize bannerImage;

@synthesize stopGroup;

- (id)initWithStopGroup:(StopGroup*)stop
{
	if (self = [super initWithNibName:@"StopGroup" bundle:[NSBundle mainBundle]]) {
		[self setStopGroup:stop];
		[self setTitle:[stopGroup getTitle]];
	}
	
	return self;
}

- (void)dealloc
{
	[stopGroup release];
	
	[super dealloc];
}

#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSString *headerImageSrc = nil;
	
	// Update the banner image
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[bannerImage setImage:[UIImage imageNamed:@"bg-header.png"]];
		headerImageSrc = [stopGroup getHeaderPortraitImage];
		
		[Analytics trackAction:@"rotate-portrait" forStop:[stopGroup getStopId]];
	}
	else
	{
		[bannerImage setImage:[UIImage imageNamed:@"bg-header-wide.png"]];
		headerImageSrc = [stopGroup getHeaderLandscapeImage];
		
		[Analytics trackAction:@"rotate-landscape" forStop:[stopGroup getStopId]];
	}
	
	UIView *headerImage = [[stopTable tableHeaderView] viewWithTag:HEADER_IMAGE_VIEW_TAG];
	if (headerImage != nil) [headerImage removeFromSuperview];
	
	if (headerImageSrc != nil) {
		NSBundle *tourBundle = [((TapAppDelegate*)[[UIApplication sharedApplication] delegate]) tourBundle];
		NSString *headerPath = [tourBundle pathForResource:[[headerImageSrc lastPathComponent] stringByDeletingPathExtension]
													ofType:[[headerImageSrc lastPathComponent] pathExtension]
											   inDirectory:[headerImageSrc stringByDeletingLastPathComponent]];
		
		UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:headerPath]];
		[headerImage setTag:HEADER_IMAGE_VIEW_TAG];
		
		[stopTable setTableHeaderView:headerImage];
		[headerImage release];
	}
}

- (void)viewDidLoad
{
	// Set the table background image
	[stopTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main-tile.png"]]];
	
	// Add the table header image if one was provided
	NSString *headerImageSrc = nil;
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait) {
		headerImageSrc = [stopGroup getHeaderPortraitImage];
	} else {
		headerImageSrc = [stopGroup getHeaderLandscapeImage];
	}
	
	if (headerImageSrc != nil) {
		NSBundle *tourBundle = [((TapAppDelegate*)[[UIApplication sharedApplication] delegate]) tourBundle];
		NSString *headerPath = [tourBundle pathForResource:[[headerImageSrc lastPathComponent] stringByDeletingPathExtension]
													ofType:[[headerImageSrc lastPathComponent] pathExtension]
											   inDirectory:[headerImageSrc stringByDeletingLastPathComponent]];
		
		UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:headerPath]];
		[headerImage setTag:HEADER_IMAGE_VIEW_TAG];
		
		[stopTable setTableHeaderView:headerImage];
		[headerImage release];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	// Deselect anything from the table
	[stopTable deselectRowAtIndexPath:[stopTable indexPathForSelectedRow] animated:animated];
	
	[self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:0.0];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[stopTable flashScrollIndicators];
	[stopTable setNeedsDisplay];
	
	[super viewDidAppear:animated];
}

#pragma mark UITableViewDataSource

/**
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self stopGroup] getTitle];
}
**/

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self stopGroup] numberOfStops];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger idx = [indexPath row];
	BaseStop *refStop = [[[self stopGroup] stopAtIndex:idx] autorelease];
	NSString *cellIdent = [NSString stringWithFormat:@"stop-cell-%d", idx];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdent] autorelease];
		
		// Set the title
		[[cell textLabel] setText:[refStop getTitle]];
		
		
		// Set the description if available
		[[cell detailTextLabel] setText:[refStop getDescription]];
		//[[cell detailTextLabel] setLineBreakMode:UILineBreakModeWordWrap];
		//[[cell detailTextLabel] setNumberOfLines:0];

		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		//[[cell detailTextLabel] setNumberOfLines:2];
		
		// Set the associated icon
		[[cell imageView] setImage:[UIImage imageWithContentsOfFile:[refStop getIconPath]]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
	return cell;
}

#pragma mark UITableViewDelegate

/**
 * ref: http://www.iphonedevsdk.com/forum/iphone-sdk-development/3739-how-should-i-display-detail-view-variable-length-strings.html
 */
/**
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger idx = [indexPath row];
	BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
		
	CGFloat result = 44.0f;
	NSString *text = [refStop getDescription];
	CGFloat width = 0;
	CGFloat tableViewWidth;
	CGRect bounds = [UIScreen mainScreen].bounds;
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		tableViewWidth = bounds.size.width;
	} else {
		tableViewWidth = bounds.size.height;
	}
	width = tableViewWidth - 110;		// fudge factor
	
	if (text) {
		// The notes can be of any height
		// This needs to work for both portrait and landscape orientations.
		// Calls to the table view to get the current cell and the rect for the 
		// current row are recursive and call back this method.
		CGSize textSize = { width, 20000.0f };		// width and height of text area
		CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
		
		size.height += 29.0f;			// top and bottom margin
		result = MAX(size.height, 44.0f);	// at least one row
	}
	
	NSLog(@"Calculated row height of %.0f for text: %@", result, text);
	
	return result;
}
 **/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSUInteger idx = [indexPath indexAtPosition:1];
	BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
	
	[(TapAppDelegate*)[[UIApplication sharedApplication] delegate] loadStop:refStop];
}

@end
