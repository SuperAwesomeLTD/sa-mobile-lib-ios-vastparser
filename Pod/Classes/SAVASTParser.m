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
#import "SAVASTAd.h"
#import "SAVASTCreative.h"
#import "SAVASTTracking.h"
#import "SAVASTMediaFile.h"

// import Utils
#import "SAUtils.h"
#import "SANetwork.h"
#import "SAFileDownloader.h"
#import "SAExtensions.h"

@implementation SAVASTParser

//
// @brief: main Async function
- (void) parseVASTURL:(NSString *)url {
    
    [self parseVASTAds:url withResult:^(SAVASTAd *ad) {
        
        if (ad && ad.creative.playableMediaURL != NULL) {
            
            [[SAFileDownloader getInstance] downloadFileFrom:ad.creative.playableMediaURL to:ad.creative.playableDiskURL withSuccess:^{
                ad.creative.isOnDisk = TRUE;
                if (_delegate && [_delegate respondsToSelector:@selector(didParseVAST:)]){
                    [_delegate didParseVAST:ad];
                }
            } orFailure:^{
                ad.creative.isOnDisk = FALSE;
                if (_delegate && [_delegate respondsToSelector:@selector(didParseVAST:)]){
                    [_delegate didParseVAST:ad];
                }
            }];
            
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(didParseVAST:)]){
                [_delegate didParseVAST:nil];
            }
        }
    }];
}

- (void) parseVASTURL:(NSString *)url done:(vastParsingDone)vastParsing {
    
    [self parseVASTAds:url withResult:^(SAVASTAd *ad) {
        
        if (ad && ad.creative.playableMediaURL != NULL) {
            
            [[SAFileDownloader getInstance] downloadFileFrom:ad.creative.playableMediaURL to:ad.creative.playableDiskURL withSuccess:^{
                ad.creative.isOnDisk = TRUE;
                vastParsing(ad);
            } orFailure:^{
                ad.creative.isOnDisk = FALSE;
                vastParsing(ad);
            }];
            
        } else {
            vastParsing(nil);
        }
    }];
}

//
// @brief: get ads starting from a root
- (void) parseVASTAds:(NSString*)vastURL withResult:(vastParsingDone)done {
    
    SANetwork *network = [[SANetwork alloc] init];
    [network sendGET:vastURL
           withQuery:@{}
           andHeader:@{@"Content-Type":@"application/json",
                       @"User-Agent":[SAUtils getUserAgent]
                       }
          andSuccess:^(NSInteger status, NSString *payload) {
        // parse XML element
        SAXMLParser *parser = [[SAXMLParser alloc] init];
        __block SAXMLElement *root = [parser parseXMLString:payload];
        
        // check for preliminary errors
        if ([parser getError]) { done(nil); return; }
        if (!root) { done(nil); return; }
        if (![SAXMLParser checkSiblingsAndChildrenOf:root forName:@"Ad"]) { done(nil); return; }
        
        // get and parse *Only* first Ad
        SAXMLElement *element = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:root forName:@"Ad"];
        SAVASTAd *ad = [self parseAdXML:element];
        
        // in-line case
        if (ad.type == InLine) {
            done(ad);
            return;
        }
        // wrapper case
        else if (ad.type == Wrapper) {
            [self parseVASTAds:ad.redirectUri withResult:^(SAVASTAd *wrapper) {
                if (wrapper) {
                    [ad sumAd:wrapper];
                }
                done(ad);
                return;
            }];
        }
        // some other type of failure case
        else {
            done(nil);
            return;
        }
    } andFailure:^{
        done(nil);
    }];
}

- (SAVASTAd*) parseAdXML:(SAXMLElement *)adElement {
    // create ad
    SAVASTAd *ad = [[SAVASTAd alloc] init];
    
    // get attributes
    ad._id = [adElement getAttribute:@"id"];
    ad.sequence = [adElement getAttribute:@"sequence"];
    ad.type = Invalid;
    
    // init arrays of data
    ad.Errors = [[NSMutableArray alloc] init];
    ad.Impressions = [[NSMutableArray alloc] init];
    
    // check ad type
    BOOL isInLine = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"InLine"];
    BOOL isWrapper = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"Wrapper"];
    
    if (isInLine) ad.type = InLine;
    if (isWrapper) ad.type = Wrapper;
    
    // get VAStAdTagURI
    SAXMLElement *redirect = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:adElement forName:@"VASTAdTagURI"];
    if (redirect) {
        ad.redirectUri = [redirect getValue];
    }
    
    // get errors
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Error" andInterate:^(SAXMLElement *errElement) {
        NSString *error = [SAUtils decodeHTMLEntitiesFrom:[errElement getValue]];
        error = [error stringByReplacingOccurrencesOfString:@" " withString:@""];
        [ad.Errors addObject:error];
    }];
    
    // get impressions
    ad.isImpressionSent = false;
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Impression" andInterate:^(SAXMLElement *impElement) {
        [ad.Impressions addObject:[SAUtils decodeHTMLEntitiesFrom:[impElement value]]];
    }];
    
    // get creatives
    SAXMLElement *creativeElement = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:adElement forName:@"Creative"];
    ad.creative = [self parseCreativeXML:creativeElement];
    
    return ad;
}

