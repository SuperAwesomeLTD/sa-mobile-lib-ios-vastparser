//
//  SAVASTAd.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAVASTAd.h"
#import "SAVASTCreative.h"

@implementation SAVASTAd

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
    [self.creative sumCreative:ad.creative];
}

@end
