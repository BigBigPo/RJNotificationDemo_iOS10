//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by Po on 2017/12/11.
//  Copyright © 2017年 Po. All rights reserved.
//
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

//#import "EmojiVC.h"
#import "CommentCell.h"
@interface NotificationViewController () <UNNotificationContentExtension, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * commentDataArray;

//@property (strong, nonatomic) EmojiVC * emojiVC;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _commentDataArray = [@[] copy];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
//    _emojiVC = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"EmojiVC"];
//
//    __weak typeof(self) wself = self;
//    [_emojiVC setPressBlock:^(NSString *text) {
//        [wself postComment:text];
//        [wself.emojiVC resignFirstResponder];
//    }];
}

- (void)pressEmojiButton:(UIButton *)sender {
    [_detailLabel setText:@"press emoji"];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSString * lastComment = notification.request.content.userInfo[@"last-comments"];
    if (lastComment && ![lastComment isEqualToString:@""]) {
        _commentDataArray = [_commentDataArray arrayByAddingObject:lastComment];
    }
    [_tableView reloadData];
    //附件的提取
    UNNotificationAttachment * attachment = notification.request.content.attachments[0];
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        NSData *imageData = [NSData dataWithContentsOfURL:attachment.URL];
        [self.imageView setImage:[UIImage imageWithData:imageData]];
        [attachment.URL stopAccessingSecurityScopedResource];
    }
    
    if ([notification.request.content.body isEqualToString:@""]) {
        [_detailView setHidden:YES];
    } else {
        self.detailLabel.text = notification.request.content.body;
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion {
    if ([response.actionIdentifier isEqualToString:@"action_like"]) {
        [self.likeLabel setHidden:!self.likeLabel.hidden];
    } else if([response.actionIdentifier isEqualToString:@"action_emoji"]) {
//        [self.emojiVC becomeFirstResponder];
    } else if([response.actionIdentifier isEqualToString:@"action_input"]) {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse *)response;
        [self postComment:textResponse.userText];
    } else {
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }
    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
}

//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}

//- (UIView *)inputView {
//    return _emojiVC.view;
//}

- (void)postComment:(NSString *)text {
    NSString * trueText = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(![text isEqualToString:@""] && ![trueText isEqualToString:@""]) {
        _commentDataArray = [_commentDataArray arrayByAddingObject:[NSString stringWithFormat:@"我:%@", text]];
        [_tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_commentDataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
        
    }
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _commentDataArray.count == 0 ? 1 : _commentDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCellID" forIndexPath:indexPath];
    if (_commentDataArray.count == 0) {
        [cell.commentLabel setText:@"说点什么吧"];
    } else {
        [cell.commentLabel setText:_commentDataArray[indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
@end
