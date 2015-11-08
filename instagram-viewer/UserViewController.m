//
//  UserViewController.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/8/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "UserViewController.h"
#import "LoginViewController.h"
#import "InstagramKit.h"
#import "UserView.h"

@interface UserViewController ()
@property (nonatomic, strong)UserView *userView;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _userView = [[UserView alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height / 2.0)];
    _userView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_userView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticationChanged:)
                                                 name:InstagramKitUserAuthenticationChangedNotification
                                               object:nil];
    [self resetStatusForAuth];
}

- (void)resetStatusForAuth {
    if ([[InstagramEngine sharedEngine] isSessionValid]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
        __weak typeof(self) weakMe = self;
        [[InstagramEngine sharedEngine] getUserDetails:@"self" withSuccess:^(InstagramUser *user) {
            weakMe.title = user.username;
            weakMe.userView.user = user;
        } failure:nil];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title = nil;
        _userView.user = nil;
        
        if (!self.presentedViewController) {
            LoginViewController *loginNavigationViewController = [[LoginViewController alloc] init];
            UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:loginNavigationViewController];
            [self presentViewController:navVc animated:YES completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)logout:(id)sender {
    [[InstagramEngine sharedEngine] logout];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"InstagramKit" message:@"You are now logged out." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)userAuthenticationChanged:(NSNotification *)notification {
    [self resetStatusForAuth];
}

@end
