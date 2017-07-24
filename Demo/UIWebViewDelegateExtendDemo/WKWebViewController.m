//
//  WKWebViewController.m
//  UIWebViewDelegateExtendDemo
//
//  Created by 田凯 on 21/07/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WKWebView.h>

@interface WKWebViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(doBack:)];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.detailItem]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doBack:(id)sender {
    if ([self.webView canGoBack]) {
        // [self.webView goBack];
        [self.webView evaluateJavaScript:@"history.go(-1);" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
