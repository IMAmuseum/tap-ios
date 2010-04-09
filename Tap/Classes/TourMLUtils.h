#import <Foundation/Foundation.h>

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#define TOURML_XMLNS		"http://www.imamuseum.org/TourML/1.0"
#define TOURML_XML_PREFIX	"TourML"

@interface TourMLUtils : NSObject {

}

// Check if a code exists in the tour document and return the stop element
+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withCode:(NSString*)code;

// Check if a code exists in the tour document and return the stop element
+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withIdentifier:(NSString*)indent;

@end
