#import "StopGroupController.h"

#import "TapAppDelegate.h"

#define HEADER_IMAGE_VIEW_TAG	8637
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

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
    
    if ([stopGroup getDescription] != nil) {
        sectionsEnabled = true;
    } else {
        sectionsEnabled = false;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (!sectionsEnabled) return @"";
    
    if(section == 0) {
        return [stopGroup getTitle];
    } else {
        return @"Find Out More";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (sectionsEnabled) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1 || !sectionsEnabled) {
        return [[self stopGroup] numberOfStops];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 1 || !sectionsEnabled) {
        NSUInteger idx = [indexPath row];
        BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-cell"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"] autorelease];
            
            [[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
            [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        cell.indentationWidth = CELL_INDENTATION;
        cell.indentationLevel = 1;
        
        // Set the title
        [[cell textLabel] setText:[refStop getTitle]];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        
        // Set the description if available
        [[cell detailTextLabel] setText:[refStop getDescription]];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
        
        // Set the associated icon
        UIImage *icon = [[UIImage alloc] initWithContentsOfFile:[refStop getIconPath]];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        [iconView setFrame:CGRectMake(20, 10, icon.size.width, icon.size.height)];
        [cell addSubview:iconView];
        
        [iconView release];
        [icon release];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-group-description"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-group-description"] autorelease];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:12]];
        }
        
        // Set the title
        [[cell textLabel] setText:[stopGroup getDescription]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    CGSize constraint;

    if (indexPath.section == 1 || !sectionsEnabled) {
        NSUInteger idx = [indexPath row];
        BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
        
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - CELL_DISCLOSURE_WIDTH - CELL_INDENTATION, 20000.0f);
        
        NSString *title = [refStop getTitle];
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        NSString *details = [refStop getDescription];
        CGSize detailsSize = [details sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(titleSize.height + detailsSize.height, 44.0f);
    } else {
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        NSString *description = [stopGroup getDescription];
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        height = MAX(descriptionSize.height, 44.0f);
    }

    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if (indexPath.section == 1 || !sectionsEnabled) {
     	NSUInteger idx = [indexPath indexAtPosition:1];
        BaseStop *refStop = [[self stopGroup] stopAtIndex:idx];
        
        [(TapAppDelegate*)[[UIApplication sharedApplication] delegate] loadStop:refStop];   
    }
}

@end
