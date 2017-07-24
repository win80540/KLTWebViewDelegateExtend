//
//  DetailViewController.m
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//



#import "DetailViewController.h"
#import "MasterViewController.h"
#import "UIWebView+KLTDelegateExtend.h"

@interface DetailViewController () <KLTUIWebViewExtendDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)doBack:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(doNextPage:)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.detailItem cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
}

- (void)doNextPage:(id)sender {
    id vc = [[MasterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebView Original Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
#if LogWebViewLife
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    if (isTopLevelNavigation) {
        NSLog(@".log webView should start top Level load:%@", request.URL.absoluteString);
    } else {
        NSLog(@".log webView should start child Level load:%@ \n top level:%@", request.URL.absoluteString, request.mainDocumentURL);
    }
#endif
    return YES;
}
/*
- (void)webViewDidStartLoad:(UIWebView *)webView {
#if LogWebViewLife
    NSLog(@".log webView start load");
#endif
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
#if LogWebViewLife
    NSLog(@".log webView finish load:%@", webView.request.URL.absoluteString);
#endif
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
#if LogWebViewLife
    NSLog(@".log webView fail load:%@ \n%@", error.userInfo[NSURLErrorFailingURLStringErrorKey], [error description]);
#endif
}

#pragma mark - UIWebView Extend Delegate Methods

- (void)webView:(UIWebView *)webView didCreatedJSContext:(JSContext *)context isMainFrame:(BOOL)isMainFrame {
#if LogWebViewExtendLife
    if (isMainFrame) {
        NSLog(@".log webView top level jscontext created:%p", context);
    } else {
        NSLog(@".log webView child level jscontext created:%p", context);
    }
#endif
}

- (void)webView:(UIWebView *)webView domContentLoadedOnMainFrame:(BOOL)isMainFrame {
#if LogWebViewExtendLife
    if (isMainFrame) {
        NSLog(@".log webView top level DOMContentLoaded");
    } else {
        NSLog(@".log webView child level DOMContentLoaded");
    }
#endif
}
*/
#pragma mark - Lazy Load

- (UIWebView *)webView {
    if (_webView) {
        return _webView;
    }
    
    _webView = [[UIWebView alloc] init];
    /* // 这里是开启PageCache的私有API，该方法能开到3
    if (YES) {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey: @"WebKitCacheModelPreferenceKey"];
        // [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"WebKitMediaPlaybackAllowsInline"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        id webView = [_webView valueForKeyPath:@"_internal.browserView._webView"];
        id preferences = [webView valueForKey:@"preferences"];
        [preferences performSelector:@selector(_postCacheModelChangedNotification)];
    }
     */
    _webView.frame = self.view.bounds;
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    return _webView;
}

@end
