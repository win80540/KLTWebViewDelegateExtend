//
//  UIWebView+Extend.m
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#import "UIWebView+KLTDelegateExtend.h"
#import <objc/message.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSObject+KLTJSContextCreate.h"
#import "KLTDestoryTrigger.h"

static BOOL isMainFrame(UIWebView *webView, JSContext *ctx);
static BOOL isChildFrame(UIWebView *webView, JSContext *ctx);
static void *kMainFrameJSContext = &kMainFrameJSContext;

@interface UIWebView (KLTDelegateExtend)

@end

@implementation UIWebView (KLTDelegateExtend)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 替换 allocWithZone: 以达到所有实例都注册监听
        Class class = objc_getMetaClass(class_getName([self class]));
        {
            SEL originalSelector = @selector(allocWithZone:);
            SEL swizzledSelector = @selector(klt_allocWithZone:);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            
            BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            if (success) {
                class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

+ (instancetype)klt_allocWithZone:(struct _NSZone *)zone {
    id ret = [self klt_allocWithZone:zone];
    if (ret) {
        // 注册监听
        [ret klt_addObserverForJSContext];
    }
    return ret;
}

- (void)klt_addObserverForJSContext {
    __weak typeof(self) weakSelf = self;
    // 监听 JSContext Create 事件
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kKLTWebViewLoadNofitcationJSContextCreated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        JSContext *ctx = note.userInfo[@"context"];
        BOOL mainFrame = isMainFrame(strongSelf, ctx);
        
        if (mainFrame) {
            [strongSelf setMainFrameJSContext:ctx];
        }
        
        if (mainFrame || isChildFrame(strongSelf, ctx)) { // 为主 frame 或子 frame ，则表示是当前 webview 触发的事件
            // 对外导出 DOMContextLoaded 时需要调用的 Native 方法
            __weak typeof(ctx) weakCtx = ctx;
            ctx[@"_klt_hybrid_DOMContentLoaded"] = ^() {
                [weakSelf stringByEvaluatingJavaScriptFromString:@"delete window._klt_hybrid_DOMContentLoaded"];
                [weakSelf klt_webView:weakSelf onDOMContentLoadedWithJSContext:weakCtx isMainFrame:mainFrame];
            };
            // 监听 DOMContentLoaded 事件
            [ctx evaluateScript:
             @"(function(){"
             "  document.addEventListener('DOMContentLoaded',_klt_hybrid_DOMContentLoaded);"
             "})();"];
            
            // 将 create JSContext 转发 delegate
            [strongSelf klt_webView:strongSelf didCreatedJSContext:ctx isMainFrame:mainFrame];
        }
    }];
    __weak typeof(observer) weakObserver = observer;
    [KLTDestoryTrigger triggerBy:self identity:nil action:^(KLTDestoryTriggerInfo *info) {
        [[NSNotificationCenter defaultCenter] removeObserver:weakObserver];
    }];
}

- (void)klt_webView:(UIWebView *)webView didCreatedJSContext:(JSContext *)context isMainFrame:(BOOL)isMainFrame {
    id<KLTUIWebViewExtendDelegate> delegate = (id<KLTUIWebViewExtendDelegate>)[self delegate];
    if ([delegate respondsToSelector:@selector(webView:didCreatedJSContext:isMainFrame:)]) {
        [delegate webView:self didCreatedJSContext:context isMainFrame:isMainFrame];
    }
}

- (void)klt_webView:(UIWebView *)webView onDOMContentLoadedWithJSContext:(JSContext *)currentCtx isMainFrame:(BOOL)isMainFrame {
    id<KLTUIWebViewExtendDelegate> delegate = (id<KLTUIWebViewExtendDelegate>)[self delegate];
    if ([delegate respondsToSelector:@selector(webView:onDOMContentLoadedWithJSContext:isMainFrame:)]) {
        [delegate webView:self onDOMContentLoadedWithJSContext:currentCtx isMainFrame:isMainFrame];
    }
}

- (void)setMainFrameJSContext:(JSContext *)ctx {
    objc_setAssociatedObject(self, kMainFrameJSContext, ctx, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JSContext *)mainFrameJSContext {
    return objc_getAssociatedObject(self, kMainFrameJSContext);
}

@end

/// 判断是否是主Frame
static BOOL isMainFrame(UIWebView *webView, JSContext *ctx) {
    // 设置标记，用于判断是否是同一个环境
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [ctx evaluateScript:[NSString stringWithFormat:@"window._klt_tag_uuid = '%@';", uuid]];
    NSString *webViewID = [webView stringByEvaluatingJavaScriptFromString:@"window._klt_tag_uuid"];
    
    // 是否是当前 WebView 的 Ctx
    if ([uuid isEqualToString:webViewID]) {
        // 清除标记
        [ctx evaluateScript:@"delete window._klt_tag_uuid"];
        return YES;
    }
    
    // 清除标记
    [ctx evaluateScript:@"delete window._klt_tag_uuid"];
    [webView stringByEvaluatingJavaScriptFromString:@"delete window._klt_tag_uuid"];
    
    return NO;
}

/// 判断是否是子Frame
static BOOL isChildFrame(UIWebView *webView, JSContext *ctx) {
    JSValue *value = [ctx evaluateScript:@"parent == window"]; // parent == window，则当前 context 的本事就是 main frame 的 context
    // value 为 true ，则为Main Frame，肯定不是Child Frame了
    if ([value isBoolean] && ![value toBool]) {
        JSContext *mainCtx = [webView mainFrameJSContext];
        // 是否是当前 WebView 的 Ctx，依据主 frame 的 window 对象地址与该 ctx 的顶层 window 对象地址一致
        if ([[mainCtx globalObject] JSValueRef] == [ctx[@"top"] JSValueRef]) {
            return YES;
        }
        return NO;
    }
    return NO;
}
