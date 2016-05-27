//
//  ViewController.m
//  divide-ios
//
//  Created by Arthur Kopatsy on 5/21/16.
//  Copyright © 2016 Arthur Kopatsy. All rights reserved.
//

#import "ViewController.h"
#import "LocationService.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) NSArray *pois;
@property (nonatomic, retain) LocationService *locationService;
@end

@interface LocationHandler: NSObject<LocationDelegate>
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize location service.
    _locationService = [[LocationService alloc] init];
    [_locationService startLocationServices:self];
}

- (void)handleLocation:(CLLocation *)location {
    // Refresh web view.
    NSLog(@"LOCATION UPDATE");
    //    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gen" ofType:@"html" inDirectory:@"www"]];
    
    //    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewDidLayoutSubviews {
    _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
