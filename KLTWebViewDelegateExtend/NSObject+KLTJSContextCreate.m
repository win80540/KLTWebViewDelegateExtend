//
//  NSObject+JSContextCreate.m
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#import "NSObject+KLTJSContextCreate.h"

@class JSContext;

NSString * const kKLTWebViewLoadNofitcationJSContextCreated = @"kKLTWebViewLoadNofitcationJSContextCreated";

@interface NSObject (KLTJSContextCreate)

@end

@implementation NSObject (KLTJSContextCreate)

/// 该代理方法是 Apple 未公开的，其中 WebView 类和 WebFrame 类都是私有类型，不使用具体类型，以免导出私有符号，JSContext 已公开，可以放心使用
- (void)webView:(id)webView didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)webFrame
{
    // webView 真实类型是 WebView 类实例，并不是 UIWebView
    // webFrame 真实类型是 WebFrame 类实例，WebView 类和 WebFrame 类都是私有类型，不要使用
    [[NSNotificationCenter defaultCenter] postNotificationName:kKLTWebViewLoadNofitcationJSContextCreated object:nil userInfo:@{@"context":ctx}];
}

@end
