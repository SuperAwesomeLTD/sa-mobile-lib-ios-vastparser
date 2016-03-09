//
//  SAVASTCreative.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "SAGenericVAST.h"

//
// @brief: this enum says what kind of creative it is
// just so that we don't have to check the class always
typedef enum SAVASTCreativeType {
    Linear = 0,
    NonLinear = 1,
    CompanionAds = 2
} SAVASTCreativeType;

//
// @brief: the creative parent class
// three types of creatives will eventually descend from this:
// - Linear
// - NonLinear
// - CompanionAds
@interface SAVASTCreative : SAGenericVAST
@property (nonatomic, assign) SAVASTCreativeType type;

// @brief: this function perfroms the sum of a Creative over the current Creative
- (void) sumCreative:(SAVASTCreative*)creative;

@end
