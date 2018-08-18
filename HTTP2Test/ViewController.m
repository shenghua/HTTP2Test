//
//  ViewController.m
//  HTTP2Test
//
//  Created by ledka on 2018/7/25.
//  Copyright © 2018 ledka. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initURLSession];
    
    UIButton *getReportPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getReportPageButton.frame = CGRectMake(20, 100, 80, 30);
    getReportPageButton.titleLabel.text = @"getReportPage";
    getReportPageButton.tintColor = [UIColor whiteColor];
    getReportPageButton.backgroundColor = [UIColor grayColor];
    [self.view addSubview:getReportPageButton];
    
    [getReportPageButton addTarget:self action:@selector(fetchReport) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"start=======");
    for (int i = 0; i < 1000; i++) {
        [self fetchReport];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initURLSession
{
    if (!self.sessionConfiguration) {
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    if (!self.operationQueue) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
}

- (NSURLRequest *)requestWithURLString:(NSString *)urlString params:(NSDictionary *)params
{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:[url host], NSHTTPCookieDomain,
                                                                                [url path], NSHTTPCookiePath,
                                                                                @"sessionid", NSHTTPCookieName,
                                                                                @"798bbda7-1d55-4df0-b04d-e231183a3705", NSHTTPCookieValue, // test
//                                                                                @"8cf17c31-3491-4820-90c8-a9ebe951554f", NSHTTPCookieValue, // http2
                                                                                nil];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookie:cookie];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = YES;
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"1.0.0" forHTTPHeaderField:@"Api-Version"];
    [request setValue:@"1.0.0" forHTTPHeaderField:@"App-Version"];
    [request setValue:@"am" forHTTPHeaderField:@"Platform"];
    [request setValue:@"yingyongbao" forHTTPHeaderField:@"Channel-Name"];
    
    [request setHTTPBody:jsonData];
    
    return request;
}

- (void)fetchReport
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"15", @"pageSize",
                                                                      @"1", @"pageNo", nil];
    
    // HTTP2.0
//    NSURLRequest *request = [self requestWithURLString:@"https://music-stu-app-dev.zmlearn.com:8443/api/v1.0.0/lesReport/getReportPage" params:params];
    
    // Test
    NSURLRequest *request = [self requestWithURLString:@"https://music-stu-app-test.zmlearn.com/api/lesReport/getReportPage" params:params];
    
    NSURLSessionDataTask *sessionDataTask = [self.session dataTaskWithRequest:request];
    
    [sessionDataTask resume];
}

- (void)fetchStudentInfo
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"15", @"pageSize",
                            @"1", @"pageNo", nil];
    
    // HTTP2.0
//    NSURLRequest *request = [self requestWithURLString:@"https://music-stu-app-dev.zmlearn.com:8443/api/v1.0.0/student/stuInfo" params:params];
    
    // Test
    NSURLRequest *request = [self requestWithURLString:@"https://music-stu-app-test.zmlearn.com/api/student/stuInfo" params:params];
    
    NSURLSessionDataTask *sessionDataTask = [self.session dataTaskWithRequest:request];
    
    [sessionDataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil]);
    
    NSLog(@"end=====");
}

@end
