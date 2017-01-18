//
//  SAVAST2Parser.h
//  Pods
//
//  Created by Gabriel Coman on 17/12/2015.
//
//

#import <UIKit/UIKit.h>

@class SAVASTAd;
@class SAVASTMedia;
@class SAXMLElement;

// method callback
typedef void (^saDidParseVAST)(SAVASTAd *ad);

@interface SAVASTParser : NSObject

- (void) parseVAST:(NSString*) url withResponse:(saDidParseVAST) response;
- (SAVASTAd*) parseAdXML: (SAXMLElement*) element;
- (SAVASTMedia*) parseMediaXML: (SAXMLElement*) element;

@end
