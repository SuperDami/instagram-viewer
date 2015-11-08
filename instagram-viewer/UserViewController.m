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
#import "DetailCell.h"
#import "IVLoader.h"


@interface UserViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UserView *userView;
@property (nonatomic, weak)InstagramEngine *instagramEngine;
@property (nonatomic, strong)IVLoader *loader;
@property (nonatomic, assign)NSInteger selectedTabIndex;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DetailCell class] forCellReuseIdentifier:NSStringFromClass([DetailCell class])];
    self.instagramEngine = [InstagramEngine sharedEngine];
    self.loader = [[IVLoader alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];
    _userView = [[UserView alloc] initWithFrame:CGRectMake(0.0, -280.0, self.view.bounds.size.width, 280.0)];
    _userView.backgroundColor = [UIColor clearColor];
    
    _selectedTabIndex = 0;
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[@"posts", @"likes"]];
    segControl.tintColor = [UIColor lightGrayColor];
    [_userView addSubview:segControl];
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventValueChanged];
    [segControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@30);
        make.centerX.equalTo(_userView);
        make.bottom.equalTo(_userView).offset(-10);
    }];
    
    [self.tableView addSubview:_userView];
    self.tableView.contentInset = UIEdgeInsetsMake(_userView.bounds.size.height, 0.0, 0.0, 0.0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticationChanged:)
                                                 name:InstagramKitUserAuthenticationChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaDataUpdated:)
                                                 name:IVLoaderUserDataUpdated
                                               object:nil];
    [self resetStatusForAuth];
    
    
    [self.tableView reloadData];
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
    
    [self reloadList];
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

- (void)mediaDataUpdated:(NSNotification *)noti {
    NSUInteger offset = [self.tableView numberOfRowsInSection:0];
    NSInteger count = [self.loader.mediaArray count] - offset;
    NSMutableArray *ipArray = [NSMutableArray array];
    if (count > 0) {
        for (NSInteger i = 0; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:offset + i inSection:0];
            [ipArray addObject:indexPath];
        }
        [self.tableView insertRowsAtIndexPaths:ipArray withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}

- (void)tabSelected:(UISegmentedControl *)sender {
    _selectedTabIndex = sender.selectedSegmentIndex;
    [self reloadList];
}

- (void)reloadList {
    if (_selectedTabIndex == 0) {
        [self.loader reloadUserPosts];
    } else {
        [self.loader reloadUserLikes];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate Methods -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loader.mediaArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InstagramMedia *media = [self.loader.mediaArray objectAtIndex:indexPath.row];
    return [DetailCell cellHeightWithScreenWidth:self.view.bounds.size.width media:media];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DetailCell class]) forIndexPath:indexPath];
    cell.media = self.loader.mediaArray[indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {    
    if (self.tableView.contentOffset.y > self.tableView.contentSize.height - 2 * self.tableView.bounds.size.height) {
        [self.loader loadMoreIfPossibleCount:10];
    }
}

@end
