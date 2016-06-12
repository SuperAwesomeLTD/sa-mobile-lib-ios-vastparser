//
//  SAUtils.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAUtils.h"
#import "SAExtensions.h"
#import "NSString+HTML.h"

// constants with user agents
#define iOS_Mobile_UserAgent @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25";
#define iOS_Tablet_UserAgent @"Mozilla/5.0 (iPad; CPU OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53";

@implementation SAUtils

////////////////////////////////////////////////////////////////////////////////
// Trully aux functions
////////////////////////////////////////////////////////////////////////////////

+ (CGRect) mapOldFrame:(CGRect)frame toNewFrame:(CGRect)oldframe {
    
    CGFloat newW = frame.size.width;
    CGFloat newH = frame.size.height;
    CGFloat oldW = oldframe.size.width;
    CGFloat oldH = oldframe.size.height;
    if (oldW == 1 || oldW == 0) { oldW = newW; }
    if (oldH == 1 || oldH == 0) { oldH = newH; }
    
    CGFloat oldR = oldW / oldH;
    CGFloat newR = newW / newH;
    
    CGFloat X = 0, Y = 0, W = 0, H = 0;
    
    if (oldR > newR) {
        W = newW;
        H = W / oldR;
        X = 0;
        Y = (newH - H) / 2.0f;
    }
    else {
        H = newH;
        W = H * oldR;
        Y = 0;
        X = (newW - W) / 2.0f;
    }
    
    return CGRectMake(X, Y, W, H);
}

+ (BOOL) isRect:(CGRect)target inRect:(CGRect)frame {
    // window
    CGFloat x11 = frame.origin.x;
    CGFloat y11 = frame.origin.y;
    CGFloat x12 = frame.origin.x + frame.size.width;
    CGFloat y12 = frame.origin.y + frame.size.height;
    
    // banner
    CGFloat x21 = target.origin.x;
    CGFloat y21 = target.origin.y;
    CGFloat x22 = target.origin.x + target.size.width;
    CGFloat y22 = target.origin.y + target.size.height;
    
    CGFloat x_overlap = MAX(0, MIN(x12, x22)) - MAX(x11, x21);
    CGFloat y_overlap = MAX(0, MIN(y12, y22)) - MAX(y11, y21);
    
    // overlap area
    CGFloat overlap = x_overlap * y_overlap;
    
    // banner area
    CGFloat barea = target.size.width * target.size.height;
    
    // treshold
    CGFloat treshold = barea / 2.0f;
    
    return overlap > treshold;
}

