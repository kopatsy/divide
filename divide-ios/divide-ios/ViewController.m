//
//  ViewController.m
//  divide-ios
//
//  Created by Arthur Kopatsy on 5/21/16.
//  Copyright © 2016 Arthur Kopatsy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gen" ofType:@"html" inDirectory:@"www"]];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
//    NSString *urlString = @"https://www.google.com/";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [_webView loadRequest:urlRequest];
}

- (void)viewDidLayoutSubviews {
    _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
