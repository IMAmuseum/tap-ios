//
//  TourMLParser.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TourMLParser.h"
#import "AppDelegate.h"
#import "ISO8601DateFormatter.h"

static NSMutableString *bundlePath;

@implementation TourMLParser

/**
 * Kicks off the processing of tourml documents from a specified endpoint and any bundles found
 * in the 'Bundles' directory
 */
+ (void)loadTours 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    bundlePath = nil;
    NSError *error;
    
    // process endpoint
    NSString *endpoint = [[appDelegate tapConfig] objectForKey:@"TourMLEndpoint"];
    if (endpoint != nil) {
        [self getExternalTourMLDoc:endpoint];
    }

    // process bundles
    NSString *bundleDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Bundles"];
    NSDirectoryEnumerator *bundleEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:bundleDir];
    if (bundleEnumerator) {
        NSString *currBundlePath;
        while (currBundlePath = [bundleEnumerator nextObject]) {
            if ([[currBundlePath pathExtension] isEqualToString:@"bundle"]) {
                NSString *tourBundlePath = [bundleDir stringByAppendingPathComponent:currBundlePath];
                bundlePath = [NSMutableString stringWithFormat:@"%@", tourBundlePath];
                NSBundle *bundle = [NSBundle bundleWithPath:tourBundlePath];
                if (bundle) {
                    NSString *tourDataPath = [bundle pathForResource:@"tour" ofType:@"xml"];
                    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:tourDataPath];
                    
                    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
                    if (doc == nil) {
                        continue;
                    }
                    
                    if ([[doc.rootElement name] isEqualToString:@"tourml:TourSet"]) {
                        for (GDataXMLElement *ref in [doc.rootElement elementsForName:@"tourml:TourMLRef"]) {
                            [self getExternalTourMLDoc:[[ref attributeForName:@"tourml:uri"] stringValue]];
                        }
                    } else {
                        [self parseTourMLDoc:doc];
                    }
                }
            }
        }
    }
    
}

/**
 * Retrieve data from a given tourMLRef
 */
+ (void)getExternalTourMLDoc:(NSString *)tourMLRef 
{
    NSURL *url = [NSURL URLWithString:tourMLRef];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                            returningResponse:&response error:&error];
    
    if ([xmlData length] == 0 && error != nil) {
        NSLog(@"Unable to retrieve document from endpoint.");
        return;
    } else if (error != nil) {
        NSLog(@"Error occured retrieving from endpoint: %@", error);
        return;
    }
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    
    if (doc == nil) {
        return;
    }
    
    if ([[doc.rootElement name] isEqualToString:@"tourml:TourSet"]) {
        for (GDataXMLElement *ref in [doc.rootElement elementsForName:@"tourml:TourMLRef"]) {
            [self getExternalTourMLDoc:[[ref attributeForName:@"tourml:uri"] stringValue]];
        }
    } else {
        [self parseTourMLDoc:doc];
    }
}

/**
 * Parse an individual tour doc
 */