+ (NSInteger) randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max {
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

+ (NSString*) findSubstringFrom:(NSString*)source betweenStart:(NSString*)start andEnd:(NSString*)end {
    NSRange startRange = [source rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [source length] - targetRange.location;
        NSRange endRange = [source rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [source substringWithRange:targetRange];
        }
    }
    
    return nil;
}

+ (NSString*) generateUniqueKey {
    // constants
    const NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    const NSInteger length = [alphabet length];
    const NSInteger dauLength = 32;
    
    // create the string
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < dauLength; i++) {
        u_int32_t r = arc4random() % length;
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

////////////////////////////////////////////////////////////////////////////////
// System type functions
////////////////////////////////////////////////////////////////////////////////

+ (SASystemSize) getSystemSize {
    BOOL isIpad = [(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"];
    return (isIpad ? size_tablet : size_mobile);
}

+ (NSString*) getVerboseSystemDetails {
    switch ([self getSystemSize]) {
        case size_tablet: return @"ios_tablet";
        case size_mobile: return @"ios_mobile";
    }
}

+ (NSString *) getDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

+ (NSString*) filePathInDocuments:(NSString*)fpath {
    return [[self getDocumentsDirectory] stringByAppendingPathComponent:fpath];
}

////////////////////////////////////////////////////////////////////////////////
// URL and Network request helper classes
////////////////////////////////////////////////////////////////////////////////

+ (NSString*) getUserAgent {
    switch ([self getSystemSize]) {
        case size_tablet: return iOS_Tablet_UserAgent;
        case size_mobile: return iOS_Mobile_UserAgent;
        
    }
}

+ (NSInteger) getCachebuster {
    NSInteger min = 1000000, max = 1500000;
    return [self randomNumberBetween:min maxNumber:max];
}

+ (NSString*) encodeURI:(NSString*)stringToEncode {
    return CFBridgingRelease(
        CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef)stringToEncode,
            NULL,
            (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
        )
    );
}

+ (NSString*) formGetQueryFromDict:(NSDictionary *)dict {
    NSMutableString *query = [[NSMutableString alloc] init];
    NSMutableArray *getParams = [[NSMutableArray alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull end) {
        [getParams addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    } atEnd:^{
        [query appendString:[getParams componentsJoinedByString:@"&"]];
    }];
    
    return query;
}

+ (NSString*) encodeJSONDictionaryFromNSDictionary:(NSDictionary *)dict {
    NSMutableString *stringJSON = [[NSMutableString alloc] init];
    NSMutableArray *jsonFields = [[NSMutableArray alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull end) {
        if ([obj isKindOfClass:[NSString class]]){
            [jsonFields addObject:[NSString stringWithFormat:@"\"%@\":\"%@\"", key, obj ]];
        } else {
            [jsonFields addObject:[NSString stringWithFormat:@"\"%@\":%@", key, obj ]];
        }
    } atEnd:^{
        [stringJSON appendFormat:@"{%@}", [jsonFields componentsJoinedByString:@","]];
    }];
    
    return [self encodeURI:stringJSON];
}

+ (NSString*) decodeHTMLEntitiesFrom:(NSString*)string {
    return [string stringByDecodingHTMLEntities];
}

+ (NSString*) findBaseURLFromResourceURL:(NSString*)resourceURL {
    if (!resourceURL) return nil;
    if (![self isValidURL:resourceURL]) return nil;
    NSString *workString = [resourceURL stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSArray *components = [workString componentsSeparatedByString:@"/"];
    NSMutableArray *newComponents = [@[] mutableCopy];
    for (int i = 0; i < components.count - 1; i++){
        [newComponents addObject:components[i]];
    }
    NSMutableString *result = [[newComponents componentsJoinedByString:@"/"] mutableCopy];
    if ([self isValidURL:result]) return [result stringByAppendingString:@"/"];
    return nil;
}

+ (BOOL) isValidURL:(NSObject *)urlObject {
    if (![urlObject isKindOfClass:[NSString class]] || urlObject == nil) return false;
    NSURL *candidateURL = [NSURL URLWithString:(NSString*)urlObject];
    if (candidateURL && candidateURL.scheme && candidateURL.host) return true;
    return false;
}

////////////////////////////////////////////////////////////////////////////////
// UIImage classes
////////////////////////////////////////////////////////////////////////////////

+ (UIImage*) closeImage {
    NSMutableString *imageString = [[NSMutableString alloc] init];
    [imageString appendString:@"iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAAAXNSR0IArs4c6QAA"];
    [imageString appendString:@"ABxpRE9UAAAAAgAAAAAAAABAAAAAKAAAAEAAAABAAAADNgS9T/UAAAMCSURBVHgB"];
    [imageString appendString:@"7JlLbhNREEUtkBCLADLhtwgWwAJYmj2xLcufkdeDGJIw4bOAMIgU5VGFXFGpcQd/"];
    [imageString appendString:@"+nXqdt1BqTuO0uV+59R9dmdUShmx8q4B4ScfAApAAfLGH7e+MmICMAGYAJmTgAnA"];
    [imageString appendString:@"BGACMAGSTwEFoABpt8K0N5556v29U4Dk6UcBKAC/BfhIzHbOBGACMAGyTb2/XyYA"];
    [imageString appendString:@"E4AJ4Cci2zkTgAnABMg29f5+mQBMACaAn4hs50wAJgATINvU+/tlAjABmAB+IrKd"];
    [imageString appendString:@"MwGYAEyAbFPv75cJwARgAviJyHbOBGACMAGyTb2/XyYAE4AJ4Cci2/kgEmA8Hj/t"];
    [imageString appendString:@"G5z0fNZ3zxr94AUQEC+kvkh9rLFA+66pvaSupN7v+z3Sa9ACCACF/1WqSN1IVZdA"];
    [imageString appendString:@"e+x6ac9fUtASwAogC38PfzqdKozqEkiPe/iup0rwDmnq/XuFFEAW/KXU38mfz+dl"];
    [imageString appendString:@"u92W9XpdVQIPX3tpz8ViYT1/okoAJ8AO/qUci8FXGFqr1cqAdLod7INvPdElgBLg"];
    [imageString appendString:@"IfgGpGsJHoJvPRsSvPURG/0cRoBD4BuQriQ4BL71dBL8kL+DkQBCAFnQV1J7Y98A"];
    [imageString appendString:@"NI/nSnAMfOuNKEF4AXbwr+T4z55vC992PFWCU+Dbe2hI8IZbwBnP2s+Bb0COleAc"];
    [imageString appendString:@"+NYTSYKwCSAgLqROmnwDYcdDJegCvvV0EnyX64ZNgpAC7OB/k+PRsW8Amsf/SeDg"];
    [imageString appendString:@"39n3/OY1jv25IcHriNtBOAFqwDdwbRLUgG89o0sQSoCa8A1IU4Ka8K1nZAnCCCAg"];
    [imageString appendString:@"nkh9lir6nN0Wr8axIYE+News9tve72w2s6eUurU9j7IdhBFAF0QW5oPUtVRZLpd9"];
    [imageString appendString:@"SVAd/mazKZPJ5E7u61bqUxT4+j5CCfAYEnT1ga9t8iPDDylA3xK0gevi9ejwwwow"];
    [imageString appendString:@"BAkQ4IcWoCmBfnDrYir7uAYK/PACIEqABB9CACQJ0ODDCIAgASJ8KAEiS4AKH06A"];
    [imageString appendString:@"iBIgw4cUIJIE6PBhBYggwRDgQwvwmBIMBT68AE6C3/oPpD4eFg0Jvq7fHwAAAP//"];
    [imageString appendString:@"lVBvPwAAAx9JREFU7ZlLbttQDEWDFii6iLaZ9LeILiALyNLsiW0Y/oy8nqLDfib9"];
    [imageString appendString:@"LCAdFCiiXhZi8SCEhi3puaR4B8RzXhBR5D28Up6vmqa5ihyz2ewW8Xs+n9/v9/vm"];
    [imageString appendString:@"cDhUje122yCfxE/Eu8i9k3un+D2AKSC4iw5BWADQ+FvExSa/6yxTgSAkAP9bfIVh"];
    [imageString appendString:@"ChCEA8CL+FOBIBQA3sSfAgRhAPAqfnQIQgDgXfzIELgHIIr4USFwDUA08SNC4BaA"];
    [imageString appendString:@"qOIrBJvNRk8M71CL2xNDlwBEFz8SBO4AuKT4u92ukcMcFazG6t0JXAFwafGR7x6R"];
    [imageString appendString:@"GgI3AECIp4gvIshyuaw6lTL5yCPi/2qjOgSLxULfCd4j5yMv3yK6AUAagsa8RHxF"];
    [imageString appendString:@"NOv1ugoEHfFvkEtCQKgGwWq1UvEF8Gsv4st9uAKgNgRd8VWImhB4Ft8lALUgsMSv"];
    [imageString appendString:@"CYF38d0C0ELwCpM5yuOgFV9sWKz+RkXvrmM6QSH+Z1z3upvLy8/uHgFlY9A4geAb"];
    [imageString appendString:@"ovc7wania17kGvxO0BH/hV7b4+oaAGnYEAjOFV8FGgJBJPGlXvcAtBC8hihnOUFf"];
    [imageString appendString:@"8YdAUIj/CffrevK1zhAAnAvBUPG1Oec4QUf853oN72sYAAoIvkMY851gLPFVuFMg"];
    [imageString appendString:@"iCq+1BgKgBaCNxDlQQjGFv8UCCKLHxIAC4Ja4j8EgeSSL44K8T8CyjC2rzWFBaCA"];
    [imageString appendString:@"4Ic8Dopz9qP/55eF9/lcPg6KnCL+sz7X8/A34R4BZdPQ+LeIvxBgrSq+5kWef+cE"];
    [imageString appendString:@"+BxafKkpNABSAEQQCOS0zTzhU/HGWiUX4gMi7ORrL8ID0ELwRAu61ArxH18qV808"];
    [imageString appendString:@"kwCgZoOmfm0CgMfI1EU+Vl/q4o81JsvvCAAdILcFZpl0q046AB2ADmBNR4Z9OgAd"];
    [imageString appendString:@"gA6QYdKtGukAdAA6gDUdGfbpAHQAOkCGSbdqpAPQAegA1nRk2KcD0AHoABkm3aqR"];
    [imageString appendString:@"DkAHoANY05Fhnw5AB6ADZJh0q0Y6AB2ADmBNR4Z9OgAdgA6QYdKtGukAdAA6gDUd"];
    [imageString appendString:@"GfbpAHQAOkCGSbdqpAPQAegA1nRk2KcD0AHoABkm3aqRDpDcAf4AbuAOWc2aNWwA"];
    [imageString appendString:@"AAAASUVORK5CYII="];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imageData];
}

+ (UIImage*) padlockImage {
    NSMutableString *imageString = [[NSMutableString alloc] init];
    [imageString appendString:@"iVBORw0KGgoAAAANSUhEUgAAAaYAAACbCAYAAAAp4j/EAAAAAXNSR0IArs4c6QAA"];
    [imageString appendString:@"ABxpRE9UAAAAAgAAAAAAAABOAAAAKAAAAE4AAABNAAAbAtZkxKwAABrOSURBVHgB"];
    [imageString appendString:@"7F0JlFXFtQVxQBNwAEc0EFxKHOFjBGNQEdDgiMIn4LhUEMRmFCPqF/mJKEYFCbqA"];
    [imageString appendString:@"COaLE8FPohFdkWjyEUkUlyOIAWlFFGloRJrQdEP3635/b1bqrXqXuu+O/e7wTq91"];
    [imageString appendString:@"Vt2+t4ZTp06dfevcenWaZbPZjUIiA9EB0QHRgdLTgW3btq2+8oorftXr/PPHgq4F"];
    [imageString appendString:@"9QKdBDoc1BK0D/SimR3heTM/ZFefus8GBZhEBqIDogOiAyWmA42Njd/cd999MwEs"];
    [imageString appendString:@"vwANAV0C+g9QO9D3QPuCmiuwMKV4LsAkICovEaIDogOiA+HowJtLlvwZwHIXaARo"];
    [imageString appendString:@"AOgnoB+CDgHtDyoISgQq5PFFLFuIZMVUYm9JMqnDmdQiR5FjknWgsrLyk0suvngS"];
    [imageString appendString:@"gGUM6BqQcuG1xbWjC0+BCvIKMCVZEYR3MWSiA6IDcdCBhoaGDXdOmDADoHI76CbQ"];
    [imageString appendString:@"xSBPLjz0Y8+KB+UEmOIwqMKDGBfRAdGBJOvA4tdeexmAcieILrz+IN2Ftx/+d3Th"];
    [imageString appendString:@"of8CTElWAuFdjJjogOhAXHRg48aNH114wQX3AnzowrsadD7oRyBPLjz0R4ApLoMq"];
    [imageString appendString:@"fIiBER0QHUiqDtTX1389ZvToaQAh3YXXGf8fA+IuvBYg16slyMGXGw9t7AE1lrcj"];
    [imageString appendString:@"PpBtoiID0QHRAdGBlOvAiy++uBCgQBfeLaArQWeBOoAOBnly4SlAQTlf4KTK26UC"];
    [imageString appendString:@"TClXRnnxkBcv0QHRgS+//PK93r16TQSQjAZdBeoJ6gSiC+8AUMEf0toBCMoJMMkE"];
    [imageString appendString:@"kwkmOiA6IDrgTQd279795fBhwx4CiIwH3QDqCwrkwlNAhXoEmEQhvSmkyEvkJTog"];
    [imageString appendString:@"OvDcc889DwCZABoOugLUHdQe5NuFJ8Akrjbx/YsOiA6IDvjSgTVr1rwNAPov0EjQ"];
    [imageString appendString:@"INC5oBNBbUC+XXgCTKKQvhRS3pTlTVl0oLR1oLa29osbb7hhCgBoHOh60AWgU0FH"];
    [imageString appendString:@"gg4Ced6FpwBJpahDXHky0Up7osn4y/iLDrjXgSeeeGIegOMO0M2gy0BngI4DtQI5"];
    [imageString appendString:@"HtCqwKdQinoEmEQp3SulyEpkJTpQujqwcsWKpQCNu0FloIGgn4KOBx0K4gGtvnbh"];
    [imageString appendString:@"WUEK9QgwyUQr3YkmYy9jLzrgTgd27NhRPmjQoMkADRVjqTeuTwYdAToQFNiFpwAK"];
    [imageString appendString:@"dQkwiWK6U0yRk8hJdKA0dQAxljZOf/TRuQAMxlgaCroU1BV0LOj7oFBceAJMATY/"];
    [imageString appendString:@"rF69unL27NlVo0aNqu7bt2/tiSeeWN+2bduGAw88sLFZs2ZZEq/btGnT0KlTp3rm"];
    [imageString appendString:@"GTlyZPWsWbOqWFYmd2lObhl3Gfek6sC7y5f/FeBDF96toP8EnQ3qCFIxlkJx4Qkw"];
    [imageString appendString:@"eQAm/JBsI47d2Dp48OCao446KqPAx2965JFHNmBJXPPSSy9tZd1JVVbhWwyt6ED6"];
    [imageString appendString:@"dYBh0vtfeeWvAELKhdcL167DpCuw8ZKifnHl2U2u8vLyzcOHD6/myscvCDmVO+SQ"];
    [imageString appendString:@"QxpGjBhR/fnnn2+240Pup3/yyxjLGMdRBxgm/f7Jk2cBKExh0kN34UEGew5gFWAy"];
    [imageString appendString:@"rJxWrlxZOXDgwJoWLVrsccvZgQuft2/fPtOnT5/d119/fW1ZWVnN3XffvZPEa97j"];
    [imageString appendString:@"M+ZxU9eAAQNqPvnkE3H1GcYkjpNWeBIwSbsOLF269DWABMOk04XnK0y6AhsvqQCT"];
    [imageString appendString:@"ZgSrqqoqACjVdiDSvHnzbI8ePer/e9KkuqVLlmR27dyZzWYyroh5WYZlWQfrMgHe"];
    [imageString appendString:@"vvvumyUPW7du3ZR2pZf+iWEXHYivDiBM+iqbMOmHAzhch0n3AkgqrwDTv4Fp4cKF"];
    [imageString appendString:@"33EDgwksOnbsmHlwypS6DevXN7oFIqd8rIt1sm5Tm4cffngDv2vJxI3vxJWxkbFJ"];
    [imageString appendString:@"qw4wTDo8P48BIBhjaQjoYpCvMOkKbLykaKu0vzHheI2KYcOGVZvA4bTTTsssmD+/"];
    [imageString appendString:@"vqGuztWqyAmMTM9ZN9tgWyYehg4durOmpqYirRNA+iXGXXQgfjqwePHiRQAHuvAC"];
    [imageString appendString:@"h0n3Akgqb0kD04YNGzZ16dKlzgoI3Oww94knmhSQrCBFgGKbpo0WZ5555u5N+JMJ"];
    [imageString appendString:@"HL8JLGMiY5I2HUCY9I/7/uxnoYVJV2DjJS1ZYPr0008rjz766L1WKT8fOLDuuy1b"];
    [imageString appendString:@"QnPZWQHI6X+2TR6sYPmDH/wgI7+BEiOYNiMo/YmXTjNM+rhx4x4FMOhh0rvgf99h"];
    [imageString appendString:@"0r0AkspbksD04YcfVh522GF535NatmzZOHfOnHon4CjWc/JCnnSA4mqKvMtkjtdk"];
    [imageString appendString:@"lvGQ8UiLDuC3lX8AKKgw6f1xHThMugIbL2nJARN/m2T9kSxB6t133skUC3TctkOe"];
    [imageString appendString:@"rABK3tmHtEwE6YcYddGBeOjA+vww6VcDHHqCOoEChUn3Akgqb0kB0/bt2yt4fJC+"];
    [imageString appendString:@"CuFvjNauXt3gFizs8tXv2pXdvHFj9ou1axtJlRUVWd6zy+/2Pnnr0KFDnsvx5JNP"];
    [imageString appendString:@"rseBirIhQtvqL8YtHsZNxiGZ44ATaNaPuOWWhwEI40E3gEILk67AxktaUsDUr1+/"];
    [imageString appendString:@"Wh2UeDTQZ//8py9Q+uarrxpnz5yZwfcgnoeX5e+P9Lp5zXt8xjzMyzJuAUnPRx7J"];
    [imageString appendString:@"q14/+8KDFcUQJNMQyLjJuMVJBxAmfT7AYAJoOOgKUHdQKGHSvQCSyou2S2O7+COP"];
    [imageString appendString:@"PLJdN+ytWrVqXPHRR55AqbG+PrvoT3/K9O7Vq3GfffbZC4j0+k3XLMOyrIN16eDj"];
    [imageString appendString:@"dE1eybNe79SpU6vipNzCixhb0YHk6cBnn332DoCgycKkK7DxkpYEMK1du3azdSPB"];
    [imageString appendString:@"whde8LTRAac2NHTp3DkPGHSQ8HrNulinEyDpz8mz3s5BBx3UyL6JMUieMZAxkzGL"];
    [imageString appendString:@"gw7gd5zrmjpMuhdAUnlLAphwXt0u3aCPGjmyTjf4ha5rduzI3jx0aJ4bTa8L4S2y"];
    [imageString appendString:@"Pc87r4F1Pvzww7Vz5szZSeI17/EZ8+hl9GvWzTYK8aA/Y516+XPPPRcfsmSSiwxE"];
    [imageString appendString:@"B0QHvOsAdv8+DRDQw6T/GP+HGiZdgY2XNPXA9MILL3ynG3JuJKitrnYFBOu/+KLx"];
    [imageString appendString:@"lFNO2QtUeM7d5Zdf3vCHhQt37Nq1y3ETAvMwL8uYzshjG2xLByC7a/Ju3QzB8Bky"];
    [imageString appendString:@"Kb1PSpGZyKyUdQCHVb8FAGCMpSYNk+4FkFTeVAMTNweceuqpeSuMxa+95mpb+KqV"];
    [imageString appendString:@"KxuOOeaYvUDpor59GzCgvoGAZVmHDpa8Zlts0w6Q9Pvsg16efZSNEGJkS9nISt+9"];
    [imageString appendString:@"6X91dXX5VYMHM0z6ONB1oD6gU0Chh0lXYOMlBR/p3fywYMGCvNUSIsm6+q60rry8"];
    [imageString appendString:@"sV27dnmghI0H2WeefhrHiXtTALv8T8+bV806dYBhm2xbByG7a/ZFL8u+2rUl98MZ"];
    [imageString appendString:@"M5GjyDENOsCX2N9Mn24XJr0VQCHUMOmQ2Z4YS17SVAPT2WefvVs33v9YtsxxtcTv"];
    [imageString appendString:@"PThQNW+TA44Dyq74+OPQDT/q3Mq6dR7ZtptvTuyLXq5nz57yrSmkl4Y0GB/pg4Co"];
    [imageString appendString:@"nQ68/957f4PhpwuvKGHSvQCSyptaYOJuNYvhdrVaGnbzzXlutj2rmHXrttgNctD7"];
    [imageString appendString:@"61C3dXU2fNgwVy49gFHeqknO0hNjFFQfpXy6dQgx56xh0nsDBE4G5WIs4bo59MDz"];
    [imageString appendString:@"KifMMqkFprvuumuHDkzPP/usIzC99eabeaCE7djZjz78MPSVknXysw22pfNLXuzc"];
    [imageString appendString:@"eOo++6SXQZ//Za1b/k+3oZHxlfF1qwNw4X3zwAMPzIbRL2qYdPDnGeRSC0w4tie3"];
    [imageString appendString:@"6aF169aNbnbide/WLc+FN3vWrBq3gx40H9vSQYa8KACyS9kn9k2VYwiPoHxIeTF0"];
    [imageString appendString:@"ogPp1IFlb70VSZh06JMAEycVYxcpY8108KBBjr9b+vOrr+atls7p0QMvGMU78odt"];
    [imageString appendString:@"sU2db/JkB0rqPvuml/n666/lB7fyrUmOqhIdyNOBb7/9dtWll1wyCSuRsaBrQL1A"];
    [imageString appendString:@"J4FyLjw/ANJUZcBX+nblzZs3b5turJ+cM8cRmC6/7LI8UMDbRdGP+3lr6dIqne8r"];
    [imageString appendString:@"+vVzXDWxb3qZZ599tsldjwR/IZGB6EAydIBh0ifec8/jMPaMscQw6ZeAihYm3Q94"];
    [imageString appendString:@"gb/0AVNZWVleqHSnH68iOF/eIaxndO3aGNWkY9sKaHgILHlTqyNTyr6p/EzHjh2L"];
    [imageString appendString:@"YySimzBLliz5bubMmTsQrn7X8ccfn1uF8pr3pkyZsnPRokVVOB29ySPyDhgwIA+0"];
    [imageString appendString:@"KR/eCyqf999/f6su86DXlIsbnsJul3yzTjdth50nDmNzzjnnZCj7CRMm1OIQ039R"];
    [imageString appendString:@"d4uhl2HL0qm+1//yl1dg6FWY9AG4/gnoh6BDQPuBIt/sgD7kufvAU/qA6cILL8wd"];
    [imageString appendString:@"QXTwwQc7rjr+d8GCvK3Xj06bVus02E31nG3rho68mQBJv8c+qjLnnXeeKyMXNv+c"];
    [imageString appendString:@"2Jzoig83KUGqoqKiSVyPrNeOBxxaGWiXZdgAUWrAFPexIVBFBdhhz8uKGIRJR5/y"];
    [imageString appendString:@"QMfN/6kEJoYhV0apW7dujrvxRo8alXuzZ7k1a9Z8G7aCuK2PbSvemZI3HYRM1+yj"];
    [imageString appendString:@"KtOxY0ccW168FRPfME1vv4ofNylBLWyeWadd21zRBWlPgCmYfiVlbPjCEPQlJoie"];
    [imageString appendString:@"BS2byWS+vn38+Okw8nTh3QS6GNQFpMKkR/5DWvTRCFrgMX0rJj02kpuNDwxFoYzY"];
    [imageString appendString:@"oYceClkFm3hByyOEem7rOHkzgZF+T98AgQNji+aGJCh5XSUpOVtTrp6Cyk0vXwgs"];
    [imageString appendString:@"ybOe1+u1AFOw+ZGksaGe0vXsVUfikB9naP4RBj7yMOmQhRF8Ct1PHTDhGPcK3eiN"];
    [imageString appendString:@"LCtz3PiA7x85IDire/eiGXY75SUPqg/kTQch0zX7qPIzBWA4Hixr17aX+3yj1NsN"];
    [imageString appendString:@"eh10JaN451uuEy9B3oQFmPwDU9LGRulR0sBp/fr171/Qp89EGPjRIBUm/Ue4bgtq"];
    [imageString appendString:@"CdoH88UzYBSrDPhL14pp8+bNeVvF8aNTR2Bq27ZtDpguu/TSBmXgokqxQzDnWiRv"];
    [imageString appendString:@"JjDS792NPqoJxLS8vLxJvtvo8rAzztzkQIDhc/1DMq95j8+YR+dXv+YHaL0dP9ds"];
    [imageString appendString:@"Q6/TdB0EBO367odXL2WiatcLj0554zY2lKnasOO0+mdep/7F4TnDpJfdeusjMO6x"];
    [imageString appendString:@"CJMOmXgGwNQBE42yboiwTdIRmLB5IAdM1117bSA3TxiKSR5UH8ibDkKma/ZR5Wda"];
    [imageString appendString:@"DGCi601vk9cEHDcrEYKUnYGicdABzY88nQwMeQ3izosKIKJq188Y2JWJ+9hwZWT3"];
    [imageString appendString:@"4hREZ+zk0RT3fz9//u9h2GMTJh19FGASYCoOMJm+E3jdxEAjoIMbDYLXOqwT2+Qq"];
    [imageString appendString:@"IoiajI0bELXWz/+jAoio2jXJwM+9pIwNX4xM+k1dDaqffuTmpQzOCF0OUIpVmHTw"];
    [imageString appendString:@"L8AkwFQcYNIBRV3TcHqZRMyrdmjREISxddy0EqOrxrTC8+vOiwogomrX65ja5U/S"];
    [imageString appendString:@"2BCcTC8zcV41ISDpuptuvPFBABNjLF0PugB0Kugo0EGgFqDY/WYJ+rIXcIHPdH1j"];
    [imageString appendString:@"EmCKDpj8fh8K88Oy1VVE40JDSd4UgKrUr5GJCiCiatcOaLzeT9rYWFf0Sm84Dl77"];
    [imageString appendString:@"Xoz8c+fOfQYGXYVJvxzXPwapMOmx/CEt5LIXKPGeAFMmk5VvTN53WVmNDCet2x+K"];
    [imageString appendString:@"NtUktXMVqfZMb8B+jExUABFVu0p+QdKkjo1Jz/2utIPIz6nsqlWrlsGYqzDpP8d1"];
    [imageString appendString:@"D9DxoENB+4NivQsP/csDKPDrC5ys9Vj/ZyORnKcmK6birJhMrjGCE+9HNfZ2riLF"];
    [imageString appendString:@"j4lnP/xGBRBRtavkFyRN6tiY+I76Bcw6DnEPkw5+80DHzf8CTLJi8vUCYWckCU58"];
    [imageString appendString:@"y+S3o6C766wT0Ol/69utcuOpciZ3njWPylsotet7oTJhPIuq3TB4T+rYmHSGOh6G"];
    [imageString appendString:@"TMKog1EJHpsx40kYcsZYGgq6FNQVdCwoFmHS0U8BJlkxFWfFxEnFM8U4SQsR89BX"];
    [imageString appendString:@"39QgZTLaptWQyZ3n9duYqa1iGKuo2g1qQE18J2VsTLwXY6zdyhxh0v8PAGQKk55I"];
    [imageString appendString:@"F54CMfRJXHnyjcmf27XQtloTWHHnHVdSfrdpF5qsJjedCXBM+UxGslBbdsaKLh43"];
    [imageString appendString:@"5Hezh127Jlnb3WMdhfrWFM9MMi/22ATpl0mWUcjR2geESV8zoH//+2DEGWPpWlBv"];
    [imageString appendString:@"kB4mvQX+T8QuPPQtb1UFvtMDTMuXL99y22235f3q3+sPbPfbb789myEIVlEReVCT"];
    [imageString appendString:@"gTyYflSr37P+wJYyoCysitxU/6st34pnN6kCqbBWUtaVkJ2LzuSasctrJ6+gAEF5"];
    [imageString appendString:@"2dVd6H7QdjkuURjUOIxNIbk6PTPpcxRy1PmEC++bB6dMsYZJpwuvHej7oNge0Ip+"];
    [imageString appendString:@"5IGQ6f/EAxP27ldMnz696oQTTsidsK0rkldg0svG4doPMCm+KZMZM2ZUUUa6UjfF"];
    [imageString appendString:@"NX+DZHozVrzYpTRafg216ocJbAqtgqyGkryZ3uBV/dY0KED47W/QdtnPYhvUuIyN"];
    [imageString appendString:@"dQy9/G/S3WLL0crvsmXLFsN4M8bSrSDGWDob1BHEGEvchZfIlRL6uQe0wH9yV0yv"];
    [imageString appendString:@"vPLK1vbt2+eO77Eq0P777994/+TJjkcSIUxGZKsjp1UZedNXR6Zr9pF9tfZf/d+h"];
    [imageString appendString:@"Q4fMq6++WhQXDldAdFW5+f6k+GPKj+N+XXwmQCwENKb8hYDMahSCAkQpAZNJ1lGM"];
    [imageString appendString:@"jXUMvfyv66m6jhKYECb90ySFSVdg4yVNJDBxJ4rVZUeFOe644xruuOOOur+98UZm"];
    [imageString appendString:@"+3c4CxQ77kqJ2Gf2nTKgLNQkUun48eN3UHZeJmWQvAqkaJxMqxTFl0qZxw84Wevm"];
    [imageString appendString:@"/4X4Nr3FO5XR64sbMLn5rqXy+JGv3nev13EZG6986/mVfuppseWo+MH83XDvxImP"];
    [imageString appendString:@"w3AzxtIQUOzDpIN3R9edNU/igAnBrzYOHDiwRlcSBgac/9xz9Y31iJFXYmBk11/K"];
    [imageString appendString:@"4nnIRA+aSJlRdpShUvRipgQE0xu0Ppb89uSFJxPIuFn9WA0meXC7KcEOmLzw7Sdv"];
    [imageString appendString:@"VO364ZVl0jA2cZP5G6+/vghGO1Fh0qEL6Qem4cOHV+uGbMiQIXW11dUCSDaATNlQ"];
    [imageString appendString:@"RrrMKEO/xiaMclxJmX64qHh0CxDkxQR0dAuqFYJdagImuh/d9C8qYxVVu25kYsqT"];
    [imageString appendString:@"hrExgauX1bVJLn7vIUz6iov69p0EYBoDYoyl80GJibGEfrsGKPQrOd+YnnrqqW3K"];
    [imageString appendString:@"eDF18/3IbkVRavcpK112lKXfCRJWOQKQzpO6dgsQ5MMEMKoeP6mbXYJRAURU7fod"];
    [imageString appendString:@"7zSMjekFii87fmXitxzDpP/i9tt/A4NNF16iwqSjz64BSeVNDDBVVlZuQtjz3HeT"];
    [imageString appendString:@"sWPGOG5qKDXwcerv6FGjcuBEWVKmfieKKufGkKu8ptQ08d2+kdoBmx9AUmXcrNai"];
    [imageString appendString:@"Aoio2jWNm9O9tIyN9cQK6onfzStOMiv0fNHLL78IY80w6SNA/UFngTqADgYl6oBW"];
    [imageString appendString:@"9NMRqNCnZKyYxo4dm/t9UufOnevrauF1sXFfyX3zpg/K7PTTT8/tYqRMC02GQs8I"];
    [imageString appendString:@"SJygBJEgEzWIsfW680+BT6HUzWotCM+FZOr0LKp2nfgyPU/D2NjJu9gbHxAm/YN/"];
    [imageString appendString:@"h0lXLryeMNypdOFBl/aAViKACUawolWrVrnt0H99/fWMgI8ZfJzkQtkpw9y6detG"];
    [imageString appendString:@"ytZkWOzuEZD4Nqy7aXjtd7LaTX679tV98qH6EXbKulU7ptQvz6a6vNyLql0vPDJv"];
    [imageString appendString:@"WsaGG3GsusUVlFd5BMlfV1e3fmRZ2VQYarrwbgRdBOoMOgb0PVBiT3eAXGxXTuhX"];
    [imageString appendString:@"/FdM8+bNy31b6tq1a72T8ZXnhUGLMlQTjrL1OnFM7g1OYieDbmqHqy3Fi0rd+PBN"];
    [imageString appendString:@"riK6BU1tFLqnA6xq38mdFxVARNVuIfmZnqVhbEwbN6gfTrphkkeQewiTvgBGmi68"];
    [imageString appendString:@"W0BXgrqDUuvCg6ySs2K65pprdiqjMW3aNPm2FNCFOW3q1NybIGXrdeKYDA/Hh0ae"];
    [imageString appendString:@"xtNtfVxlmYDBDcCYXEV+Vm0mA+TkzosKIKJq1+14qnxJHhueYMIXI2Vv9LTYqyUc"];
    [imageString appendString:@"SL28d69eEwFEo0FXgejC6wRqAzoAlKgYS9AP2xWS9Rn6Fv8V00knnZR7w/9kxYoG"];
    [imageString appendString:@"WREVXhE5yYcyVBOOslUGxUtqN3lZL59xm61dfQQQ06YHxZNTiHWTq4gAZ9deoft2"];
    [imageString appendString:@"IFto9RcVQETVbiH5WZ8ldWyor3xJMb0oKb308+JjlY/b/7Uw6eNhpG8A9QWdDjoa"];
    [imageString appendString:@"lKgw6eiza0BSedHH+ANTy5Yt93xfat68eTaze7dsegi4YqIM1WSjbN1OFj0fDZDJ"];
    [imageString appendString:@"B6/qVSnzEKgUqft2qZuNFCYwoVHR+XN7bTKk5K2QyyYqgLBr106Wbu+7lZWbfHEd"];
    [imageString appendString:@"G6V/1tTkljbJrZA+uJGL1zy/e/LJZ2CcGSZ9GKgfqBuoPSiVu/AgnzzwQj/jD0xK"];
    [imageString appendString:@"Udq0aSOrpYCgpFZTlKWSq9dJo/JzZeN2Yqu2CqVuwcXkKiq0QlP82qWm+giodvnt"];
    [imageString appendString:@"AMIuf1j37dotJFM3z8Lij/WYZBmHsXEjB1MerqCKDUqGMOnnwFCfADoMlGoXHnQo"];
    [imageString appendString:@"Od+YlMIce+yxshsvJGCiLJVcgxgmrjhMxkjV7TZ1s1Iin6YVjl83nuq36S2ffNu5"];
    [imageString appendString:@"FO0AQtXXVKldu25lbJcvLH7jPDZ2fS90n6urYrrvOA47d+4sv/rqq+8HAI0DXQfq"];
    [imageString appendString:@"AzoFdCQo9S48yECASa0eSjENC5iUUaPR5EQuNNFNzwhqXia/CUTcrrQUr9bUZFDJ"];
    [imageString appendString:@"qx1Y2gGEtd6w/7dr1yRXL/fC4jPOY+NFHtRJyjosuXip5/HHHvsdAEgPk34G/k90"];
    [imageString appendString:@"mHT0P89N5+Z/9Dk5rjxZMQXb9KADcNjApCYfVxk06AQLK1BxZcN7fEYjRkBQ5dym"];
    [imageString appendString:@"pu9aQVxFql3Tqs/OnWcHEKqupkrt2vVidE15w+I3zmNj6jfvUR9J1FnqkR+dDEt+"];
    [imageString appendString:@"H3zwwRIYZD1M+k/xP2MsJTpMOuQjwKQbX/16y6ZN2T8uXJh96MEHs3fdeWd2zOjR"];
    [imageString appendString:@"joRjj7K/nDQpO3vmzOzbf/97KBsvGmtqs7uW/SNbPft/stvvn5rddse9nohlqn/7"];
    [imageString appendString:@"FOp4O9tYiyO7fLr2mgqYwpqkUo+/cPcit2TKbfv27akNky7AZDDS777zThYn8ma5"];
    [imageString appendString:@"o8/urcnt/SOOOCI76d57szuqqjwDQmbzluy2OydlNxx9QvarAw4LhTa065Stumdy"];
    [imageString appendString:@"tmGr99hTAkzJNGACPOkbN8ZIe+jXv/4tVkZ04akYS6kJkx4nYPp/AAAA//8UPM5q"];
    [imageString appendString:@"AAAPd0lEQVTtnQ1wVNUdxZNAE2lpbIUWgZQUmRbohxV0/OpUBaSDFiogDlNAK2IR"];
    [imageString appendString:@"a/BjLNLWKiBGdBxEKDptZzCIYCt1lGLacexkaKcSikijqGQEjGAIAkPUKJGQhNye"];
    [imageString appendString:@"P+bGTdj39r3lvt3LuyczZ96yy97dd+55/9+7d9/uzVFK7TOlnJwcJSoqKmpVra0q"];
    [imageString appendString:@"qBaVlqq8vLzjz9VtmNgOGjRIvb19e+D3cXTzVlV31tnqvYIzIlHdt4ap5tfeCPx+"];
    [imageString appendString:@"xD/xUnthqp/YjrnM00t3vNy4ceNLI0eM+A30S+hq6GLoLOgrUD6UizzkuCTsc046"];
    [imageString appendString:@"SuWRmJhVMP1+6VLjQNKFXLYo7OrAPuxiClC2vL1T7T1zUCRASgTd3gFDVGvN7pTv"];
    [imageString appendString:@"R79fgslcPk1mnW251S+HDh3a/tNx4xagCN8OTYVGQkOhr0GnQXmpim0cH8d+xw9M"];
    [imageString appendString:@"e2pqVEFBQaRgEjhNnTIlJQj2j74qcihpQB2cOC3l+yGY3Cp8BJ29/d3W1rZ3/vz5"];
    [imageString appendString:@"j6EI/wqaAf0EGgb1h74EdYecGy0JaLHfaSkVpLM6YppdUhI5lARMubm5qmbnTk8Y"];
    [imageString appendString:@"NP2nMmNQ0nBqrtrm+X40lGTLEZO9BYswcaNvKioqylGAZQrvZkim8C6CBkLOTuFp"];
    [imageString appendString:@"sMCDeIGpraVF9enTJyNgEjg9tGiRJwg+vPPujIPpo3tKPd8PweRGwSPY7O/nAwcO"];
    [imageString appendString:@"bLtizJh5KMC3QTKFNwIaAvWGnJ3Ciy2Y5KIEAUamNG7sWE8Q7L9odHAwndZbvX/e"];
    [imageString appendString:@"pUqekyi57z08pkdEqbYydZgIIK/bHDHZX7wImHj2UWtr69675sxZCgDJFN4N0JXQ"];
    [imageString appendString:@"OVA/yOkpvNiCqXz9+lBQ6t27tyouLu6k/Pz8wG0MGTLEEwS1vYoDA+XTZ//m2U7j"];
    [imageString appendString:@"yqcDt1NX/F3PdhIhRTDFs+gRZvb36wsvvPA8APRrSKbwJkIXQt+EToe+ADn5uZKG"];
    [imageString appendString:@"kmzhQVpKbCPZ7ax9xrR61arAUPnd3XcnLeJytd2AAQMCtSPThokFX99uO9IUGCYy"];
    [imageString appendString:@"CpL/r5/bdXvs4KHAbdUWnunZTmK7BJP9BQwHlrErW9mWHV7W1tZW/Xj06HtReGUK"];
    [imageString appendString:@"bwp0GcQpvC6Xw8OTeIFp+bJlgYAiU307qqs9i/ism24K1I5c/ZdY8PXtY/UfBIaJ"];
    [imageString appendString:@"gEk/L9k2bFttn3zi2568BsFkR6EiMNzph+bm5j0lt9zyCIquTOFNh66AfgDpKbxu"];
    [imageString appendString:@"uO38aElGOvAhLclz/ZS1EdOSxYsDAUXA9O6uXZ4F/LZbbw3cjgmYJGtD3xcWTPL/"];
    [imageString appendString:@"9XO9tgSTOwWR8LOjr9c+88xaFFyZwpsFTYA4hecBEnhDMCUr3gSTHQcziyr7IQ4Z"];
    [imageString appendString:@"qHnnnVdGjRx5DwrurdDPoMugwVAvqABy8ou0XqMb+EEwEUwsfnEoftwHO3Pc1NS0"];
    [imageString appendString:@"e8aMGQ+h2N4JXQ+Ngc6G+kJyFR6n8LqMnOAJwZQMTJs3bVJlK1YEUrLnh51+S9aG"];
    [imageString appendString:@"vi9sW5zKs7NAERxu9ktZWdlqFNq50EzoKuh8qBjiVXhdgKRHUPCGYNIAMLkNCxO/"];
    [imageString appendString:@"1w7bFsHkZgEk+Ozr9+rq6o0osr+FSqDJ0I+gb0OcwvOAksAJ/qQlDTav7Sl/8YMf"];
    [imageString appendString:@"KII8FhYmfm2GbYtgsq9AERru9UljY+OuaVOnlqLI3gFdC42Gvgf1gb4IcQrPA07w"];
    [imageString appendString:@"hmDyg0K6j4WFid/rhG2LYHKvCBJ89vX5Y8uXl6HAzoFuhMZB50LfgL4MOfsDrV6j"];
    [imageString appendString:@"mcT74Q/B5AeFdB8LCxO/1wnbFsFkX5EiONzqk6qqqn+huMoUnqyxNAn6ITQI+iok"];
    [imageString appendString:@"ayzxKjyP0ZIACv6kpUS4Jbt9Skzlbdm8OeX3ffyA4fdYWJiYbItgcqsIEnp29XdD"];
    [imageString appendString:@"Q8OOayZNWojiKmssTYNGQd+BZI2lHhCn8HygFEswLV2yJPAXYy+84AL1j/JytaGi"];
    [imageString appendString:@"wlOvV1WpfbW16lhzcyiIEUx2FQsWb/ZHJjKANZb2Pfzww38CfGQKbwY0FhoOyRpL"];
    [imageString appendString:@"PSFO4aWAUizB9GRZWWAwhfkF8p49eyr8TL1a89RTqqXJ+3ft9MiHYGIhzEQh5GvY"];
    [imageString appendString:@"lbNNlZX/BHxkjSWZwrsauhhyepl0AU1YwbN4TeWtX7cuEjAlQmzo0KGqautW3xEU"];
    [imageString appendString:@"wWRXwWABZ39EnYH6+vpqLpMeHkLJoBU7MMnUWyJEorotI6jKl1/2hBPBxEIYdSFk"];
    [imageString appendString:@"+/ZkDFN4dQvmz38cBVVP4XGZ9DRGShpSsQOTTLMVFhZmBE79+vVTH9XXJ4UTwWRP"];
    [imageString appendString:@"0WABZ19EnQEsk/53FFOZwpM1lmQK7yKIy6SnCSd4F6+pPPmMZ+qUKRkBk4zGFsyb"];
    [imageString appendString:@"RzBx3SCum+RwBg4eOPAGPn/WayxxmfQ0YaRHS7KNJZj+9+qrKjc3NyNwwvIRqq2l"];
    [imageString appendString:@"5QQ4hR0xpVoyPczj8tr6IgyvLZe94Cgi6lGEC+3LMulz585dhkLKZdINAEnDKZZg"];
    [imageString appendString:@"kmJ8x+23ZwRMMmp6c9u2E0BAMLHwu1CYXd/H8vLy51FEuy6TLlN4/IHWkwBVbMHU"];
    [imageString appendString:@"evSowu9UZQROf16zhmByeCrH9eLs6v7vra19rcsy6SNQULlM+kkACVk6fml5bMGk"];
    [imageString appendString:@"p7Dke03FxcWRAurRRx4hmAgmfs7kUAawTPp7s0tKFqOA6ik8LpNuAEjOgEkAJb/a"];
    [imageString appendString:@"8O8NG9TCBQvUz6+7To0bO1ZdesklnpJfhOjevXtgmM2/916CyaGi5OoIgfv9+fT0"];
    [imageString appendString:@"X/EHKHGZdIMw0lCSbexHTHrkFHb77Nq1gcE0j2DiaIFgdiYDWCZ9C5dJN/NF2kQY"];
    [imageString appendString:@"Jd4mmDCiSgatDw8dIphYbJ0ptigK3NcAHsgy6b+48UYukx7RSEnDiWAimJAFFiV6"];
    [imageString appendString:@"wAwEycCTK1euQdHUy6SPx20ukx4BpAgmS8DUuOovykuH/7hS8XtMLJxBCif/T3Q5"];
    [imageString appendString:@"wTLplSiYicukX4J/c5l0gqmoNdm0WxT3ZXoqz28fwn4nil+wja44sfC76S2WSX/n"];
    [imageString appendString:@"2mnTZJl0WWNJlkm/HOIy6RFACcdYdBc/TJ48+X5T0j/Emp+f/5FfAZfHNm3cqORi"];
    [imageString appendString:@"hCAS+Hi1F3cwiZfaV1P9xHbMZZ5eWuXlwgnjx9/TDqXrsb0SkjWWiiAukx4BnOBr"];
    [imageString appendString:@"WnASqPlJGp1tSrqA4hLuei+Q6PuXLF4c+KKFd3ftchZM4qX21VQ/sR1zmaeXVnl5"];
    [imageString appendString:@"C/pjJiS/gye/Gi6fK8mvO3CZ9BQg8IOE32PwNjIwXYPGjUgX0G7duh3UAPLaEkxn"];
    [imageString appendString:@"qCBTeeKl9tVUP7EdM3mnj9b4OAl9IZoIyUq0I6FzIVn4rxd0GnR8mXRs0yqkfJ5Z"];
    [imageString appendString:@"3/xgJ49JJ51nSrqA5uXl7fMCkr6fYAoGJvFS+2qqn9iOuczTS6u8lGm770NyoYNM"];
    [imageString appendString:@"350B9YCOL5OOLaFkiQdBwCRr3BuRLqD4xfBaDSCvLcEUDEzipfbVVD+xHTN5p49W"];
    [imageString appendString:@"+dgP/dEX+jokQJLPlAogjpQsgRH6ouPEIAiY5IzCiHQBxXaPF5D0/QRTMDCJl9pX"];
    [imageString appendString:@"U/3EdszknT5a56NM2QmM8iEZJeVBuVBHQeRtO7wIAibpOCPSBRTb3RpAXtuVTzwR"];
    [imageString appendString:@"+OKHl1580fPiB1nKIuF1fW+XLlx4QjthL/H22h+5P2xbQT5jEi/1/pnqJ7ZjJu/0"];
    [imageString appendString:@"0VofCSLLYRwETMY6URdQKaZ+BVweW/fcc74QSWhLySJ/9993n5JRVqIWlZaqwYMH"];
    [imageString appendString:@"B27n8eXLT3UwGesrFFW2RQ+YAWYgKxmwFkxbt2wJDJRESJ3M7fXr1hFMPBCzciDy"];
    [imageString appendString:@"RIAnQszA5xmwFkxHP/1U9ejRI6Nw2l9XRzARTAQTM8AMZDkD1oJJpvMmTpiQMTBd"];
    [imageString appendString:@"cP75J0Apnc+F/KYoM/AZEw+oLB9QPOv9/KyXXtCLdDOQEkyp/kOYxxOm2VJ+xiQF"];
    [imageString appendString:@"fkNFRcbAlGxZ9VMNTGH6gv/X/ydP6A/9YQbszYDv7xWF7biwYBIw4AcXI4cTFgtT"];
    [imageString appendString:@"bS0tp/yIKWx/8P/be+Cxb9g3zIB3BrIOpsaPP1YCjgSoGb197vDhqv7gwaRQ4ojJ"];
    [imageString appendString:@"Oxg8aOgNM8AMZCsDWQeTwKGlqUnJd4wKCwuNQUkurLhrzhx15PBhTygRTDzwsnXg"];
    [imageString appendString:@"8XWZPWbAOwNWgEkAITrc0KCeXr1a3TRzprp81Cg1fNgwNXDgQFVcXJxSw845R+GD"];
    [imageString appendString:@"OHXD9OmqbMUK31GSfr3jW0zxyUULQdXpue3vu+O+sG15TC92tIf2MZLcrUeTDLJ3"];
    [imageString appendString:@"kOkNvWEG4pMBq8CUWJB5+zNYE0zxOdhYONmXzECwDEQFpjqC5TOwnKwPAFMdR0zB"];
    [imageString appendString:@"wsyDnj4xA/HIgGkwHWkvoke8roI72ULt0vPFQ/jZ4SkPungcdOxH9iMz4J8B02B6"];
    [imageString appendString:@"S5/d1+zcedgliESxr/CwUfuJ7VsMs3+Y6Q/9YQbikQHTYFqjC+mDDzzwWhTF2qU2"];
    [imageString appendString:@"H1q06HXtJ7ZreNDF46BjP7IfmQH/DJgG03RdSHEl3RsuQSSKfRUPtZ/YTmeY/cNM"];
    [imageString appendString:@"f+gPMxCPDJgG0+kooPozEbV506b9URRsF9oU7xKgJJ6ezoMuHgcd+5H9yAz4Z8A0"];
    [imageString appendString:@"mFA/c/6gC2r//v238yKI8FfniWfinfax3VOjfcUDw//AoD/0hxnIXgaMFjsUUPkr"];
    [imageString appendString:@"gj6Bjv+Kw+ySEn7W1PWLuCn+LZ5p/9q9FE+N9hUPuuwddPSe3jMD/hkwWuykeLb/"];
    [imageString appendString:@"zcZW/7zQsWWPPvqWC9NvJvZRvIJ3xxL8K2n31Ghf8cDwPzDoD/1hBrKXAaPFThdQ"];
    [imageString appendString:@"bHOhtZCGk7p51qwqTut5T+uJN/AocaQk3j3T7iU2HDGxUGSvUNB7ep/JDEQFJqmj"];
    [imageString appendString:@"BVCF1FOtvn37Vv+3svJ9EyOLOLUBT/aLN9qn9q14lw91/GUyGHwtFiJmgBnIVgai"];
    [imageString appendString:@"BJMUVCmsq6EOOMntoqKiN+U7OntqahrjBJgw+yL7Lh6IF139afesE5Rwn9G+ylbg"];
    [imageString appendString:@"+LosdswAM5AqA0aLnRRPjz/5ftMHUCdAtf+7ITc3dwf0uiPagf1u8PBCPBKvkv6l"];
    [imageString appendString:@"6kw+zgOeGWAG4pCBTIFJCm0v6AHoQygZoFy+T4Ak3ohHnn9xCBz3gYWTGWAGUmUg"];
    [imageString appendString:@"k2DSBVc+exoPLYdegbxGUnEGleyz7Lt4cBUknqT8S9WZfJwHPDPADMQhA0bBFAdD"];
    [imageString appendString:@"uA88sJkBZoAZyG4GCCaV3Q7gAUD/mQFmgBnonAGCiWBiBpgBZoAZsCoDVr0ZnjV0"];
    [imageString appendString:@"PmugH/SDGWAGXMwAwcQzJWaAGWAGmAGrMmDVm3HxzID7zDNiZoAZYAY6Z4Bg4pkS"];
    [imageString appendString:@"M8AMMAPMgFUZsOrN8Kyh81kD/aAfzAAz4GIGCCaeKTEDzAAzwAxYlQGr3oyLZwbc"];
    [imageString appendString:@"Z54RMwPMADPQOQMEE8+UmAFmgBlgBqzKwP8BSZK5M9OL+AwAAAAASUVORK5CYII="];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imageData];
}

////////////////////////////////////////////////////////////////////////////////
// Aux network functions
////////////////////////////////////////////////////////////////////////////////

+ (void) sendGETtoEndpoint:(NSString*)endpoint
             withQueryDict:(NSDictionary*)GETDict
                andSuccess:(success)success
                 orFailure:(failure)failure {
    
    // prepare the URL
    __block NSMutableString *_surl = [endpoint mutableCopy];
    
    [_surl appendString:(GETDict.allKeys.count > 0 ? @"?" : @"")];
    [_surl appendString:[self formGetQueryFromDict:GETDict]];
    
    NSURL *url = [NSURL URLWithString:_surl];
    
    // create the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setValue:[self getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    // form the response block to the POST
    netresponse resp = ^(NSData * data, NSURLResponse * response, NSError * error) {
        
        NSInteger status = ((NSHTTPURLResponse*)response).statusCode;
        
        if (error || status != 200) {
            // logging
            NSLog(@"Network error for %@ - %@", _surl, error);
            
            // send message
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure();
                }
            });
        }
        else {
            
            // logging
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (str.length >= 10){  str = [[str substringToIndex:9] stringByAppendingString:@" ... /truncated"]; }
            NSLog(@"Success: %@ ==> %@", _surl, str);
            
            // send message
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success){
                    success(data);
                }
            });
        }
    };
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:resp];
    [task resume];
}


@end
