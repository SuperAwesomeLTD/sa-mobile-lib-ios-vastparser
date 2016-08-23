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
#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"
#import "SAMedia.h"
#import "SATracking.h"
#import "SAUtils.h"

@interface SAViewController ()
@property (nonatomic, strong) SAVideoPlayer *player;
@property (nonatomic, strong) SAVASTParser *parser;
@property (nonatomic, strong) SAAd *vastAd;
@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof (self) weakSelf = self;
    
    _player = [[SAVideoPlayer alloc] initWithFrame:CGRectMake(0, 40, 220, 160)];
    [_player setClickHandler:^{
        NSURL *url = [NSURL URLWithString:weakSelf.vastAd.creative.clickUrl];
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
    
    NSString *vastURL1 = @"https://ads.staging.superawesome.tv/v2/video/vast/116/142/118/?sdkVersion=unknown&rnd=381446114";
    NSString *vastURL2 = @"https://ads.superawesome.tv/v2/video/vast/28000/-1/-1/?sdkVersion=unknown&rnd=457960880";
    NSString *vastURL3 = @"https://ads.staging.superawesome.tv/v2/video/vast/249/476/560/?sdkVersion=unknown&rnd=12383867";
    NSString *vastURL4 = @"https://rtr.innovid.com/r1.57b3521dc8b1b6.86536393;cb=1471946037344";
    NSString *vastURL5 = @"https://skskkss.com";
    NSString *vastURL6 = nil;
    NSString *vastURL7 = @"http://sa-test-moat.herokuapp.com/xmloutput/xml1";
    NSString *vastURL8 = @"http://sa-test-moat.herokuapp.com/xmloutput/xml2";
    NSString *vastURL9 = @"http://sa-test-moat.herokuapp.com/xmloutput/xml3";
    NSString *vastURL10 = @"http://sa-test-moat.herokuapp.com/xmloutput/xml4";
    NSString *vastURL11 = @"http://sa-test-moat.herokuapp.com/xmloutput/xml5";
    
    _parser = [[SAVASTParser alloc] init];
    [_parser parseVASTURL:vastURL7 done:^(SAAd *ad) {
        
        weakSelf.vastAd = ad;
        
        NSLog(@"VAST AD %@ %@", ad, [ad jsonPreetyStringRepresentation]);
        
        // play
        NSString *finalFile = [SAUtils filePathInDocuments:ad.creative.details.media.playableDiskUrl];
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
