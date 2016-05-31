//
//  SAVASTAd.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAVASTAd.h"

@implementation SAVASTAd

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super init]) {
        _type = (SAAdType)[jsonDictionary safeIntForKey:@"type"];
        __id = [jsonDictionary safeStringForKey:@"id"];
        _sequence = [jsonDictionary safeStringForKey:@"sequence"];
        _redirectUri = [jsonDictionary safeStringForKey:@"redirectUri"];
        _isImpressionSent = [jsonDictionary safeBoolForKey:@"isImpressionSent"];
        _Errors = [[[NSArray alloc] initWithJsonArray:[jsonDictionary objectForKey:@"Errors"] andIterator:^id(id item) {
            return (NSString*)item;
        }] mutableCopy];
        _Impressions = [[[NSArray alloc] initWithJsonArray:[jsonDictionary objectForKey:@"Impressions"] andIterator:^id(id item) {
            return (NSString*)item;
        }] mutableCopy];
        _creative = [[SAVASTCreative alloc] initWithJsonDictionary:[jsonDictionary objectForKey:@"creative"]];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
        @"type": @(_type),
        @"id": nullSafe(__id),
        @"sequence": nullSafe(_sequence),
        @"redirectUri": nullSafe(_redirectUri),
        @"isImpressionSent": @(_isImpressionSent),
        @"Errors": [_Errors dictionaryRepresentation],
        @"Impressions": [_Impressions dictionaryRepresentation],
        @"creative": nullSafe([_creative dictionaryRepresentation])
    };
}

- (void) sumAd:(SAVASTAd *)ad {
    
    // old ad gets _id of new ad (does not really affect anything)
    __id = ad._id;
    // and the sequence is overriden (again, does not affect anything)
    _sequence = ad.sequence;
    
    // summing errors
    [_Errors addObjectsFromArray:ad.Errors];
    // suming impressions
    [_Impressions addObjectsFromArray:ad.Impressions];
    // and creatives (and for now we assume we only have linear ones)
    // don't sum-up creatives now
    [_creative sumCreative:ad.creative];
}

@end
