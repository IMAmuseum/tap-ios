//
//  TourCell.m
//  Tap
//
//  Created by Daniel Cervantes on 11/20/12.
//
//

#import "TourCell.h"

@implementation TourCell

@synthesize tourImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [tourImage release];
    [super dealloc];
}

@end
