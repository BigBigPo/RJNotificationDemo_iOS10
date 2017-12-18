//
//  EmojiVC.h
//  NotificationContent
//
//  Created by Po on 2017/12/15.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiVC : UIViewController

- (void)setPressBlock:(void(^)(NSString * text))block;

@end
