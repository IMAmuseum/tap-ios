//
//  StopGroupController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StopGroupController.h"
#import "AppDelegate.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPConnection.h"

#define PAUSE_ICON @"icon-pause-btn.png"
#define PLAY_ICON @"icon-play-btn.png"
#define HEADER_IMAGE_VIEW_TAG 8637
#define AUDIO_CONTROL_VIEW 2
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@interface StopGroupController ()
- (IBAction)togglePlay;
- (IBAction)moveScurbber:sender;
- (IBAction)toggleAudioControl:(id)sender;
- (void)updateTime;
@end

@implementation StopGroupController

@synthesize stopGroupTable = _stopGroupTable;
@synthesize bannerImage = _bannerImage;
@synthesize stopGroup = _stopGroup;
@synthesize stops = _stops;
@synthesize audioPlayer = _audioPlayer;
@synthesize audioScrubber = _audioScrubber;
@synthesize pausePlayButton = _pausePlayButton;
@synthesize currentTime = _currentTime;
@synthesize trackDuration = _trackDuration;
@synthesize trackTitle = _trackTitle;
@synthesize playbackTimer = _playbackTimer;

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if(self) {
        [self setTitle:(NSString *)stop.title];
        [self setStopGroup:stop];
        
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *connections = [[stop.sourceConnection allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        
        _stops = [[NSMutableArray alloc] init];
        for (TAPConnection *connection in connections) {
            [_stops addObject:connection.destinationStop];
        }
        
        // add appropriate audio views
        NSArray *assets = [_stopGroup getAssetsByUsage:@"tour_audio"];
        if ([assets count]) {
            TAPAsset *audioAsset = [assets objectAtIndex:0];
            if (audioAsset != nil) {
                UIButton *musicControlView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 16, 16)];
                [musicControlView addTarget:self action:@selector(toggleAudioControl:) forControlEvents:UIControlEventTouchUpInside];
                [musicControlView setBackgroundImage: [UIImage imageNamed:@"icon-audio-btn.png"] forState: UIControlStateNormal];
                UIBarButtonItem *audioControlToggle = [[UIBarButtonItem alloc] initWithCustomView:musicControlView];
                [[self navigationItem] setRightBarButtonItem:audioControlToggle];
                [musicControlView release];
                [audioControlToggle release];
                                
                NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"AudioControlView" owner:self options:nil];
                [self.view addSubview:[screens objectAtIndex:0]];
            }
        }
    }
	
	return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Set the table background image
	[self.stopGroupTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main-tile.png"]]];

    TAPAsset *headerAsset = [[_stopGroup getAssetsByUsage:@"header_image"] objectAtIndex:0];
    if (headerAsset != nil) {
        NSString *headerImageSrc = [[[headerAsset source] anyObject] uri];
        UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:headerImageSrc]];
		[headerImage setTag:HEADER_IMAGE_VIEW_TAG];
		[_stopGroupTable setTableHeaderView:headerImage];
		[headerImage release];
    }
    
    // determine whether or not the stop group has a description in order to layout the table correctly
    if ((NSString *)_stopGroup.desc != nil) {
        sectionsEnabled = true;
    } else {
        sectionsEnabled = false;
    }
    
    // add audio controls if audio is available
    NSArray *assets = [_stopGroup getAssetsByUsage:@"tour_audio"];
    if ([assets count]) {
        TAPAsset *audioAsset = [assets objectAtIndex:0];
        if (audioAsset != nil) {           
            // handle the audio controls
            [_audioScrubber setThumbImage:[UIImage imageNamed:@"slider-button.png"] forState:UIControlStateNormal];
            _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            [_pausePlayButton setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
            
            dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(dispatchQueue, ^(void) {
                NSError *error;
                NSURL *audioUrl = [NSURL fileURLWithPath:[[[audioAsset source] anyObject] uri]];
                _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
                if (error) {
                    NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
                } else {
                    // update audio control on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        float minutes = floor(_audioPlayer.duration / 60);
                        float seconds = _audioPlayer.duration - (minutes * 60);
                        NSString *duration = [[NSString alloc] initWithFormat:@"%0.0f:%02.0f", minutes, seconds];
                        [_trackDuration setText:duration];
                        [duration release];
                        
                        [_audioScrubber setMaximumValue:(int)[_audioPlayer duration] - 1];
                        [_audioScrubber setMinimumValue:0.0f];
                        [_audioScrubber setValue:0.0f];
                        
                        [_audioPlayer setDelegate:self];
                        if ([_audioPlayer prepareToPlay] && [_audioPlayer play]) {
                            [_pausePlayButton setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
                        }
                        [self hideAudioControl];
                    });
                }
            });
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // Deselect anything from the table
	[_stopGroupTable deselectRowAtIndexPath:[_stopGroupTable indexPathForSelectedRow] animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![[self.navigationController viewControllers] containsObject:self]) {
        [_audioPlayer stop];
    }
}

#pragma mark AudioControls
- (IBAction)togglePlay
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        [_pausePlayButton setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
        [_playbackTimer invalidate];
    } else {
        [_audioPlayer play];
        [_pausePlayButton setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
        _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

- (IBAction)moveScurbber:sender
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        [_audioPlayer setCurrentTime:_audioScrubber.value];
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        [_audioPlayer setCurrentTime:_audioScrubber.value];
        [_audioPlayer prepareToPlay];
        [self updateTime];
    }
}

- (void)updateTime
{
    float minutes = floor(_audioPlayer.currentTime / 60);
    float seconds = _audioPlayer.currentTime - (minutes * 60);
    
    NSString *duration = [[NSString alloc] initWithFormat:@"%0.0f:%02.0f", minutes, seconds];
    [_currentTime setText:duration];
    [duration release];
    
    [_audioScrubber setValue:_audioPlayer.currentTime];
}

- (void)hideAudioControl
{
    UIView *controlView = [self.view viewWithTag:AUDIO_CONTROL_VIEW];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [controlView setAlpha:0.0f];
    [UIView commitAnimations];
}

- (IBAction)toggleAudioControl:(id)sender
{
    UIView *controlView = [self.view viewWithTag:AUDIO_CONTROL_VIEW];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    if ([controlView alpha] == 0.0f) {
        [controlView setAlpha:1.0f];
    } else {
        [controlView setAlpha:0.0f];
    }
    
    [UIView commitAnimations];
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [_pausePlayButton setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
    }
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
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
        return [self.stops count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 1 || !sectionsEnabled) {
        TAPStop *stop = [self.stops objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-cell"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"] autorelease];
            
            [[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
            [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        // Set the title
        [[cell textLabel] setText:(NSString *)stop.title];
        [[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
        [[cell textLabel] setNumberOfLines:0];
        
        // Set the associated icon
        [[cell imageView] setImage:[UIImage imageWithContentsOfFile:[stop getIconPath]]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-group-description"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-group-description"] autorelease];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:13]];
        }
        
        // Set the stop group description
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell textLabel] setText:(NSString *)_stopGroup.desc];
        [[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
        [[cell textLabel] setNumberOfLines:0];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    CGSize constraint;
    
    if (indexPath.section == 1 || !sectionsEnabled) {
        TAPStop *stop = [stops objectAtIndex:indexPath.row];
        
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - CELL_DISCLOSURE_WIDTH - CELL_INDENTATION, 20000.0f);
        
        NSString *title = (NSString *)stop.title;
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        NSString *description = (NSString *)stop.desc;
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(titleSize.height + descriptionSize.height, 44.0f);
    } else {
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        NSString *description = (NSString *)_stopGroup.desc;
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        height = MAX(descriptionSize.height, 44.0f);
    }
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if (indexPath.section == 1 || !sectionsEnabled) {
        TAPStop *stop = [_stops objectAtIndex:indexPath.row];
        if (![stop.view isEqualToString:@"tour_image_stop"]) {
            [_audioPlayer stop];
        }
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] loadStop:stop];
    }
}

- (void)dealloc 
{
    [_stopGroupTable release];
    [_bannerImage release];
    [_stopGroup release];
    [_stops release];
    [_audioPlayer release];
    [_audioScrubber release];
    [_pausePlayButton release];
    [_currentTime release];
    [_trackDuration release];
    [_trackTitle release];
    [super dealloc];
}

@end