//
//  KLTDestoryTrigger.h
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLTDestoryTriggerInfo : NSObject

@property (nonatomic, weak) id triggerBy;
@property (nonatomic, copy) NSString *identity;
@property (nonatomic, copy) void(^action)(KLTDestoryTriggerInfo *);

@end

@interface KLTDestoryTrigger : NSObject

+ (void)triggerBy:(id)triggerBy identity:(NSString *)identity action:(void(^)(KLTDestoryTriggerInfo *))action;

@end