+ (void)parseTourMLDoc:(GDataXMLDocument *)doc 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error = nil;
    
    NSString *tourId = [[doc.rootElement attributeForName:@"tourml:id"] stringValue];
    NSDate *lastModified = [self convertStringToDate:[[doc.rootElement attributeForName:@"tourml:lastModified"] stringValue]];
    
    // Make request to find existing tour by id
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tour" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate: [NSPredicate predicateWithFormat: @"(id = %@)", [[doc.rootElement attributeForName:@"tourml:id"] stringValue]]];
    NSArray *tours = [context executeFetchRequest:request error:&error];
    
    
    // Check if tour already exists
    if ([tours count] != 0) {
        TAPTour *existingTour = [tours objectAtIndex:0];
        // check if the existing tour is older this this tour or the last modified is not set for either versions of the tours
        if ([existingTour.lastModified compare:lastModified] == NSOrderedAscending || existingTour.lastModified == nil || lastModified == nil) {
            // delete existing tour data
            [context deleteObject:existingTour];
            [context save:&error];
        } else {
            // tour in core data is newer so leave it alone
            return;
        }
    }
    
    // Get documents folder path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // generate path for tour
    NSString *assetsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", tourId]];

    // handle creating the new directory or deleting the contents of the directory if it already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:assetsDirectory]) {
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:assetsDirectory error:&error]) {    
            NSString *filePath = [assetsDirectory stringByAppendingPathComponent:file];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:assetsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    // start creating new tour
    TAPTour *tour = [NSEntityDescription insertNewObjectForEntityForName:@"Tour" inManagedObjectContext:context];
    // Tour attributes
    tour.id = tourId;
    tour.lastModified = lastModified;
    tour.bundlePath = bundlePath;
    // TourMetadata
    GDataXMLElement *tourMetadata = [[doc.rootElement elementsForName:@"tourml:TourMetadata"] objectAtIndex:0];
    tour.publishDate = [self convertStringToDate:[[[tourMetadata elementsForName:@"tourml:publishDate"] objectAtIndex:0] stringValue]];
    tour.author = [[[tourMetadata elementsForName:@"tourml:Author"] objectAtIndex:0] stringValue];
    tour.title = [self processTitle:[tourMetadata elementsForName:@"tourml:Title"] withContext:context];
    tour.desc = [self processDescription:[tourMetadata elementsForName:@"tourml:Description"] withContext:context];
    // AppResource
    tour.appResource = [self processAssets:[tourMetadata elementsForName:@"tourml:AppResource"] fromRoot:doc.rootElement withContext:context];
    // PropertySet
    tour.propertySet = [self processPropertySet:[[tourMetadata elementsForName:@"tourml:PropertySet"] objectAtIndex:0] withContext:context];
    // Stops
    tour.stop = [self processStops:doc.rootElement fromRoot:doc.rootElement withContext:context];

    // check to see if a root stop element exists
    if ([[tourMetadata elementsForName:@"tourml:RootStopRef"] count] > 0) {
        NSString *rootStopRef = [[[[tourMetadata elementsForName:@"tourml:RootStopRef"] objectAtIndex:0] attributeForName:@"tourml:id"] stringValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", rootStopRef];
        NSSet *rootStops = [tour.stop filteredSetUsingPredicate:predicate];
        tour.rootStopRef = [rootStops anyObject];
    }

    if (![context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    
    bundlePath = nil;
}

/**
 * Process tour stops
 */
+ (NSSet *)processStops:(GDataXMLElement *)element fromRoot:(GDataXMLElement *)root withContext:(NSManagedObjectContext *)context 
{
    NSMutableSet *stops = [[NSMutableSet alloc] init];
    
    for (GDataXMLElement *stopElement in [element elementsForName:@"tourml:Stop"]) {
        TAPStop *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
        stop.id = [[stopElement attributeForName:@"tourml:id"] stringValue];
        stop.view = [[stopElement attributeForName:@"tourml:view"] stringValue];
        stop.title = [self processTitle:[stopElement elementsForName:@"tourml:Title"] withContext:context];
        stop.desc = [self processDescription:[stopElement elementsForName:@"tourml:Description"] withContext:context];
        stop.propertySet = [self processPropertySet:[[stopElement elementsForName:@"tourml:PropertySet"] objectAtIndex:0] withContext:context];
        stop.assetRef = [self processAssets:[stopElement elementsForName:@"tourml:AssetRef"] fromRoot:root withContext:context];
        
        [stops addObject:stop];
    }
    
    // now that all of the stops are available, add all of the associated connections
    for (GDataXMLElement *connectionElement in [root elementsForName:@"tourml:Connection"]) {
        
        NSPredicate *sourcePredicate = [NSPredicate predicateWithFormat:@"id == %@", [[connectionElement attributeForName:@"tourml:srcId"] stringValue]];
        NSSet *filteredSource = [stops filteredSetUsingPredicate:sourcePredicate];

        NSPredicate *destinationPredicate = [NSPredicate predicateWithFormat:@"id == %@", [[connectionElement attributeForName:@"tourml:destId"] stringValue]];
        NSSet *filteredDestination = [stops filteredSetUsingPredicate:destinationPredicate];
        
        TAPConnection *connection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:context];
        connection.usage = [[connectionElement attributeForName:@"tourml:usage"] stringValue];
        connection.sourceStop = [filteredSource anyObject];
        connection.destinationStop = [filteredDestination anyObject];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterNoStyle];
        connection.priority = [formatter numberFromString:[[connectionElement attributeForName:@"tourml:priority"] stringValue]];
    }
    
    return stops;
}

/**
 * Processes assets for a particular stop
 */
+ (NSSet *)processAssets:(NSArray *)elements fromRoot:(GDataXMLElement *)root withContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSMutableSet *assetRefs = [[NSMutableSet alloc] init];
    
    for (GDataXMLElement *assetRefElement in elements) {
        TAPAssetRef *assetRef = [NSEntityDescription insertNewObjectForEntityForName:@"AssetRef" inManagedObjectContext:context];
        assetRef.id = [[assetRefElement attributeForName:@"tourml:id"] stringValue];
        assetRef.usage = [[assetRefElement attributeForName:@"tourml:usage"] stringValue];
        
        // get asset
        NSArray *assetSearch = [root nodesForXPath:[NSString stringWithFormat:@"/tourml:Tour/tourml:Asset[@tourml:id='%@']", assetRef.id] error:&error];

        GDataXMLElement *assetElement = [assetSearch objectAtIndex:0];
        
        TAPAsset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:context];
        asset.id = [[assetElement attributeForName:@"tourml:id"] stringValue];
        asset.type = [[assetElement attributeForName:@"tourml:type"] stringValue];
        asset.copyright = [[[assetElement elementsForName:@"tourml:Copyright"] objectAtIndex:0] stringValue];
        asset.creditLine = [[[assetElement elementsForName:@"tourml:CreditLine"] objectAtIndex:0] stringValue];
        asset.machineRights = [[[assetElement elementsForName:@"tourml:MachineRights"] objectAtIndex:0] stringValue];
        asset.expiration = [self convertStringToDate:[[[assetElement elementsForName:@"tourml:MachineRights"] objectAtIndex:0] stringValue]];
        asset.propertySet = [self processPropertySet:[[assetElement elementsForName:@"tourml:PropertySet"] objectAtIndex:0] withContext:context];
        
        // add asset content
        NSMutableSet *assetContent = [[NSMutableSet alloc] init];
        for (GDataXMLElement *contentElement in [assetElement elementsForName:@"tourml:Content"]) {
            TAPContent *content = [NSEntityDescription insertNewObjectForEntityForName:@"Content" inManagedObjectContext:context];
            content.data = [[[contentElement elementsForName:@"tourml:Data"] objectAtIndex:0] stringValue];
            content.format = [[contentElement attributeForName:@"tourml:format"] stringValue];
            content.language = [[contentElement attributeForName:@"tourml:lang"] stringValue];
            content.part = [[contentElement attributeForName:@"tourml:part"] stringValue];
            content.propertySet = [self processPropertySet:[[contentElement elementsForName:@"tourml:PropertySet"] objectAtIndex:0] withContext:context];
            [assetContent addObject:content];
        }
        asset.content = assetContent;

        // add asset sources
        NSMutableSet *assetSources = [[NSMutableSet alloc] init];
        for (GDataXMLElement *sourceElement in [assetElement elementsForName:@"tourml:Source"]) {
            TAPSource *source = [NSEntityDescription insertNewObjectForEntityForName:@"Source" inManagedObjectContext:context];
            source.format = [[sourceElement attributeForName:@"tourml:format"] stringValue];
            source.language = [[sourceElement attributeForName:@"tourml:lang"] stringValue];
            source.lastModified = [self convertStringToDate:[[sourceElement attributeForName:@"tourml:lastModified"] stringValue]];
            source.part = [[sourceElement attributeForName:@"tourml:part"] stringValue];
            source.uri = [[sourceElement attributeForName:@"tourml:uri"] stringValue];
            source.propertySet = [self processPropertySet:[[sourceElement elementsForName:@"tourml:PropertySet"] objectAtIndex:0] withContext:context];
            [assetSources addObject:source];
        }
        asset.source = assetSources;
        
        asset.watermark = [[self processAssets:[assetElement elementsForName:@"tourml:Watermark"] fromRoot:root withContext:context] anyObject];
        assetRef.asset = asset;
        [assetRefs addObject:assetRef];
    }
    
    return assetRefs;
}

