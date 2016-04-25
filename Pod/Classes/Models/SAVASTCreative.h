//
//  SAVASTCreative.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>

//
// @brief: this enum says what kind of creative it is
// just so that we don't have to check the class always
typedef enum SAVASTCreativeType {
    Linear = 0,
    NonLinear = 1,
    CompanionAds = 2
} SAVASTCreativeType;

//
// @brief: the vast creative class that now supports only "Linear" creative,
// because that's the only one actually used for videos
// in the future both NonLinear and CompanionAds should be used
@interface SAVASTCreative : NSObject
@property (nonatomic, assign) SAVASTCreativeType type;
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

// @brief: this function perfroms the sum of a Creative over the current Creative
- (void) sumCreative:(SAVASTCreative*)creative;

@end