- (SAVASTCreative*) parseCreativeXML:(SAXMLElement *)element {
    // first find out what kind of content this creative has
    // is it Linear, NonLinear or CompanionAds?
    BOOL isLinear = [SAXMLParser checkSiblingsAndChildrenOf:element forName:@"Linear"];
    
    // init as a linear Creative
    if (isLinear) {
        // create linear creative
        SAVASTCreative *_creative = [[SAVASTCreative alloc] init];
        
        // get attributes
        _creative.type = Linear;
        _creative._id = [element getAttribute:@"id"];
        _creative.sequence = [element getAttribute:@"sequence"];
        
        // create arrays
        _creative.ClickTracking = [[NSMutableArray alloc] init];
        _creative.CustomClicks = [[NSMutableArray alloc] init];
        _creative.MediaFiles = [[NSMutableArray alloc] init];
        _creative.TrackingEvents = [[NSMutableArray alloc] init];
        
        // populate duration
        [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"Duration" andInterate:^(SAXMLElement *durElement) {
            _creative.Duration = [durElement value];;
        }];
        
        // populate clickthrough
        [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"ClickThrough" andInterate:^(SAXMLElement *clickElement) {
            _creative.ClickThrough = [clickElement value];;
            _creative.ClickThrough = [SAUtils decodeHTMLEntitiesFrom:_creative.ClickThrough];
            _creative.ClickThrough = [_creative.ClickThrough stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            _creative.ClickThrough = [_creative.ClickThrough stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
            _creative.ClickThrough = [_creative.ClickThrough stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        }];
        
        // populate click tracking array
        [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"ClickTracking" andInterate:^(SAXMLElement *ctrackElement) {
            [_creative.ClickTracking addObject:[SAUtils decodeHTMLEntitiesFrom:[ctrackElement value]]];
        }];
        
        // populate custom clicks array
        [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"CustomClicks" andInterate:^(SAXMLElement *cclickElement) {
            [_creative.CustomClicks addObject:[SAUtils decodeHTMLEntitiesFrom:[cclickElement value]]];
        }];
        
        // populate media files
        [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"MediaFile" andInterate:^(SAXMLElement *cMediaElement) {
            // since this is a more "complex" object, wich takes data from
            // attributes as well as tag value, split the
            // declaration and array assignment
            SAVASTMediaFile *mediaFile = [[SAVASTMediaFile alloc] init];
            mediaFile.width = [cMediaElement getAttribute:@"width"];
            mediaFile.height = [cMediaElement getAttribute:@"height"];
            mediaFile.type = [cMediaElement getAttribute:@"type"];
            mediaFile.URL = [SAUtils decodeHTMLEntitiesFrom:[cMediaElement value]];
            
            // only add the Media file if the type is MP4
            if ([mediaFile.type rangeOfString:@"mp4"].location != NSNotFound ||
                [mediaFile.URL rangeOfString:@".mp4"].location != NSNotFound) {
                [_creative.MediaFiles addObject:mediaFile];
            }
        }];
        
        // populate tracking
        [SAXMLParser searchSiblingsAndChildrenOf:element forName:@"Tracking" andInterate:^(SAXMLElement *cTrackingElement) {
            // since this is also a more "complex" object, which takes data from
            // attributes as well as tag value, split the declaration and
            // array assignmenent
            SAVASTTracking *tracking = [[SAVASTTracking alloc] init];
            tracking.event = [cTrackingElement getAttribute:@"event"];
            tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[cTrackingElement value]];
            [_creative.TrackingEvents addObject:tracking];
        }];
        
        // get the designated playable Media File
        if (_creative.MediaFiles > 0){
            _creative.playableMediaURL = [(SAVASTMediaFile*)_creative.MediaFiles.firstObject URL];
            if (_creative.playableMediaURL != NULL) {
                _creative.playableDiskURL = [[SAFileDownloader getInstance] getDiskLocation];
            }
        }
        
        // return creative
        return _creative;
    }
    // non-linear / companion ads is not yet supported
    else {
        return NULL;
    }
}

- (void) dealloc {
    NSLog(@"SAVASTParser dealloc");
}

@end
