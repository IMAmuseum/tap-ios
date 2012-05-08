#import "StopGroupController.h"

#import "TapAppDelegate.h"

#define HEADER_IMAGE_VIEW_TAG	8637
#define CELL_CONTENT_MARGIN 50.0f
#define CELL_PADDING 40.0f

@implementation StopGroupController

@synthesize stopTable;
@synthesize bannerImage;

@synthesize stopGroup;

- (id)initWithStopGroup:(StopGroup*)stop
{
	if ((self = [super initWithNibName:@"StopGroup" bundle:[NSBundle mainBundle]])) {
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

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self stopGroup] numberOfStops];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger idx = [indexPath row];
	BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
	//NSString *cellIdent = [NSString stringWithFormat:@"stop-cell-%d", idx];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stop-cell"];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"] autorelease];
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    // Set the title
    [[cell textLabel] setText:[refStop getTitle]];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    
    // Set the description if available
    [[cell detailTextLabel] setText:[refStop getDescription]];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 0;
    
    // Set the associated icon
    [[cell imageView] setImage:[UIImage imageWithContentsOfFile:[refStop getIconPath]]];
    
    [refStop release];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSUInteger idx = [indexPath row];
	BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
    
    CGSize constraint = CGSizeMake(320.0f - CELL_CONTENT_MARGIN * 2, 20000.0f);
    
    NSString *titleText = [refStop getTitle];
    CGSize titleSize = [titleText sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

    NSString *detailText = [refStop getDescription];
    CGSize detailSize = [detailText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(titleSize.height + detailSize.height + CELL_PADDING, CELL_PADDING);
    return height;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSUInteger idx = [indexPath indexAtPosition:1];
	BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
	
	[(TapAppDelegate*)[[UIApplication sharedApplication] delegate] loadStop:refStop];
}

@end
