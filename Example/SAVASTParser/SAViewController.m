//
//  SAViewController.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

#import "SAViewController.h"
#import "SAVideoPlayer.h"
#import "SAVASTParser.h"
#import "SAVASTAd.h"
#import "SAVASTCreative.h"
#import "SAUtils.h"

@interface SAViewController ()
@property (nonatomic, strong) SAVideoPlayer *player;
@property (nonatomic, strong) SAVASTParser *parser;
@property (nonatomic, strong) SAVASTAd *vastAd;
@property (nonatomic, strong) SAVASTCreative *vastCreative;
@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof (self) weakSelf = self;
    
    _player = [[SAVideoPlayer alloc] initWithFrame:CGRectMake(0, 40, 220, 160)];
    [_player setClickHandler:^{
        NSURL *url = [NSURL URLWithString:weakSelf.vastCreative.ClickThrough];
        [[UIApplication sharedApplication] openURL:url];
    }];
    [_player setEventHandler:^(SAVideoPlayerEvent event) {
        switch (event) {
            case Video_Start: {
                NSLog(@"Video start");
                break;
            }
            case Video_1_4: {
                NSLog(@"Video 1/4");
                break;
            }
            case Video_1_2: {
                NSLog(@"Video 1/2");
                break;
            }
            case Video_3_4: {
                NSLog(@"Video 3/4");
                break;
            }
            case Video_End: {
                NSLog(@"Video end");
                break;
            }
            case Video_Error: {
                NSLog(@"Video error");
                break;
            }
        }
    }];
    [self.view addSubview:_player];
    
    _parser = [[SAVASTParser alloc] init];
    [_parser parseVASTURL:@"https://ads.superawesome.tv/v2/video/vast/28000/-1/-1/?sdkVersion=unknown&rnd=457960880" done:^(SAVASTAd *ad) {
        
        weakSelf.vastAd = ad;
        weakSelf.vastCreative = weakSelf.vastAd.creative;
        
        // play
        NSString *finalFile = [SAUtils filePathInDocuments:ad.creative.playableDiskURL];
        [weakSelf.player playWithMediaFile:finalFile];
        
    }];
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
}

@end
