/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAVASTParser.h"
#import "SAXMLParser.h"
#import "SAVASTMedia.h"
#import "SAVASTAd.h"
#import "SATracking.h"
#import "SANetwork.h"
#import "SAUtils.h"

@interface SAVASTParser ()
@property (nonatomic, strong) NSDictionary *header;
@end

@implementation SAVASTParser

/**
 * Simple constructor that initializes the Header dictionary to be sent along
 * with every request.
 *
 * @return a new object instance
 */
- (id) init {
    if (self = [super init]) {
        _header = @{@"Content-Type":@"application/json",
                    @"User-Agent": [SAUtils getUserAgent]};
    }
    
    return self;
}

- (void) parseVAST:(NSString*) url
      withResponse:(saDidParseVAST) response {
    
    // get a local block copy
    __block saDidParseVAST localDidParseVAST = response ? response : ^(SAVASTAd *ad) {};
    
    [self recursiveParse:url fromStartingAd:[[SAVASTAd alloc] init] withResponse:^(SAVASTAd *ad) {
       
        SAVASTMedia *minMedia = nil;
        SAVASTMedia *maxMedia = nil;
        SAVASTMedia *medMedia = nil;
        
        // get the min media
        for (SAVASTMedia *media in ad.mediaList) {
            if (minMedia == nil || (media.bitrate < minMedia.bitrate)) {
                minMedia = media;
            }
        }
        // get the max media
        for (SAVASTMedia *media in ad.mediaList) {
            if (maxMedia == nil || (media.bitrate > maxMedia.bitrate)) {
                maxMedia = media;
            }
        }
        // get everything in between
        for (SAVASTMedia *media in ad.mediaList) {
            if (media != minMedia && media != maxMedia) {
                medMedia = media;
            }
        }
        
        // get media Url based on connection type
        SAConnectionType connectionType = [SAUtils getNetworkConnectivity];
        
        switch (connectionType) {
                
                // try to get the lowest media possible
            case cellular_unknown:
            case cellular_2g: {
                ad.mediaUrl = minMedia != nil ? minMedia.mediaUrl : nil;
                break;
            }
                // try to get one of the medium media possible
            case cellular_3g: {
                ad.mediaUrl = medMedia != nil ? medMedia.mediaUrl : nil;
                break;
            }
                // try to get the best media possible
            case unknown:
            case ethernet:
            case wifi:
            case cellular_4g: {
                ad.mediaUrl = maxMedia != nil ? maxMedia.mediaUrl : nil;
                break;
            }
        }
        
        // if somehow all of that has failed, just get the last element of the list
        if (ad.mediaUrl == nil && [ad.mediaList count] >= 1) {
            ad.mediaUrl = [[ad.mediaList lastObject] mediaUrl];
        }
        
        // send final message
        localDidParseVAST (ad);
    }];
    
}

/**
 * Recursive method that handles all the VAST parsing
 *
 * @param url       url to get the vast from
 * @param startAd   ad that gets passed down
 * @param response  a copy of the saDidParseVAST callback block
 */
- (void) recursiveParse:(NSString*) url
         fromStartingAd:(SAVASTAd*)startAd
           withResponse:(saDidParseVAST) response {
    
    SANetwork *network = [[SANetwork alloc] init];
    [network sendGET:url withQuery:@{} andHeader:_header withResponse:^(NSInteger status, NSString *payload, BOOL success) {
        
        // if not successful just return the ad as it is 'because definetly something
        // "bad" happened
        if (!success || payload == nil) {
            response (startAd);
        }
        // else try to parse the XML data
        else {
            
            // init the parser
            SAXMLParser *parser = [[SAXMLParser alloc] init];
            
            // get the xml document
            SAXMLElement *document = [parser parseXMLString:payload];
            
            if (document != nil) {
                
                // get only the first XML Ad found in the VAST tag. don't bother at the moment
                // with VAST strings that have multiple ads in them
                SAXMLElement *Ad = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"Ad"];
                
                if (Ad == nil) {
                    response (startAd);
                    return;
                }
                
                // use the internal "parseAdXML" method to form an SAVASTAd object
                SAVASTAd *ad = [self parseAdXML:Ad];
                
                switch (ad.vastType) {
                    // if it's invalid, return the start a
                    case SA_Invalid_VAST: {
                        response (startAd);
                        break;
                    }
                    // if it's inline, then I'm at the end of the VAST chain, I sum up ads and return
                    case SA_InLine_VAST: {
                        [ad sumAd:startAd];
                        response (ad);
                        break;
                    }
                    // if it's a wrapper, I sum up what I have and call the method recursively
                    case SA_Wrapper_VAST: {
                        [ad sumAd:startAd];
                        [self recursiveParse:ad.vastRedirect fromStartingAd:ad withResponse:response];
                        break;
                    }
                }
                
            }
            // if there's an XML error, again assume it all went to shit and don't
            // bother summing ads or anything, just pass the start ad as it is
            else {
                response (startAd);
            }
        }
    }];
}

