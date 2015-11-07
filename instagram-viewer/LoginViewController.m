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

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];

    NSURL *authURL = [[InstagramEngine sharedEngine] authorizationURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];

//    [self.navigationItem.rightBarButtonItem setEnabled:NO];
//    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Login"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
}

- (void)close:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSError *error;
    if ([[InstagramEngine sharedEngine] receivedValidAccessTokenFromURL:request.URL error:&error])
    {
        [self authenticationSuccess];
    }
    return YES;
}

- (void)authenticationSuccess
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

@end
