//
//  SAImpression.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "SAGenericVAST.h"

//
// @brief: the impressions class
@interface SAImpression: SAGenericVAST
@property (nonatomic, assign) BOOL isSent;
@property (nonatomic, strong) NSString *URL;
@end

