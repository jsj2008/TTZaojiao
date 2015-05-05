//
//  TTUserDongtaiViewController.m
//  TTzaojiao
//
//  Created by hegf on 15-4-27.
//  Copyright (c) 2015年 hegf. All rights reserved.
//

#import "TTUserDongtaiViewController.h"
#import <RDVTabBarController.h>
#import "UIImageView+MoreAttribute.h"
#import <MJRefresh.h>

@interface TTUserDongtaiViewController ()
{
    NSMutableArray* _blogList;
    NSString* _pageIndex;
    BOOL _isGetMoreList;
}

@property (strong, nonatomic) DynamicUserModel* curUser;
@property (weak, nonatomic) IBOutlet UITableView *userDynamicTableView;
@property (weak, nonatomic) TTDynamicUserStatusHeaderView* headerView;

@end

@implementation TTUserDongtaiViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人动态";
    // Do any additional setup after loading the view.

    if(([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars
        = NO;
        self.modalPresentationCapturesStatusBarAppearance
        = NO;
    }
    _userDynamicTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

    //取得用户模型
    if (_i_uid.length != 0) {
        [self getUserinfo:_i_uid];
    }
    
    _blogList = [NSMutableArray array];
    _isGetMoreList = NO;
    _pageIndex = @"1";
    [self updateDynamicBlog];
    
    [self setupRefresh];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    //取得用户模型
    if (_i_uid.length != 0) {
        [self getUserinfo:_i_uid];
    }
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
}


-(void)setupRefresh{

    [_userDynamicTableView addLegendHeaderWithRefreshingBlock:^{
        [_userDynamicTableView.header beginRefreshing];
        _isGetMoreList = NO;
        _pageIndex = @"1";
        [self updateDynamicBlog];
    }];
    
    [_userDynamicTableView addLegendFooterWithRefreshingBlock:^{
        [_userDynamicTableView.footer beginRefreshing];
        _isGetMoreList = YES;
        NSUInteger idx = [_pageIndex integerValue]+1;
        _pageIndex = [NSString stringWithFormat:@"%ld", idx];
        [self updateDynamicBlog];
    }];
}


-(void)updateDynamicBlog{
    NSDictionary* parameters = @{
                                 @"i_uid": _i_uid,
                                 @"p_1": _pageIndex,
                                 @"p_2": @"15"
                                 };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AFAppDotNetAPIClient sharedClient]apiGet:USER_BLOG Parameters:parameters Result:^(id result_data, ApiStatus result_status, NSString *api) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_userDynamicTableView.header endRefreshing];
        [_userDynamicTableView.footer endRefreshing];
        
        if (result_status == ApiStatusSuccess) {
            if (!_isGetMoreList) {
                [_blogList removeAllObjects];
            }
            if ([result_data isKindOfClass:[NSMutableArray class]]) {
                if (((NSMutableArray*)result_data).count!=0) {
                    NSMutableArray* list = (NSMutableArray*)result_data;
                    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[BlogUserDynamicModel class]]) {
                            [_blogList addObject:obj];
                            [_userDynamicTableView reloadData];
                        }
                    }];
                }
            }
        }else{
            if (result_status != ApiStatusNetworkNotReachable) {
                [[[UIAlertView alloc]init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
            }
        };
        
    }];
}

-(void)getUserinfo:(NSString*)i_uid{
    
    NSDictionary* parameters = @{
                                 @"i_uid": i_uid,
                                 };
    [[AFAppDotNetAPIClient sharedClient]apiGet:USER_INFO Parameters:parameters Result:^(id result_data, ApiStatus result_status, NSString *api) {
        if (result_status == ApiStatusSuccess) {
            if ([result_data isKindOfClass:[NSMutableArray class]]) {
                NSMutableArray *modes = result_data;
                if (modes.count == 2) {
                    DynamicUserModel* ret = result_data[0];
                    if ([ret.msg isEqualToString:@"Get_List_User_Info"]) {
                        DynamicUserModel* dyuser = result_data[1];
                        _curUser = dyuser;
                        [self loadUserInfo];
                            
                        }
                        
                    }
            }else{
                if (result_status != ApiStatusNetworkNotReachable) {
                    [[[UIAlertView alloc]init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
                }
            }
        }
    }];

}

//加载用户数据
-(void)loadUserInfo{
    if(_curUser.i_Cover.length !=0){
        [_headerView.coverView setImageIcon:_curUser.i_Cover];
    }else
    if (_curUser.icon.length != 0) {
         [_headerView.iconView setImageIcon:_curUser.icon];
    }
   
    _headerView.babyName.text = _curUser.name;
    _headerView.genderMounth.text = _curUser.birthday;
    _headerView.sepintr.text = _curUser.i_intr;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TTDynamicUserBlogCell* cell = [TTDynamicUserBlogCell dyanmicUserBlogCellWithTableView:tableView];
    TTUserBlogFrame* frame = [[TTUserBlogFrame alloc]init];
    frame.userblog = _blogList[indexPath.row];
    if (_curUser.icon.length != 0) {
        [cell.topView.iconView setImageIcon:_curUser.icon];
    }else{
        [cell.topView.iconView setImage:[UIImage imageNamed:@"baby_icon1"]];
    }
    cell.topView.name.text = _curUser.name;
    cell.blogFrame = frame;
    cell.delegate = self;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _blogList.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSArray* views = [[NSBundle mainBundle]loadNibNamed:@"TTDynamicUserStatusHeaderView" owner:self options:nil];
    TTDynamicUserStatusHeaderView* headerView = [views firstObject];
    _headerView = headerView;
    _headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*9/20);
    _headerView.delegate = self;
    [self loadUserInfo];
    return _headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TTUserBlogFrame* frame = [[TTUserBlogFrame alloc]init];
    frame.userblog = _blogList[indexPath.row];
    return frame.cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.view.frame.size.height*9/20;
}

-(void)dynamicHeaderView:(TTDynamicUserStatusHeaderView *)headerView didActionType:(ActionType)type{
    switch (type) {
        case kChangeCover:
            ;
            break;
        case kChangeIcon:
            ;
            break;
        case kzanCover:
            ;
            break;
        case kBack:
            [self backToPrePaeg];
            break;
        default:
            break;
    }
}

-(void)backToPrePaeg{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dynamicUserBlogCell:(TTDynamicUserBlogCell *)cell didShowCommentList:(NSString *)blog_id{
    [self performSegueWithIdentifier:@"toCommentList" sender:blog_id];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[TTCommentListViewController class]]) {
        TTCommentListViewController* dvc = (TTCommentListViewController*)segue.destinationViewController;
        dvc.blog_id = sender;
    }

}

@end