/**
 * Generic method for processing titles
 */
+ (NSDictionary *)processTitle:(NSArray *)elements withContext:(NSManagedObjectContext *)context 
{
    NSMutableDictionary *titles = [[NSMutableDictionary alloc] init];
    
    for (GDataXMLElement *title in elements) {
        [titles setObject:[title stringValue] forKey:[[[title attributes] objectAtIndex:0] stringValue]];
    }
    
    return titles;    
}

/**
 * Generic method for processing descriptions
 */
+ (NSDictionary *)processDescription:(NSArray *)elements withContext:(NSManagedObjectContext *)context 
{
    NSMutableDictionary *descriptions = [[NSMutableDictionary alloc] init];
    
    for (GDataXMLElement *description in elements) {
        [descriptions setObject:[description stringValue] forKey:[[[description attributes] objectAtIndex:0] stringValue]];
    }
    
    return descriptions;
}

/**
 * Generic method of processing property sets
 */
+ (NSSet *)processPropertySet:(GDataXMLElement *)element withContext:(NSManagedObjectContext *)context 
{
    NSMutableSet *propertySet = [[NSMutableSet alloc] init];
    
    for (GDataXMLElement *propertyElement in element.children) {
        TAPProperty *property = [NSEntityDescription insertNewObjectForEntityForName:@"Property" inManagedObjectContext:context];
        property.language = [[propertyElement attributeForName:@"tourml:lang"] stringValue];
        property.name = [[propertyElement attributeForName:@"tourml:name"] stringValue];
        property.value = [propertyElement stringValue];
        [propertySet addObject:property];
    }
    
    return propertySet;
}

/**
 * Converts a given date string of yyyy-MM-dd'T'HH:mm:ss and converts
 * it to a NSDate.
 */
+ (NSDate *)convertStringToDate:(NSString *)dateString 
{
    if (dateString == nil) return nil;
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *date = [formatter dateFromString:dateString];
    formatter = nil;
    return date;
}

@end
