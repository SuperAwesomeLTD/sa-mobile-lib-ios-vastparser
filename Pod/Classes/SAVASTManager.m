//
//  SAVASTManager.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 12/15/2015.
//
//

////////////////////////////////////////////////////////////////////////////////
// MARK: Imports
////////////////////////////////////////////////////////////////////////////////

// import headers
#import "SAVASTManager.h"

//// import player
//#import "SAVideoPlayer.h"
//
//// import modelspace
//#import "SAVASTAd.h"
//#import "SAVASTCreative.h"
//#import "SAVASTTracking.h"
//#import "SAVASTMediaFile.h"
//
//// import aux headers
//#import "SAUtils.h"
//#import "SAExtensions.h"
//#import "SAEvents.h"
//
//////////////////////////////////////////////////////////////////////////////////
//// MARK: Class definition
//////////////////////////////////////////////////////////////////////////////////
//
//@interface SAVASTManager ()
//
//@property (nonatomic, weak) SAVideoPlayer *playerRef;
//@property (nonatomic, weak) SAVASTAd *_cAd;
//@property (nonatomic, weak) SAVASTCreative *_cCreative;
//
//@end

@implementation SAVASTManager

//////////////////////////////////////////////////////////////////////////////////
//// MARK: Init functions
//////////////////////////////////////////////////////////////////////////////////
//
//- (id) initWithPlayer:(SAVideoPlayer *)player {
//    if (self = [super init]) {
//        
//        // init player ref
//        _playerRef = player;
//        
//        // the the event handler
//        [_playerRef setEventHandler:^(SAVideoPlayerEvent event) {
//            switch (event) {
//                case Video_Start: {
//                    
//                    NSLog(@"[AA :: INFO] didFindPlayerReady");
//                    
//                    for (NSString *impression in __cAd.Impressions) {
//                        [SAEvents sendEventToURL:impression];
//                    }
//                    
//                    // send event tracker
//                    [self sendCurrentCreativeTrackersFor:@"start"];
//                    
//                    // also, for each creative send the creativeView event
//                    [self sendCurrentCreativeTrackersFor:@"creativeView"];
//                    
//                    // call delegate
//                    if (_delegate && [_delegate respondsToSelector:@selector(didStartCreative)]) {
//                        [_delegate didStartCreative];
//                    }
//                    
//                    break;
//                }
//                case Video_1_4: {
//                    
//                    // send event tracker
//                    [self sendCurrentCreativeTrackersFor:@"firstQuartile"];
//                    
//                    // call delegate
//                    if (_delegate && [_delegate respondsToSelector:@selector(didReachFirstQuartileOfCreative)]) {
//                        [_delegate didReachFirstQuartileOfCreative];
//                    }
//                    
//                    break;
//                }
//                case Video_1_2: {
//                    
//                    // send event tracker
//                    [self sendCurrentCreativeTrackersFor:@"midpoint"];
//                    
//                    // call delegate
//                    if(_delegate && [_delegate respondsToSelector:@selector(didReachMidpointOfCreative)]){
//                        [_delegate didReachMidpointOfCreative];
//                    }
//                    
//                    break;
//                }
//                case Video_3_4: {
//                    
//                    // send event tracker
//                    [self sendCurrentCreativeTrackersFor:@"thirdQuartile"];
//                    
//                    // call delegate
//                    if (_delegate && [_delegate respondsToSelector:@selector(didReachThirdQuartileOfCreative)]) {
//                        [_delegate didReachThirdQuartileOfCreative];
//                    }
//                    
//                    break;
//                }
//                case Video_End: {
//                    
//                    // send event tracker
//                    [self sendCurrentCreativeTrackersFor:@"complete"];
//                    
//                    // call delegate
//                    if (_delegate && [_delegate respondsToSelector:@selector(didEndOfCreative)]) {
//                        [_delegate didEndOfCreative];
//                        [_delegate didEndAd];
//                        [_delegate didEndAllAds];
//                    }
//                    
//                    break;
//                }
//                case Video_Error: {
//                    
//                    // if a creative is played with error, send events to the error tag
//                    // and advance to the next ad
//                    for (NSString *error in __cAd.Errors) {
//                        [SAEvents sendEventToURL:error];
//                    }
//                    
//                    // call delegate
//                    if (_delegate && [_delegate respondsToSelector:@selector(didHaveErrorForCreative)]) {
//                        [_delegate didHaveErrorForCreative];
//                    }
//                    
//                    break;
//                }
//            }
//        }];
//        
//        // set the click handler
//        [_playerRef setClickHandler:^{
//            
//            // setup the current click URL
//            NSString *url = @"";
//            if (__cCreative.ClickThrough != NULL && [SAUtils isValidURL:__cCreative.ClickThrough]) {
//                url = __cCreative.ClickThrough;
//            }
//            
//            // call delegate
//            if (_delegate && [_delegate respondsToSelector:@selector(didGoToURL:withTrackingArray:)]) {
//                [_delegate didGoToURL:[NSURL URLWithString:url] withTrackingArray:__cCreative.ClickTracking];
//            }
//            
//        }];
//    }
//    
//    return self;
//}
//
//- (void) dealloc {
//    NSLog(@"SAVASTManager dealloc");
//}
//
//////////////////////////////////////////////////////////////////////////////////
//// MARK: Custom Manager functions
//////////////////////////////////////////////////////////////////////////////////
//
//- (void) manageWithVASTAd:(SAVASTAd *)ad {
//    
//    // failure
//    if (ad == nil || ad.creative == nil){
//        if (_delegate && [_delegate respondsToSelector:@selector(didNotFindAds)]){
//            [_delegate didNotFindAds];
//        }
//        return;
//    }
//    
//    // setup current ad
//    __cAd = ad;
//    __cCreative = ad.creative;
//    
//    // and start ad
//    if (_delegate && [_delegate respondsToSelector:@selector(didStartAd)]) {
//        [_delegate didStartAd];
//    }
//    
//    // play & manage
//    // [_playerRef reset];
//    
//    // play the current creative
//    if (__cCreative.isOnDisk) {
//        NSString *finalDiskURL = [SAUtils filePathInDocuments:__cCreative.playableDiskURL];
//        NSLog(@"Playing video from Disk %@", finalDiskURL);
//        [_playerRef playWithMediaFile:finalDiskURL];
//    }
//    else {
//        NSLog(@"Playing video from URL %@", __cCreative.playableMediaURL);
//        NSURL *url = [NSURL URLWithString:__cCreative.playableMediaURL];
//        [_playerRef playWithMediaURL:url];
//    }
//}
//
//////////////////////////////////////////////////////////////////////////////////
//// MARK: Aux functions
//////////////////////////////////////////////////////////////////////////////////
//
//- (void) sendCurrentCreativeTrackersFor:(NSString*)event {
//    NSArray *trackers = [__cCreative.TrackingEvents filterBy:@"event" withValue:event];
//    for (SAVASTTracking *tracker in trackers) {
//        [SAEvents sendEventToURL:tracker.URL];
//    }
//}

@end
