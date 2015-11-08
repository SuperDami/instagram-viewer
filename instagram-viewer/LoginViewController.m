//
//  LoginViewController.h
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "LoginViewController.h"
#import "InstagramKit.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation LoginViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Login";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSURL *authURL = [[InstagramEngine sharedEngine] authorizationURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
}

- (void)close:(id) sender {
    if ([self.navigationController.presentingViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)[self navigationController].presentingViewController popToRootViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSError *error;
    __weak typeof(self) weakMe = self;
    if ([[InstagramEngine sharedEngine] receivedValidAccessTokenFromURL:request.URL error:&error])
    {
        [weakMe authenticationSuccess];
    }
    return YES;
}

- (void)authenticationSuccess {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
