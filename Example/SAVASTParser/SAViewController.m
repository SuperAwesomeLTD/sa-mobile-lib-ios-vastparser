//
//  SAViewController.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

#import "SAViewController.h"
#import "SAVideoPlayer.h"
#import "SAVASTManager.h"
#import "SAVASTParser.h"
#import "SAVASTAd.h"
#import "SAVASTCreative.h"

@interface SAViewController () <SAVASTManagerProtocol>
@property (nonatomic, strong) SAVideoPlayer *player;
@property (nonatomic, strong) SAVideoPlayer *player2;
@property (nonatomic, strong) SAVASTManager *manager;
@property (nonatomic, strong) SAVASTManager *manager2;
@property (nonatomic, strong) SAVASTParser *parser;
@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _player = [[SAVideoPlayer alloc] initWithFrame:CGRectMake(0, 40, 220, 160)];
    [self.view addSubview:_player];
    
    _parser = [[SAVASTParser alloc] init];
    [_parser parseVASTURL:@"https://ads.superawesome.tv/v2/video/vast/28000/-1/-1/?sdkVersion=unknown&rnd=457960880" done:^(SAVASTAd *ad) {
        
        SAVASTCreative *creative = ad.creative;
        
    }];
    
    _manager = [[SAVASTManager alloc] initWithPlayer:_player];
    _manager.delegate = self;
//    [_manager parseVASTURL:@"https://ads.superawesome.tv/v2/video/vast/28000/-1/-1/?sdkVersion=unknown&rnd=457960880"];
    
//    _player2 = [[SAVideoPlayer alloc] initWithFrame:CGRectMake(0, 200, 320, 220)];
//    [self.view addSubview:_player2];
//    
//    _manager2 = [[SAVASTManager alloc] initWithPlayer:_player2];
//    _manager2.delegate = self;
//    [_manager2 parseVASTURL:@"https://ads.superawesome.tv/v2/video/vast/28000/31825/32136/?sdkVersion=ios_4.0.2&rnd=687506518&dauid=2097324019"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)resizeAction:(id)sender {
    [_player updateToFrame:CGRectMake(0, 40, 320, 180)];
}

- (IBAction)deleteAction:(id)sender {
    [_player destroy];
    _manager = NULL;
}

- (void) didNotFindAds {
    NSLog(@"didNotFindAds");
}

- (void) didStartAd {
    NSLog(@"didStartAd");
}

- (void) didStartCreative {
    NSLog(@"didStartCreative");
}

- (void) didReachFirstQuartileOfCreative {
    NSLog(@"didReachFirstQuartileOfCreative");
}

- (void) didReachMidpointOfCreative {
    NSLog(@"didReachMidpointOfCreative");
}

- (void) didReachThirdQuartileOfCreative {
    NSLog(@"didReachThirdQuartileOfCreative");
}

- (void) didEndOfCreative {
    NSLog(@"didEndOfCreative");
}

- (void) didHaveErrorForCreative {
    NSLog(@"didHaveErrorForCreative");
}

- (void) didEndAd {
    NSLog(@"didEndAd");
}

- (void) didEndAllAds {
    NSLog(@"didEndAllAds");
}

- (void) didGoToURL:(NSURL*)url withTrackingArray:(NSArray *)clickTarcking {
    NSLog(@">>>>>\ndidGoToURL %@\n& send to %@", url, clickTarcking);
}

@end
