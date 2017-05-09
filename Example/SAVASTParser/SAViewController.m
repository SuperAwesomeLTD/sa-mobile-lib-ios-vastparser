//
//  SAViewController.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

#import "SAViewController.h"
#import "SAVASTParser.h"
#import "SAJsonParser.h"
#import "SAVASTAd.h"

@interface SAViewController ()
@end

@implementation SAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *vast = @"https://ads.superawesome.tv/v2/video/vast/31571/-2/-2/?sdkVersion=unity_5.3.5&rnd=895407827&dauid=799181369&bundle=com.woozworld.woozworld&device=tablet&country=US";
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        NSLog(@"%@", [ad jsonPreetyStringRepresentation]);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
