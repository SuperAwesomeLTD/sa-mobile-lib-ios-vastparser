//
//  SAVAST2Parser.m
//  Pods
//
//  Created by Gabriel Coman on 17/12/2015.
//
//

#import "SAVASTParser.h"

// import new SAXML
#import "SAXMLParser.h"

// import helpes
#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"
#import "SAMedia.h"
#import "SATracking.h"

// import Utils
#import "SAUtils.h"
#import "SANetwork.h"
#import "SAFileDownloader.h"
#import "SAExtensions.h"

@implementation SAVASTParser

////////////////////////////////////////////////////////////////////////////////
// MARK: View lifecycle
////////////////////////////////////////////////////////////////////////////////

- (id) init {
    if (self = [super init]) {
        // do nothing
    }
    return self;
}

- (void) dealloc {
    NSLog(@"SAVASTParser dealloc");
}

////////////////////////////////////////////////////////////////////////////////
// MARK: Parsing public function
////////////////////////////////////////////////////////////////////////////////

- (void) parseVASTURL:(NSString *)url done:(vastParsingDone)vastParsing {
    
    [self parseVASTAds:url withResult:^(SAAd *ad) {
        
        if (ad.creative.details.media) {
            SAFileDownloader *downloader = [[SAFileDownloader alloc] init];
            [downloader downloadFileFrom:ad.creative.details.media.playableMediaUrl to:ad.creative.details.media.playableDiskUrl withResponse:^(BOOL success) {
                ad.creative.details.media.isOnDisk = success;
                vastParsing(ad);
            }];
        } else {
            vastParsing(ad);
        }

    }];
}

////////////////////////////////////////////////////////////////////////////////
// MARK: Parsing private functions
////////////////////////////////////////////////////////////////////////////////

- (void) parseVASTAds:(NSString*)vastURL withResult:(vastParsingDone)done {
    
    SANetwork *network = [[SANetwork alloc] init];
    [network sendGET:vastURL
           withQuery:@{}
           andHeader:@{@"Content-Type":@"application/json",
                       @"User-Agent":[SAUtils getUserAgent]}
        withResponse:^(NSInteger status, NSString *payload, BOOL success) {
            
            // create empty ad
            SAAd *empty = [[SAAd alloc] init];
            
            if (!success) {
                done(empty);
            } else {
                // parse XML element
                SAXMLParser *parser = [[SAXMLParser alloc] init];
                __block SAXMLElement *root = [parser parseXMLString:payload];
                
                // check for preliminary errors
                if ([parser getError]) { done(empty); return; }
                if (!root) { done(empty); return; }
                if (![SAXMLParser checkSiblingsAndChildrenOf:root forName:@"Ad"]) { done(empty); return; }
                
                // get and parse *Only* first Ad
                SAXMLElement *element = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:root forName:@"Ad"];
                __block SAAd *ad = [self parseAdXML:element];
                
                if (ad.vastType == InLine) {
                    done(ad);
                    return;
                } else if (ad.vastType == Wrapper) {
                    [self parseVASTAds:ad.vastRedirect withResult:^(SAAd *wrapper) {
                        SAAd *final = [self sumAd:ad withDest:wrapper];
                        done(final);
                        return;
                    }];
                } else {
                    done(empty);
                    return;
                }

            }
        }];
}

