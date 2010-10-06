#import "PollResults.h"


@implementation PollResults

@synthesize pollStop;
@synthesize resultsTable;

#define CHART_BAR_VIEW_TAG  627

-(id)initWithData:(NSData*)data pollStop:(PollStop*)stop
{
    [self setPollStop:stop];

    NSString *resultsFilename = [NSString stringWithFormat:@"poll-results-%@", [pollStop getStopId]];
    NSString *resultsDataPath = [NSString stringWithFormat:@"%@/%@.xml", [[NSBundle mainBundle] resourcePath], resultsFilename];

    // Try to parse the data as xml
    if (data != nil && [data length] > 0) {
		resultDoc = xmlReadMemory([data bytes], [data length], [resultsFilename UTF8String], NULL, 0);
		        
        if (resultDoc != NULL) {
            // we got a good result so save it
            if (![[NSFileManager defaultManager] createFileAtPath:resultsDataPath contents:data attributes:nil]) {
                NSLog(@"Failed to save results file to %@", resultsDataPath);
            }
        } else {
			xmlErrorPtr	theLastErrorPtr = xmlGetLastError();
			NSLog(@"xmlError: %@", [NSString stringWithUTF8String:theLastErrorPtr->message]);
		}
    }
    
    // Try to load an old result if we didn't get a new one
    if (resultDoc == NULL) {
        resultDoc = xmlParseFile([resultsDataPath UTF8String]);
    }
    
    // At this point we should have a good result xml doc
    if (resultDoc == NULL) return nil;
    
    // Count up the total number of responses
    totalResponses = 0;
    for (NSString *answer in [pollStop getAnswers]) {
        totalResponses += [self countForResponse:answer];
    }
    
    return self;
}

-(NSInteger)countForResponse:(NSString*)response
{
   	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
	
	xpathCtx = xmlXPathNewContext(resultDoc);
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create new XPath context.");
		return 0;
    }
	
	NSString *countXPath = [NSString stringWithFormat:@"/Result/vote[@option=\"%@\"]", response];
    NSLog(@"Running xpath expr: %@", countXPath);
	xmlChar *xpathExpr = (xmlChar*)[countXPath UTF8String];
	xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL) {
        NSLog(@"Unable to evaluate xpath expression: %@", xpathExpr);
		xmlXPathFreeContext(xpathCtx);
        return 0;
    }
	if (xmlXPathNodeSetIsEmpty(xpathObj->nodesetval)) {
		NSLog(@"Unable to find matching node.");
        xmlXPathFreeContext(xpathCtx);
		xmlXPathFreeObject(xpathObj);
        return 0;
	}
	
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) {
		xmlNodePtr voteOption = xpathObj->nodesetval->nodeTab[i];
        
		char *value = (char*)xmlGetProp(voteOption, (xmlChar*)"value");
        NSString *count = [NSString stringWithUTF8String:value];
		free(value);
		
		// Make sure we clean up before returning
		xmlXPathFreeContext(xpathCtx);
		xmlXPathFreeObject(xpathObj);
        
		return [count intValue];
	}
    	
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);
	
	return 0;
}

-(UITableView*)getResultsTableWithFrame:(CGRect)frame
{
    if (resultsTable != nil) return resultsTable;

    // Add a little left padding
    frame.size.width -= 10;
    
    resultsTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    [resultsTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main.png"]]];
    [resultsTable setDelegate:self];
    [resultsTable setDataSource:self];
	[resultsTable setAutoresizesSubviews:YES];
	[resultsTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
    return resultsTable;
}

- (void)flipAnimationDidStop:(NSString*)animationID finished:(NSNumber *)finished context:(void*)context
{
    NSLog(@"Animation results flip finished");
    
    // Animate in the bar charts of the graph
    NSArray *answers = [pollStop getAnswers];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.5f];
    
    for (int idx = 0; idx < [answers count]; idx++) {
        UITableViewCell *cell = [resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        float percent = [self countForResponse:[answers objectAtIndex:idx]] / (float)totalResponses;
        
        UIView *chartBar = [cell viewWithTag:CHART_BAR_VIEW_TAG];
        CGRect newFrame = CGRectMake([chartBar frame].origin.x,
                                     [chartBar frame].origin.y,
                                     [[cell contentView] frame].size.width * percent,
                                     [chartBar frame].size.height);
        chartBar.frame = newFrame;
    }
    
    [UIView commitAnimations];
	
	//[self release]; // we're done with this result instance
}


-(void)dealloc
{
    xmlFreeDoc(resultDoc);
    [pollStop release];
    [resultsTable release]; 
    
    [super dealloc];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"Results", @"Table header for poll results");
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [pollStop numberOfAnswers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger idx = [indexPath row];

	NSString *cellIdent = [NSString stringWithFormat:@"poll-result-%@-%d", [pollStop getStopId], idx];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		//[cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[[cell contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		
		// Set the title
        NSArray *answers = [pollStop getAnswers];
        float percent = [self countForResponse:[answers objectAtIndex:idx]] / (float)totalResponses;
        NSString *txt = [NSString stringWithFormat:@"%.0f%% %@", percent * 100, [answers objectAtIndex:idx]];
		[[cell textLabel] setText:txt];
		[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
		//NSLog(@"%@", [cell bounds]);
        
        // Add a chart bar to the background
        CGRect chartBarFrame = CGRectMake([[cell contentView] frame].origin.x,
                                          [[cell contentView] frame].origin.y,
                                          0.0f, // Will be animated
                                          [[cell contentView] frame].size.height);
        UIView *chartBar = [[[UIView alloc] initWithFrame:chartBarFrame] autorelease];
        [chartBar setTag:CHART_BAR_VIEW_TAG];
		[chartBar setAutoresizesSubviews:YES];
		[chartBar setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        
        [[cell contentView] addSubview:chartBar];
        [[cell contentView] sendSubviewToBack:chartBar];
        [[cell contentView] setClipsToBounds:YES];
		
		// Add the bar chart images
		UIImageView *barLeft = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-poll-bar-left.png"]] autorelease];
		UIImageView *barMiddle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-poll-bar-middle.png"]] autorelease];
		UIImageView *barRight = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-poll-bar-right.png"]] autorelease];
		
		[barLeft setAutoresizingMask:UIViewAutoresizingNone];
		[barLeft setFrame:CGRectMake(4.0f, 2.0f, CGRectGetWidth([barLeft frame]), CGRectGetHeight([barLeft frame]))];
		[barMiddle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[barMiddle setFrame:CGRectMake(12.0f, 2.0f, CGRectGetWidth([barMiddle frame]), CGRectGetHeight([barMiddle frame]))];
		[barRight setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		[barRight setFrame:CGRectMake(13.0f, 2.0f, CGRectGetWidth([barRight frame]), CGRectGetHeight([barRight frame]))];
		
		[chartBar addSubview:barLeft];
		[chartBar addSubview:barMiddle];
		[chartBar addSubview:barRight];
	}
	
	return cell;
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil; // disallow selections
}

@end
