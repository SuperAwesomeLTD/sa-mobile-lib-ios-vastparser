//
//  SAVASTCreative.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

// import header
#import "SAVASTCreative.h"

// import utils
#import "SAUtils.h"

@implementation SAVASTCreative

- (void) sumCreative:(SAVASTCreative *)creative {
    // perform a "Sum" operation
    // first override some unimportant variables
    self._id = creative._id;
    self.sequence = creative.sequence;
    self.Duration = creative.Duration;
    
    if ([SAUtils isValidURL:creative.ClickThrough]) {
        self.ClickThrough = creative.ClickThrough;
    }
    if ([SAUtils isValidURL:creative.playableMediaURL]){
        self.playableMediaURL = creative.playableMediaURL;
    }
    if (creative.playableDiskURL != NULL){
        self.playableDiskURL = creative.playableDiskURL;
    }
    
    // then concatenate arrays (this is what's important)
    [self.MediaFiles addObjectsFromArray:creative.MediaFiles];
    [self.TrackingEvents addObjectsFromArray:creative.TrackingEvents];
    [self.ClickTracking addObjectsFromArray:creative.ClickTracking];
    [self.CustomClicks addObjectsFromArray:creative.CustomClicks];
}

@end