//
//  SATracking.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "SAGenericVAST.h"

//
// @brief: the tracking object
@interface SATracking : SAGenericVAST
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) NSString *URL;
@end
