//
//  SAMediaFile.h
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "SAGenericVAST.h"

//
// @brief: media file implementation
@interface SAMediaFile : SAGenericVAST
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *URL;
@end