- (SAAd*) parseAdXML:(SAXMLElement *)adElement {
    // create ad
    SAAd *ad = [[SAAd alloc] init];
    
    ad.error = 0;
    ad.isVAST = YES;
    ad.vastType = InLine;
    
    // init arrays of data
    NSMutableArray *errors = [@[] mutableCopy];
    NSMutableArray *impressions = [@[] mutableCopy];
    
    // check ad type
    BOOL isInLine = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"InLine"];
    BOOL isWrapper = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"Wrapper"];
    
    if (isInLine) ad.vastType = InLine;
    if (isWrapper) ad.vastType = Wrapper;
    
    // get VAStAdTagURI
    SAXMLElement *redirect = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:adElement forName:@"VASTAdTagURI"];
    if (redirect) {
        ad.vastRedirect = [redirect getValue];
    }
    
    // get errors
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Error" andInterate:^(SAXMLElement *errElement) {
        NSString *error = [SAUtils decodeHTMLEntitiesFrom:[errElement getValue]];
        error = [error stringByReplacingOccurrencesOfString:@" " withString:@""];
        SATracking *tracking = [[SATracking alloc] init];
        tracking.URL = error;
        tracking.event = @"error";
        [errors addObject:tracking];
    }];

    // get impressions
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Impression" andInterate:^(SAXMLElement *impElement) {
        NSString *impression = [SAUtils decodeHTMLEntitiesFrom:[impElement value]];
        SATracking *tracking = [[SATracking alloc] init];
        tracking.URL = impression;
        tracking.event = @"impression";
        [impressions addObject:tracking];
    }];
    
    // get creatives
    SAXMLElement *creativeElement = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:adElement forName:@"Creative"];
    ad.creative = [self parseCreativeXML:creativeElement];
    
    // add errors and impressions
    [ad.creative.events addObjectsFromArray:errors];
    [ad.creative.events addObjectsFromArray:impressions];
    
    // return the ad
    return ad;
}

- (SACreative*) parseCreativeXML:(SAXMLElement *)element {
    // create linear creative
    SACreative *creative = [[SACreative alloc] init];
    
    // create arrays
    creative.events = [@[] mutableCopy];
    creative.clicks = [@[] mutableCopy];
    
    // populate clickthrough
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"ClickThrough" andInterate:^(SAXMLElement *clickElement) {
        creative.clickUrl = [clickElement value];
        creative.clickUrl = [SAUtils decodeHTMLEntitiesFrom:creative.clickUrl];
        creative.clickUrl = [creative.clickUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        creative.clickUrl = [creative.clickUrl stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
        creative.clickUrl = [creative.clickUrl stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    }];
    
    // populate click tracking array
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"ClickTracking" andInterate:^(SAXMLElement *ctrackElement) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[ctrackElement value]];
        tracking.event = @"click_tracking";
        [creative.clicks addObject:tracking];
    }];
    
    // populate custom clicks array
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"CustomClicks" andInterate:^(SAXMLElement *cclickElement) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[cclickElement value]];
        tracking.event = @"custom_clicks";
    }];
    
    // populate tracking
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"Tracking" andInterate:^(SAXMLElement *cTrackingElement) {
        SATracking *tracking = [[SATracking alloc] init];
        tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[cTrackingElement value]];
        tracking.event = [cTrackingElement getAttribute:@"event"];
        [creative.events addObject:tracking];
    }];
    
    // create the details
    creative.details = [[SADetails alloc] init];
    
    // populate media files
    [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"MediaFile" andInterate:^(SAXMLElement *cMediaElement) {
        SAMedia *media = [self parseMediaXML:cMediaElement];
        if ([media.type rangeOfString:@"mp4"].location != NSNotFound ||
            [media.type rangeOfString:@".mp4"].location != NSNotFound) {
            creative.details.media = media;
        }
    }];
    
    // return creative
    return creative;
}

- (SAMedia*) parseMediaXML:(SAXMLElement*)element {
    SAMedia *media = [[SAMedia alloc] init];
    media.type = [element getAttribute:@"type"];
    media.playableMediaUrl = [[element value] stringByReplacingOccurrencesOfString:@" " withString:@""];
    media.playableDiskUrl = [SAFileDownloader getDiskLocation];
    return media;
}

- (SAAd*) sumAd:(SAAd*)source withDest:(SAAd*)dest {
    SAAd *localS = source;
    
    // replace click URL
    if (dest.creative.clickUrl != NULL) {
        localS.creative.clickUrl = dest.creative.clickUrl;
    }
    
    // append events and clicks
    [localS.creative.events addObjectsFromArray:dest.creative.events];
    [localS.creative.clicks addObjectsFromArray:dest.creative.clicks];
    
    // media
    if (dest.creative.details.media != NULL) {
        localS.creative.details.media = dest.creative.details.media;
    }
    
    return localS;
}

@end
