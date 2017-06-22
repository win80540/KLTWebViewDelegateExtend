//
//  DetailViewController.h
//  UIWebviewDelegateExtend
//
//  Created by 田凯 on 21/06/2017.
//  Copyright © 2017 netease. All rights reserved.
//

#ifndef DetailViewController_h
#define DetailViewController_h

#define LogWebViewLife 1 // 当该宏开启时，打印webview生命周期
#define LogWebViewExtendLife 1 // 当该宏开启时，打印webview扩展生命周期
#endif

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSURL *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

