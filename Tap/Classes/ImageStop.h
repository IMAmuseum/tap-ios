#import <Foundation/Foundation.h>

#import "BaseStop.h"


@interface ImageStop : BaseStop <Stop> {

}

+ (NSString*)getSource:(xmlDocPtr)document withIdentifier:(NSString*)ident;
+ (NSString*)getCaption:(xmlDocPtr)document withIdentifier:(NSString*)ident;
+ (NSString*)getCreditLine:(xmlDocPtr)document withIdentifier:(NSString*)ident;
- (NSArray*)getAssetIds;

@end
