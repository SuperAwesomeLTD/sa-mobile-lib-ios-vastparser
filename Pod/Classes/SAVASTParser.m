//
//  SAVAST2Parser.m
//  Pods
//
//  Created by Gabriel Coman on 17/12/2015.
//
//

#import "SAVASTParser.h"

// import XML
#import "TBXML.h"
#import "TBXML+SAStaticFunctions.h"

// import helpes
#import "SAVASTAd.h"
#import "SAVASTCreative.h"
#import "SALinearCreative.h"
#import "SANonLinearCreative.h"
#import "SACompanionAdsCreative.h"
#import "SAImpression.h"
#import "SATracking.h"
#import "SAMediaFile.h"

// import Utils
#import "SAUtils.h"
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
    NSError *xmlError = NULL;
    TBXML *tbxml = [[TBXML alloc] initWithXMLData:xmlData error:&xmlError];
    if (xmlError) {
        return ads;
    }
    
    // step 2. get the correct reference to the root XML element
    __block TBXMLElement *root = tbxml.rootXMLElement;
    
    // step 3. if no "Ad" elements are found, just don't continue
    if (![TBXML checkSiblingsAndChildrenOf:root forName:@"Ad"]){
        return ads;
    }
    
    // step 4. start finding ads and parsing them
    [TBXML searchSiblingsAndChildrenOf:root forName:@"Ad" andInterate:^(TBXMLElement *adElement) {
        
        // check ad type
        BOOL isInLine = [TBXML checkSiblingsAndChildrenOf:adElement->firstChild forName:@"InLine"];
        BOOL isWrapper = [TBXML checkSiblingsAndChildrenOf:adElement->firstChild forName:@"Wrapper"];
        
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
            NSValue *uriPointer = [TBXML findFirstIntanceInSiblingsAndChildrenOf:adElement->firstChild forName:@"VASTAdTagURI"];
            if (uriPointer) {
                TBXMLElement *uriElement = [uriPointer pointerValue];
                VASTAdTagURI = [SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:uriElement]];
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

- (SAVASTAd*) parseAdXML:(TBXMLElement *)adElement {
    // create ad
    SAVASTAd *ad = [[SAVASTAd alloc] init];
    
    // get attributes
    ad._id = [TBXML valueOfAttributeNamed:@"id" forElement:adElement];
    ad.sequence = [TBXML valueOfAttributeNamed:@"sequence" forElement:adElement];
    ad.type = Invalid;
    
    // init arrays of data
    ad.Errors = [[NSMutableArray alloc] init];
    ad.Impressions = [[NSMutableArray alloc] init];
    ad.Creatives = [[NSMutableArray alloc] init];
    
    // check ad type
    BOOL isInLine = [TBXML checkSiblingsAndChildrenOf:adElement->firstChild forName:@"InLine"];
    BOOL isWrapper = [TBXML checkSiblingsAndChildrenOf:adElement->firstChild forName:@"Wrapper"];
    
    if (isInLine) ad.type = InLine;
    if (isWrapper) ad.type = Wrapper;
    
    // get errors
    [TBXML searchSiblingsAndChildrenOf:adElement->firstChild forName:@"Error" andInterate:^(TBXMLElement *errElement) {
        [ad.Errors addObject:[SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:errElement]]];
    }];
    
    // get impressions
    [TBXML searchSiblingsAndChildrenOf:adElement->firstChild forName:@"Impression" andInterate:^(TBXMLElement *impElement) {
        // the impression object is now a more complex one
        SAImpression *impr = [[SAImpression alloc] init];
        impr.isSent = false;
        impr.URL = [SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:impElement]];
        [ad.Impressions addObject:impr];
    }];
    
    // get creatives
    [TBXML searchSiblingsAndChildrenOf:adElement->firstChild forName:@"Creative" andInterate:^(TBXMLElement *creativeElement) {
        SALinearCreative *linear = [self parseCreativeXML:creativeElement];
        if (linear) {
            [ad.Creatives addObject:linear];
        }
    }];
    
    // now do a check - if the
    
    return ad;
}

