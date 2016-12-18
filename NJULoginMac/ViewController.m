//
//  ViewController.m
//  NJULoginMac
//
//  Created by 宋 奎熹 on 2016/12/18.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "LoginManager.h"

#define LOGIN_URL @"http://p.nju.edu.cn/portal_io/login"
#define LOGOUT_URL @"http://p.nju.edu.cn/portal_io/logout"
#define CHECK_STATUS_URL @"http://p.nju.edu.cn/portal_io/getinfo"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkStatus];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)checkStatus{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         @"application/json",
                                                         nil];
    [manager POST:CHECK_STATUS_URL
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
              NSLog(@"%d", [resultDict[@"reply_code"] intValue]);
              
              switch ([resultDict[@"reply_code"] intValue]) {
                  case 2:
                      [self.actionButton setTitle:@"Login"];
                      break;
                  case 0:
                      [self.actionButton setTitle:@"Logout"];
                      break;
                  default:
                      break;
              }
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];
}

- (void)login{
    NSDictionary *tmpDict = @{
                              @"username" : [NSString stringWithString:self.usernameText.stringValue],
                              @"password" : [NSString stringWithString:self.passwordText.stringValue],
                              };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         @"application/json",
                                                         nil];
    [manager POST:LOGIN_URL
       parameters:tmpDict
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
              int i = [resultDict[@"reply_code"] intValue];
              if(i == 1 || i == 6){
                  [self.actionButton setTitle:@"Logout"];
              }
              
              NSDate *date = [NSDate date];
              NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
              [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
              NSString *dateString = [dateFormatter stringFromDate:date];
              
              [self.logView setString:[self.logView.string stringByAppendingString:[NSString stringWithFormat:@"%@  %@\n", dateString, resultDict[@"reply_msg"]]]];
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];
}

- (void)logout{
    
    NSLog(@"%@", [[LoginManager logout] description]);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         @"application/json",
                                                         nil];
    [manager POST:LOGOUT_URL
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
              if([resultDict[@"reply_code"] intValue] == 101){
                  [self.actionButton setTitle:@"Login"];
              }
              
              NSDate *date = [NSDate date];
              NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
              [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
              NSString *dateString = [dateFormatter stringFromDate:date];
              
              [self.logView setString:[self.logView.string stringByAppendingString:[NSString stringWithFormat:@"%@  %@\n", dateString, resultDict[@"reply_msg"]]]];
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];
}

- (IBAction)buttonAction:(id)sender{
    if([self.actionButton.title isEqualToString:@"Login"]){
        [self login];
    }else{
        [self logout];
    }
}

@end