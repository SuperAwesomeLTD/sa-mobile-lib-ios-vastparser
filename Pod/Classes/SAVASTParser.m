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
#import "SAFileDownloader.h"
#import "SAExtensions.h"

@implementation SAVASTParser

//
// @brief: main Async function
- (void) parseVASTURL:(NSString *)url {
    
    dispatch_queue_t myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(myQueue, ^{
    
        // get ads array
        NSMutableArray *adsArray = [self parseVAST:url];
        
        // long running stuff
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_delegate && [_delegate respondsToSelector:@selector(didParseVAST:)]) {
                [_delegate didParseVAST:adsArray];
            }
        });
    });
}

//
// @brief: get ads starting from a root
- (NSMutableArray*) parseVAST:(NSString*)vastURL {
    // create the array of ads that should be returned
    __block NSMutableArray *ads = [[NSMutableArray alloc] init];
    
    // step 1: get the XML
    NSData *xmlData = [SAUtils sendSyncGETToEndpoint:vastURL];
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    __block SAXMLElement *root = [parser parseXMLData:xmlData];
    if ([parser getError]) {
        NSLog(@"%@", [parser getError]);
        return ads;
    }
    
    // step 3. if no "Ad" elements are found, just don't continue
    if (![SAXMLParser checkSiblingsAndChildrenOf:root forName:@"Ad"]){
        return ads;
    }
    
    // step 4. start finding ads and parsing them
    [SAXMLParser searchSiblingsAndChildrenOf:root forName:@"Ad" andInterate:^(SAXMLElement *adElement) {
        
        // check ad type
        BOOL isInLine = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"InLine"];
        BOOL isWrapper = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"Wrapper"];
        
        // normal InLine case
        if (isInLine) {
            SAVASTAd *inlineAd = [self parseAdXML:adElement];
            [ads addObject:inlineAd];
        }
        // normal Wrapper case
        else if (isWrapper){
            // get the Wrapper type ad
            SAVASTAd *wrapperAd = [self parseAdXML:adElement];
            
            // get VAStAdTagURI
            NSString *VASTAdTagURI = @"";
            SAXMLElement *redirect = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:adElement forName:@"VASTAdTagURI"];
            if (redirect) {
                VASTAdTagURI = [redirect getValue];
            }
            
            // call back this function recursevly
            NSMutableArray *foundAds = [self parseVAST:VASTAdTagURI];
            
            // now try to joing creatives - that's a bit tricky
            // step 1: remove all creatives other than one from the Wrapper
            [wrapperAd.Creatives removeAllButFirstElement];
            // step 2: now go through the resulting ads, remove all but one
            // element from the creatives, and sum them
            for (SAVASTAd *foundAd in foundAds) {
                // [foundAd.Creatives removeAllButFirstElement];
                [foundAd sumAd:wrapperAd];
            }
            
            // add the object of the array to the main array
            [ads addObjectsFromArray:foundAds];
        }
    }];
    
    return ads;
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
    ad.Creatives = [[NSMutableArray alloc] init];
    
    // check ad type
    BOOL isInLine = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"InLine"];
    BOOL isWrapper = [SAXMLParser checkSiblingsAndChildrenOf:adElement forName:@"Wrapper"];
    
    if (isInLine) ad.type = InLine;
    if (isWrapper) ad.type = Wrapper;
    
    // get errors
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Error" andInterate:^(SAXMLElement *errElement) {
        [ad.Errors addObject:[SAUtils decodeHTMLEntitiesFrom:[errElement getValue]]];
    }];
    
    // get impressions
    ad.isImpressionSent = false;
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Impression" andInterate:^(SAXMLElement *impElement) {
        [ad.Impressions addObject:[SAUtils decodeHTMLEntitiesFrom:[impElement value]]];
    }];
    
    // get creatives
    [SAXMLParser searchSiblingsAndChildrenOf:adElement forName:@"Creative" andInterate:^(SAXMLElement *creativeElement) {
        SAVASTCreative *linear = [self parseCreativeXML:creativeElement];
        if (linear) {
            [ad.Creatives addObject:linear];
        }
    }];
    
    // now do a check - if the
    
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
                _creative.playableDiskURL = [[SAFileDownloader getInstance] downloadFileSync:_creative.playableMediaURL];
                if (_creative.playableDiskURL != NULL) {
                    NSLog(@"Downloaded %@ on %@", _creative.playableMediaURL, _creative.playableDiskURL);
                    _creative.isOnDisk = true;
                }
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
