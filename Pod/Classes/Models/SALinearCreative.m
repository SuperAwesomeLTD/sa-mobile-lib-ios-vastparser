//
//  SALinearCreative.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SALinearCreative.h"
#import "SAUtils.h"

@implementation SALinearCreative

- (void) print {
    if (super.type == Linear) NSLog(@"\t\tType: Linear Creative(%@)", __id);
    if (super.type == NonLinear) NSLog(@"\t\tType: NonLinear Creative(%@)", __id);
    if (super.type == CompanionAds) NSLog(@"\t\tType: CompanionAds Creative(%@)", __id);
    NSLog(@"\t\tSequence: %@", _sequence);
    NSLog(@"\t\tDuration: %@", _Duration);
    NSLog(@"\t\tplayable: %@", _playableMediaURL);
    if (_ClickThrough) NSLog(@"\t\tClickThrough: OK %@", _ClickThrough);
    else NSLog(@"\t\tClickThrough: NOK");
    NSLog(@"\t\tClickTracking[%ld]", (long)_ClickTracking.count);
    NSLog(@"\t\tCustomClicks[%ld]", (long)_CustomClicks.count);
    NSLog(@"\t\tTracking[%ld]", (long)_TrackingEvents.count);
    NSLog(@"\t\tMediaFiles[%ld]", (long)_MediaFiles.count);
}

- (void) sumCreative:(SALinearCreative *)creative {
    
    // perform a "Sum" operation
    // first override some unimportant variables
    self._id = creative._id;
    self.sequence = creative.sequence;
    self.Duration = creative.Duration;
    
    if ([SAUtils isValidURL:self.ClickThrough]) {
        self.ClickThrough = self.ClickThrough;
    }
    if ([SAUtils isValidURL:creative.ClickThrough]) {
        self.ClickThrough = creative.ClickThrough;
    }
    if ([SAUtils isValidURL:self.playableMediaURL]){
        self.playableMediaURL = self.playableMediaURL;
    }
    if ([SAUtils isValidURL:creative.playableMediaURL]){
        self.playableMediaURL = creative.playableMediaURL;
    }
    
    // then concatenate arrays (this is what's important)
    [self.MediaFiles addObjectsFromArray:creative.MediaFiles];
    [self.TrackingEvents addObjectsFromArray:creative.TrackingEvents];
    [self.ClickTracking addObjectsFromArray:creative.ClickTracking];
    [self.CustomClicks addObjectsFromArray:creative.CustomClicks];
}

@end