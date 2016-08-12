//
//  SAFileDownloader.m
//  Pods
//
//  Created by Gabriel Coman on 18/04/2016.
//
//

#import "SAFileDownloader.h"

// callback for iOS's own [NSURLConnection sendAsynchronousRequest:]
typedef void (^locationResponse)(NSURL * location, NSURLResponse * response, NSError * error);

// defines
#define SA_FILE_STORE @"SA_FILE_STORE"
#define PAIR_KEY @"Key"
#define PAIR_PATH @"FPath"

//
// private vars for SAFileDownloader
@interface SAFileDownloader ()
// dictionary that holds all the files currently saved on disk as part of the SDK
@property (nonatomic, strong) NSMutableDictionary *fileStore;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSUserDefaults *defs;
@end

//
// actual implementation of SAFileDownloader
@implementation SAFileDownloader

#pragma mark Singleton & Constructor functions

- (id) init {
    if (self = [super init]) {
        // get user defaults and file manager
        _defs = [NSUserDefaults standardUserDefaults];
        _fileManager = [NSFileManager defaultManager];
        
        // get the file store
        if ([_defs objectForKey:SA_FILE_STORE]) {
            _fileStore = [[_defs objectForKey:SA_FILE_STORE] mutableCopy];
        } else {
            _fileStore = [[NSMutableDictionary alloc] init];
        }
        
        // do a preliminary cleanup
        [self cleanup];
    }
    
    return self;
}

#pragma mark Main Public functions

+ (NSString*) getDiskLocation {
    return [NSString stringWithFormat:@"samov_%d.mp4", arc4random_uniform((uint32_t)(65536))];
}

- (void) downloadFileFrom:(NSString*)url to:(NSString*)fpath withResponse:(downloadResponse)response {
    
    // form the URL & request
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:URL];
    [request setHTTPMethod:@"GET"];
    
    locationResponse resp2 = ^(NSURL * location, NSURLResponse * httpresponse, NSError * error) {
        NSInteger statusCode = ((NSHTTPURLResponse*)httpresponse).statusCode;
        
        // check for whatever error
        if (error != NULL || statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[false] | FILE GET | 0 | %@ ==> %@", url, fpath);
                if (response) {
                    response(false);
                }
            });
        }
        // goto success
        else {
            NSString *fullFilePath = [self filePathInDocuments:fpath];
            NSString *key = [self getKeyFromLocation:fpath];
            NSError *fileError = NULL;
            NSURL *destURL = [NSURL fileURLWithPath:fullFilePath];
            [_fileManager moveItemAtURL:location toURL:destURL error:&fileError];
            
            if (fileError == NULL || key == NULL) {
                // save
                [_fileStore setObject:fpath forKey:key];
                [_defs setObject:_fileStore forKey:SA_FILE_STORE];
                [_defs synchronize];
                
                // call success
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"[true] | FILE GET | 200 | %@ ==> %@", url, fpath);
                    if (response) {
                        response(true);
                    }
                });
                
            }
            // failure to write file
            else {
                // call success
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"[false] | FILE GET | 0 | %@ ==> %@", url, fpath);
                    if (response) {
                        response(false);
                    }
                });
            }
        }
    };
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:resp2];
    [task resume];
}

#pragma mark Private Functions

- (NSString*) getKeyFromLocation:(NSString*)location {
    if (!location) return NULL;
    NSArray *c1 = [location componentsSeparatedByString:@"_"];
    if ([c1 count] < 2) return NULL;
    NSString *key1 = [c1 objectAtIndex:1];
    NSArray *c2 = [key1 componentsSeparatedByString:@"."];
    if ([c2 count] < 1) return NULL;
    return [c2 firstObject];
}

- (void) cleanup {
    
    for (NSString *key in _fileStore.allKeys) {
        NSString *filePath = [_fileStore objectForKey:key];
        NSString *fullFilePath = [self filePathInDocuments:filePath];
        if ([_fileManager fileExistsAtPath:fullFilePath] && [_fileManager isDeletableFileAtPath:fullFilePath]) {
            [_fileManager removeItemAtPath:fullFilePath error:nil];
            NSLog(@"[true] | DEL | %@", filePath);
        } else {
            NSLog(@"[false] | DEL | %@", filePath);
        }
    }
    
    // remove
    [_fileStore removeAllObjects];
    [_defs removeObjectForKey:SA_FILE_STORE];
    [_defs synchronize];
}

// MARK: Private

- (NSString *) getDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

- (NSString*) filePathInDocuments:(NSString*)fpath {
    return [[self getDocumentsDirectory] stringByAppendingPathComponent:fpath];
}

@end
