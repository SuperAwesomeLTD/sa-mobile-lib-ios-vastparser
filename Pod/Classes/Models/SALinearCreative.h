//
//  SALinearCreative.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "SAVASTCreative.h"

//
// @brief: the linear creative basically displays video media from a
// remote source and contains all tracking and click events that should be
// associated
@interface SALinearCreative : SAVASTCreative
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *sequence;
@property (nonatomic, strong) NSString *Duration;
@property (nonatomic, strong) NSString *ClickThrough;
@property (nonatomic, strong) NSString *playableMediaURL;
@property (nonatomic, assign) BOOL isOnDisk;
@property (nonatomic, strong) NSString *playableDiskURL;
@property (nonatomic, strong) NSMutableArray *MediaFiles;
@property (nonatomic, strong) NSMutableArray *TrackingEvents;
@property (nonatomic, strong) NSMutableArray *ClickTracking;
@property (nonatomic, strong) NSMutableArray *CustomClicks;

// @brief: this function performs the sum of a Linear Creative over the current Linear Creative
- (void) sumCreative:(SALinearCreative*)creative;

@end
