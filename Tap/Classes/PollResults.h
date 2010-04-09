#import <Foundation/Foundation.h>

#import "PollStop.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface PollResults : NSObject <UITableViewDelegate, UITableViewDataSource> {

    xmlDocPtr resultDoc;
    NSInteger totalResponses;
    PollStop *pollStop;
    UITableView *resultsTable;

}

@property (nonatomic, retain) PollStop *pollStop;
@property (nonatomic, retain) UITableView *resultsTable;

// Pass in the resulting xml response doc
-(id)initWithData:(NSData*)data pollStop:(PollStop*)stop;

// Return the number of votes for the given response
-(NSInteger)countForResponse:(NSString*)response;

// Return a tableview with the results
-(UITableView*)getResultsTableWithFrame:(CGRect)frame;

@end
