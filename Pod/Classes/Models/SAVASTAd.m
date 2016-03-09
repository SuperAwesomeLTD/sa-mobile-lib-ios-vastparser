//
//  SAVASTAd.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAVASTAd.h"
#import "SAVASTCreative.h"
#import "SALinearCreative.h"

@implementation SAVASTAd

- (void) print {
    if (_type == 0) NSLog(@"\tType: InLine Ad(%@)", __id);
    if (_type == 1) NSLog(@"\tType: Wrapper Ad(%@)", __id);
    NSLog(@"\tSequence: %@", _sequence);
    NSLog(@"\tImpressions[%ld]", (long)_Impressions.count);
    NSLog(@"\tErrors[%ld]", (long)_Errors.count);
    NSLog(@"\tCreatives[%ld]", (long)_Creatives.count);
    for (SAVASTCreative *c in _Creatives) {
        [c print];
    }
}

- (void) sumAd:(SAVASTAd *)ad {
    
    // old ad gets _id of new ad (does not really affect anything)
    self._id = ad._id;
    // and the sequence is overriden (again, does not affect anything)
    self.sequence = ad.sequence;
    
    // summing errors
    [self.Errors addObjectsFromArray:ad.Errors];
    // suming impressions
    [self.Impressions addObjectsFromArray:ad.Impressions];
    // and creatives (and for now we assume we only have linear ones)
    // don't sum-up creatives now
    for (SALinearCreative *creative in self.Creatives) {
        for (SALinearCreative *creative2 in ad.Creatives) {
            [creative sumCreative:creative2];
        }
    }
}

@end