- (SALinearCreative*) parseCreativeXML:(TBXMLElement *)element {
    // first find out what kind of content this creative has
    // is it Linear, NonLinear or CompanionAds?
    BOOL isLinear = [TBXML checkSiblingsAndChildrenOf:element->firstChild forName:@"Linear"];
    
    // init as a linear Creative
    if (isLinear) {
        // create linear creative
        SALinearCreative *_creative = [[SALinearCreative alloc] init];
        
        // get attributes
        _creative.type = Linear;
        _creative._id = [TBXML valueOfAttributeNamed:@"id" forElement:element];
        _creative.sequence = [TBXML valueOfAttributeNamed:@"sequence" forElement:element];
        
        // create arrays
        _creative.ClickTracking = [[NSMutableArray alloc] init];
        _creative.CustomClicks = [[NSMutableArray alloc] init];
        _creative.MediaFiles = [[NSMutableArray alloc] init];
        _creative.TrackingEvents = [[NSMutableArray alloc] init];
        
        // populate duration
        [TBXML searchSiblingsAndChildrenOf:element->firstChild forName:@"Duration" andInterate:^(TBXMLElement *durElement) {
            _creative.Duration = [TBXML textForElement:durElement];
        }];
        
        // populate clickthrough
        [TBXML searchSiblingsAndChildrenOf:element->firstChild forName:@"ClickThrough" andInterate:^(TBXMLElement *clickElement) {
            _creative.ClickThrough = [TBXML textForElement:clickElement];
            _creative.ClickThrough = [SAUtils decodeHTMLEntitiesFrom:_creative.ClickThrough];
            _creative.ClickThrough = [_creative.ClickThrough stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            _creative.ClickThrough = [_creative.ClickThrough stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
            _creative.ClickThrough = [_creative.ClickThrough stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        }];
        
        // populate click tracking array
        [TBXML searchSiblingsAndChildrenOf:element->firstChild forName:@"ClickTracking" andInterate:^(TBXMLElement *ctrackElement) {
            [_creative.ClickTracking addObject:[SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:ctrackElement]]];
        }];
        
        // populate custom clicks array
        [TBXML searchSiblingsAndChildrenOf:element->firstChild forName:@"CustomClicks" andInterate:^(TBXMLElement *cclickElement) {
            [_creative.CustomClicks addObject:[SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:cclickElement]]];
        }];
        
        // populate media files
        [TBXML searchSiblingsAndChildrenOf:element->firstChild forName:@"MediaFile" andInterate:^(TBXMLElement *cMediaElement) {
            // since this is a more "complex" object, wich takes data from
            // attributes as well as tag value, split the
            // declaration and array assignment
            SAMediaFile *mediaFile = [[SAMediaFile alloc] init];
            mediaFile.width = [TBXML valueOfAttributeNamed:@"width" forElement:cMediaElement];
            mediaFile.height = [TBXML valueOfAttributeNamed:@"height" forElement:cMediaElement];
            mediaFile.type = [TBXML valueOfAttributeNamed:@"type" forElement:cMediaElement];
            mediaFile.URL = [SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:cMediaElement]];
            
            // only add the Media file if the type is MP4
            if ([mediaFile.type rangeOfString:@"mp4"].location != NSNotFound ||
                [mediaFile.URL rangeOfString:@".mp4"].location != NSNotFound) {
                [_creative.MediaFiles addObject:mediaFile];
            }
        }];
        
        // populate tracking
        [TBXML searchSiblingsAndChildrenOf:element->firstChild forName:@"Tracking" andInterate:^(TBXMLElement *cTrackingElement) {
            // since this is also a more "complex" object, which takes data from
            // attributes as well as tag value, split the declaration and
            // array assignmenent
            SATracking *tracking = [[SATracking alloc] init];
            tracking.event = [TBXML valueOfAttributeNamed:@"event" forElement:cTrackingElement];
            tracking.URL = [SAUtils decodeHTMLEntitiesFrom:[TBXML textForElement:cTrackingElement]];
            [_creative.TrackingEvents addObject:tracking];
        }];
        
        // get the designated playable Media File
        if (_creative.MediaFiles > 0){
            _creative.playableMediaURL = [(SAMediaFile*)_creative.MediaFiles.firstObject URL];
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
