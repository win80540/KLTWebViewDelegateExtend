//
//  KLTDestoryTrigger.m
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#import "KLTDestoryTrigger.h"
#import <objc/message.h>

static void *kDestoryTriggerAssocciate = &kDestoryTriggerAssocciate;

@interface KLTDestoryTrigger ()
@property (nonatomic, strong) NSMutableArray<KLTDestoryTriggerInfo *> *triggerInfos;
@end

@implementation KLTDestoryTrigger

- (instancetype)init {
    self = [super init];
    if (self) {
        _triggerInfos = [NSMutableArray new];
    }
    return self;
}

+ (void)triggerBy:(id)triggerBy identity:(NSString *)identity action:(void(^)(KLTDestoryTriggerInfo *))action {
    KLTDestoryTriggerInfo *triggerInfo = [KLTDestoryTriggerInfo new];
    triggerInfo.triggerBy = triggerBy;
    triggerInfo.identity = identity;
    triggerInfo.action = action;
    
    KLTDestoryTrigger *trigger = objc_getAssociatedObject(triggerBy, kDestoryTriggerAssocciate);
    if (!trigger) {
        trigger = [KLTDestoryTrigger new];
        objc_setAssociatedObject(triggerBy, kDestoryTriggerAssocciate, trigger, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [trigger.triggerInfos addObject:triggerInfo];
}

- (void)dealloc {
    [_triggerInfos enumerateObjectsUsingBlock:^(KLTDestoryTriggerInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.action) {
            obj.action(obj);
        }
    }];
}

@end

@implementation KLTDestoryTriggerInfo

@end
