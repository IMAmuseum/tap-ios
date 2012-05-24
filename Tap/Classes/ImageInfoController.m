//
//  ImageInfoController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageInfoController.h"
#import "ImageStopController.h"

#define HEADER_IMAGE_VIEW_TAG	8637
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@interface ImageInfoController ()

@end

@implementation ImageInfoController

@synthesize delegate;
@synthesize infoTable;
@synthesize caption;
@synthesize creditLine;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Deselect anything from the table
	[infoTable deselectRowAtIndexPath:[infoTable indexPathForSelectedRow] animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [caption release];
    [creditLine release];
    
	[super dealloc];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if(section == 0 && caption != nil) {
        return @"Caption";
    } else if (creditLine != nil) {
        return @"Credit";
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    numberOfSections = 0;
    if (caption != nil) {
        numberOfSections++;
    }
    if (creditLine != nil) {
        numberOfSections++;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        // Create a new reusable table cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:12]];
    }
    
    // Set the content
    if(caption != nil && indexPath.section == 0) {
        [[cell textLabel] setText:caption];        
    } else {
        [[cell textLabel] setText:creditLine];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    NSString *content;
    if(caption != nil && indexPath.section == 0) {
        content = [[NSString alloc] initWithString:caption];      
    } else {
        content = [[NSString alloc] initWithString:creditLine];
    }
    
    CGSize descriptionSize = [content sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(descriptionSize.height, 22.0f);
    [content release];
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate imageInfoControllerDidFinish:self];
}

@end