- (SAVASTAd*) parseAdXML: (SAXMLElement*) element {
    
    __block SAVASTAd *ad = [[SAVASTAd alloc] init];
    
    BOOL isInLine = [SAXMLParser checkSiblingsAndChildrenOf:element forName:@"InLine"];
    BOOL isWrapper = [SAXMLParser checkSiblingsAndChildrenOf:element forName:@"Wrapper"];
    
    if (isInLine) ad.vastType = SA_InLine_VAST;
    if (isWrapper) ad.vastType = SA_Wrapper_VAST;
    
    SAXMLElement *vastUri = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:element forName:@"VASTAdTagURI"];
    if (vastUri != nil) {
        ad.vastRedirect = [SAUtils decodeHTMLEntitiesFrom:[vastUri getValue]];
    }
    
    // get errors
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"Error" andInterate:^(SAXMLElement *element) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.event = @"error";
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[element getValue]];
        [ad.vastEvents addObject:tracking];
    }];
    
    // get impressions
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"Impression" andInterate:^(SAXMLElement *element) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.event = @"impression";
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[element getValue]];
        [ad.vastEvents addObject:tracking];
    }];
    
    // get the creative
    SAXMLElement *creativeXML = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:element forName:@"Creative"];
    
    [SAXMLParser searchSiblingsAndChildrenOf:creativeXML forName:@"ClickThrough" andInterate:^(SAXMLElement *element) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.event = @"click_through";
        tracking.URL = [[[[SAUtils decodeHTMLEntitiesFrom:[element getValue]]
                        stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]
                        stringByReplacingOccurrencesOfString:@"%3A" withString:@":"]
                        stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        [ad.vastEvents addObject:tracking];
    }];
    
    [SAXMLParser searchSiblingsAndChildrenOf:creativeXML forName:@"ClickTracking" andInterate:^(SAXMLElement *element) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.event = @"click_tracking";
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[element getValue]];
        [ad.vastEvents addObject:tracking];
    }];
    
    [SAXMLParser searchSiblingsAndChildrenOf:creativeXML forName:@"CustomClicks" andInterate:^(SAXMLElement *element) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.event = @"custom_clicks";
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[element getValue]];
        [ad.vastEvents addObject:tracking];
    }];
    
    [SAXMLParser searchSiblingsAndChildrenOf:creativeXML forName:@"Tracking" andInterate:^(SAXMLElement *element) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.event = [element getAttribute:@"event"];
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[element getValue]];
        [ad.vastEvents addObject:tracking];
    }];
    
    // append only valid, mp4 type ads
    [SAXMLParser searchSiblingsAndChildrenOf:creativeXML forName:@"MediaFile" andInterate:^(SAXMLElement *element) {
        SAVASTMedia *media = [self parseMediaXML:element];
        if ([media isValid] && [media.type rangeOfString:@"mp4"].location != NSNotFound) {
            [ad.mediaList addObject:media];
        }
    }];
    
    return ad;
    
}

- (SAVASTMedia*) parseMediaXML: (SAXMLElement*) element {
    
    // create the new media element
    SAVASTMedia *media = [[SAVASTMedia alloc] init];
    
    // return empty media
    if (element == nil) return media;
    
    // get the media url
    media.mediaUrl = [[element getValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // get the attribute
    media.type = [element getAttribute:@"type"];
    
    // get bitrate
    NSString *bitrate = [element getAttribute:@"bitrate"];
    if (bitrate != nil) {
        media.bitrate = [bitrate integerValue];
    }
    
    // get width
    NSString *width = [element getAttribute:@"width"];
    if (width != nil) {
        media.width = [width integerValue];
    }
    
    // get height
    NSString *height = [element getAttribute:@"height"];
    if (height != nil) {
        media.height = [height integerValue];
    }
    
    return media;
}

@end
