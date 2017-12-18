//
//  NotificationService.m
//  NotificationService
//
//  Created by Po on 2017/12/12.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) NSURLSession * session;
@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // 修改信息
    NSString * type = @"【特别关心】 ";
    self.bestAttemptContent.title = [type stringByAppendingString:self.bestAttemptContent.title];
    
    // 下载并关联附件
    NSString * urlString = self.bestAttemptContent.userInfo[@"image-url"];
    [self loadAttachmentForUrlString:urlString
                   completionHandler: ^(UNNotificationAttachment *attachment) {
                       self.bestAttemptContent.attachments = [NSArray arrayWithObjects:attachment, nil];
                       [self contentComplete];
                   }];
}

- (void)serviceExtensionTimeWillExpire {
    //这里进行操作超时后的补救···例如将图片替换成默认图片等等
    self.bestAttemptContent.title = @"超时";
    [self contentComplete];
}

- (void)contentComplete
{
    [self.session invalidateAndCancel];
    self.contentHandler(self.bestAttemptContent);
}

- (void)loadAttachmentForUrlString:(NSString *)urlString
                 completionHandler:(void (^)(UNNotificationAttachment *))completionHandler {
    __block UNNotificationAttachment *attachment = nil;
    __block NSURL *attachmentURL = [NSURL URLWithString:urlString];
    NSString *fileExt = [@"." stringByAppendingString:[urlString pathExtension]];
    
    //下载附件
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *task;
    task = [_session downloadTaskWithURL:attachmentURL
                       completionHandler: ^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                          
                           if (error != nil) {
                               NSLog(@"%@", error.localizedDescription);
                           } else {
                               NSFileManager *fileManager = [NSFileManager defaultManager];
                               NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path
                                                     stringByAppendingString:fileExt]];
                               [fileManager moveItemAtURL:temporaryFileLocation
                                                    toURL:localURL
                                                   error:&error];
                               NSError *attachmentError = nil;
                               NSString * uuidString = [[NSUUID UUID] UUIDString];
                               //将附件信息进行打包
                               attachment = [UNNotificationAttachment attachmentWithIdentifier:uuidString
                                                                                           URL:localURL
                                                                                       options:nil
                                                                                         error:&attachmentError];
                               if (attachmentError) {
                                   NSLog(@"%@", attachmentError.localizedDescription);
                               }
                           }
                           
                           completionHandler(attachment);
                       }];
    [task resume];
}

@end
