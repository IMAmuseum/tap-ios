#import <Foundation/Foundation.h>

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#define TOURML_XMLNS		"http://www.imamuseum.org/TourML/2011/11"
#define TOURML_XML_PREFIX	"tourml"

@interface TourMLUtils : NSObject {

}
// Retrieve the asset source
+ (xmlNodePtr)getAsset:(xmlDocPtr)document withIdentifier:(NSString*)indent;

// Retrieve an array of source ids
+ (NSMutableArray*)getStopConnectionsByPriority:(xmlDocPtr)document withSource:(NSString*)sourceId;

// Check if a code exists in the tour document and return the stop element
+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withCode:(NSString*)code;

// Check if a code exists in the tour document and return the stop element
+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withIdentifier:(NSString*)indent;

// Retrieve the tour title
+ (NSString*)getTourTitle:(xmlDocPtr)document;

@end
