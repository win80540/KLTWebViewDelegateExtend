//
//  UIWebView+Extend.h
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSContext;

@protocol KLTUIWebViewExtendDelegate <UIWebViewDelegate>

@optional
/**
 * 当 webView Frame 创建 JSContext 时的代理回调，因为在该时机点web页面上的脚本都还没运行，所以非常适合注入优先级最高的脚本，如环境变量
 *
 * @param webView UIWebView * 创建 JSContext 的 UIWebView 实例
 * @param context JSContext * 创建的 JSContext 实例
 * @param isMainFrame BOOL 是否是 mainFrame 的 JSContext
 *
 */
- (void)webView:(UIWebView *)webView didCreatedJSContext:(JSContext *)context isMainFrame:(BOOL)isMainFrame;

/**
 * 当 webView Frame 的 DOMContentLoaded 的代理回调，该时机不同于 load，不等待子 frame，图片，CSS，脚本等，只要标签解析完就会触发
 *
 * @param webView UIWebView * 创建 JSContext 的 UIWebView 实例
 * @param isMainFrame BOOL 是否是 mainFrame 的 JSContext
 *
 */
- (void)webView:(UIWebView *)webView domContentLoadedOnMainFrame:(BOOL)isMainFrame;

@end
