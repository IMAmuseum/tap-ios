#import <UIKit/UIKit.h>

#import "StopFactory.h"
#import "StopGroup.h"

@interface StopGroupController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UITableView *stopTable;
	IBOutlet UIImageView *bannerImage;
	
	StopGroup *stopGroup;

}

@property (nonatomic, retain) UITableView *stopTable;
@property (nonatomic, retain) UIImageView *bannerImage;

@property (assign) StopGroup *stopGroup;

- (id)initWithStopGroup:(StopGroup*)stop;

@end
