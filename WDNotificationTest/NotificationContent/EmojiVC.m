//
//  EmojiVC.m
//  NotificationContent
//
//  Created by Po on 2017/12/15.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "EmojiVC.h"

typedef void(^PressBlock)(NSString * text);

@interface EmojiVC ()
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;

@property (copy, nonatomic) PressBlock pressBlock;
@end

@implementation EmojiVC

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (IBAction)pressButton:(UIButton *)sender {
    if (_pressBlock) {
        _pressBlock(sender.titleLabel.text);
    }
}


- (void)setPressBlock:(void(^)(NSString * text))block {
    _pressBlock = block;
}

@end
