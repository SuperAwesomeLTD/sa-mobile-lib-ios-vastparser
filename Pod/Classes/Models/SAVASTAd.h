//
//  SAVASTAd.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>

//
// @brief: this enum should hold the type of content an ad holds
typedef enum SAAdType {
    Invalid = -1,
    InLine = 0,
    Wrapper = 1
}SAAdType;

//
// @brief: the simplified representation of a VAST ad
// - some details have been contactenated, but all important data is here
@interface SAVASTAd : NSObject
@property (nonatomic, assign) SAAdType type;
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *sequence;
@property (nonatomic, strong) NSString *redirectUri;
@property (nonatomic, strong) NSMutableArray *Errors;
@property (nonatomic, strong) NSMutableArray *Impressions;
@property (nonatomic, assign) BOOL isImpressionSent;
@property (nonatomic, strong) NSMutableArray *Creatives;

// @brief: this function performs the sum of an Ad over the current Ad
- (void) sumAd:(SAVASTAd*)ad;

@end
