//
//  TTDongTaiViewController.m
//  TTzaojiao
//
//  Created by Liang Zhang on 15/4/21.
//  Copyright (c) 2015年 hegf. All rights reserved.
//

#import "TTDongTaiViewController.h"
#import "BlogModel.h"
#import "TTBlogFrame.h"
#import "TTCommentListViewController.h"
#import "TTUserDongtaiViewController.h"
#import "NearByBabyModel.h"

@interface TTDongTaiViewController (){
    NSMutableArray* _blogs;
    NSMutableArray* _nearByBabys;
    NSUInteger _pageIndexInt;
    NSString* _i_sort;
    NSString* _group;
    UIView* _customHeaderView;
    UISegmentedControl* _sortSeg;
    BOOL _isGetMoreBlog;
}
@property (weak, nonatomic) IBOutlet UITableView *dongtaiTable;
@property (strong, nonatomic) TTDynamicSidebarViewController *siderbar;

@end

@implementation TTDongTaiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadHeaderView];
    
    [self setupRefresh];
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars
        = NO;
        self.modalPresentationCapturesStatusBarAppearance
        = NO;
    }

    UIBarButtonItem* itemright = [UIBarButtonItem barButtonItemWithImage:@"icon_add_dynamic_state" target:self action:@selector(dynamic_state:)];
    self.navigationItem.rightBarButtonItem = itemright;
    
    
    UIBarButtonItem* itemleft = [UIBarButtonItem barButtonItemWithImage:@"icon_menu" target:self action:@selector(selAgeRange:)];
    self.navigationItem.leftBarButtonItem = itemleft;
    
    // 左侧边栏开始
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [panGesture delaysTouchesBegan];
    [self.tabBarController.view addGestureRecognizer:panGesture];
    
    self.siderbar = [[TTDynamicSidebarViewController alloc] init];
    self.siderbar.delegate = self;
    [self.siderbar setBgRGB:0xF09EB1];
    [self.rdv_tabBarController.view addSubview:self.siderbar.view];
    self.siderbar.view.frame  = self.view.bounds;
    // 左侧边栏结束
    
    _pageIndexInt = 1;
    _group = @"0";//全部月龄
    _i_sort = @"1"; //早教自拍
    [self updateBlog];
}

-(void)dynamic_state:(UIBarButtonItem*)item{
    [self performSegueWithIdentifier:@"toRelease" sender:nil];
}

-(void)selAgeRange:(UIBarButtonItem*)item{
    [_siderbar showHideSidebar];
}

-(void)didselAgeGroup:(NSString *)group{
    _pageIndexInt = 1;
    _group = group;
    [self updateBlog];
}

-(void)setupRefresh{
    _isGetMoreBlog = NO;
    [_dongtaiTable addLegendHeaderWithRefreshingBlock:^{
        [_dongtaiTable.header beginRefreshing];
        _pageIndexInt = 1;
        if (_sortSeg.selectedSegmentIndex == 3) {
            [self showNearByBaby];
        }else{
            [self updateBlog];
        }
    }];

    [_dongtaiTable addLegendFooterWithRefreshingBlock:^{
        [_dongtaiTable.footer beginRefreshing];
        _pageIndexInt++;
        _isGetMoreBlog = YES;
        if (_sortSeg.selectedSegmentIndex == 3) {
            [self showNearByBaby];
        }else{
            [self updateBlog];
        }
    }];
    
}

-(void)loadHeaderView{
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    _customHeaderView = view;
    view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    NSArray* items = @[@"早教自拍", @"课程提问", @"宝宝生活", @"附近宝宝"];
    
    UISegmentedControl* sortSeg = [[UISegmentedControl alloc]initWithItems:items];
    sortSeg.frame = CGRectMake(40, 4, view.frame.size.width-80, view.frame.size.height-8);
    [sortSeg addTarget:self action:@selector(selChanged:) forControlEvents:UIControlEventValueChanged];
    sortSeg.tintColor = [UIColor colorWithHue:216.0/255.0 saturation:117.0/255.0 brightness:152.0/255.0 alpha:1.0];
    NSDictionary* textAttr1 = @{
                                NSForegroundColorAttributeName:[UIColor colorWithRed:255.0/255.0 green:168.0/255.0 blue:188.0/255.0 alpha:1.0f]
                                };
    [sortSeg setTitleTextAttributes:textAttr1 forState:UIControlStateNormal];
    NSDictionary* textAttr2 = @{
                                NSForegroundColorAttributeName:[UIColor whiteColor]
                                };
    [sortSeg setTitleTextAttributes:textAttr2 forState:UIControlStateSelected];
    _sortSeg = sortSeg;
    sortSeg.selectedSegmentIndex = 0;
    [view addSubview:sortSeg];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.siderbar panDetected:recoginzer];
}

-(void)updateBlog{
   
    NSString* pageIndex = [NSString stringWithFormat:@"%ld", _pageIndexInt];
    NSString* i_uid = [TTUserModelTool sharedUserModelTool].logonUser.ttid;
    NSDictionary* parameters = @{
                                 @"i_uid": i_uid,
                                 @"p_1": pageIndex,
                                 @"p_2": @"15",
                                 @"i_sort": _i_sort,
                                 @"i_group": _group
                                 };
    [MBProgressHUD showHUDAddedTo:_dongtaiTable animated:YES];
    [[AFAppDotNetAPIClient sharedClient]apiGet:GET_LIST_BLOG_GROUP Parameters:parameters Result:^(id result_data, ApiStatus result_status, NSString *api) {
        [MBProgressHUD hideAllHUDsForView:_dongtaiTable animated:YES];
        if (_blogs == nil) {
            _blogs = [NSMutableArray array];
        }
        if (result_status == ApiStatusSuccess) {
            if (_isGetMoreBlog) {
                [_dongtaiTable.footer endRefreshing];
                _isGetMoreBlog = NO;
            }else{
                [_dongtaiTable.header endRefreshing];
                [_blogs removeAllObjects];
            }
            if ([result_data isKindOfClass:[NSMutableArray class]]) {
                [result_data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[BlogModel class]]) {
                        [_blogs addObject:obj];
                    }
                }];

                [_dongtaiTable reloadData];
            }
            
        }else{
            if (_isGetMoreBlog) {
                [_dongtaiTable.footer endRefreshing];
                _isGetMoreBlog = NO;
            }else{
                [_dongtaiTable.header endRefreshing];
            }
            if (result_status != ApiStatusNetworkNotReachable) {
                [[[UIAlertView alloc]init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
            }
        };
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return _customHeaderView;
    }else
    return [[UIView alloc]initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 44.f;
    }
    return 1.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if (_sortSeg.selectedSegmentIndex == 3) {
        TTNearBybabyTableViewCell* cell = [TTNearBybabyTableViewCell nearBybabyCellWithTableView:tableView];
        
        cell.nearByBaby = _nearByBabys[indexPath.row];
        cell.delegate = self;
        return cell;
    }else{
        TTDyanmicUserStautsCell* cell = [TTDyanmicUserStautsCell dyanmicUserStautsCellWithTableView:tableView];
        TTBlogFrame* frame = [[TTBlogFrame alloc]init];
        frame.blog = _blogs[indexPath.row];
        cell.blogFrame = frame;
        //评论列表View的代理 响应查看全部按钮代理方法
        cell.delegate = self;
        return cell;
    }
    
}

//附近宝宝头像点击处理
-(void)didIconTaped:(NSString *)uid{
    [self performSegueWithIdentifier:@"toUserDynamic" sender:uid];
}

//点赞
-(void)daynamicUserStatusZanClicked:blogid{
    
    NSDictionary* parameters = @{
                                 @"i_uid": [TTUserModelTool sharedUserModelTool].logonUser.ttid,
                                 @"i_psd": [TTUserModelTool sharedUserModelTool].password,
                                 @"id": blogid,
                                 };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AFAppDotNetAPIClient sharedClient]apiGet:PRAISE_NEW Parameters:parameters Result:^(id result_data, ApiStatus result_status, NSString *api) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result_status == ApiStatusSuccess) {
            
            [self updateBlog];
        }else{
            if (result_status != ApiStatusNetworkNotReachable) {
                [[[UIAlertView alloc]init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
            }
        };
        
    }];

}

//消息查看
-(void)daynamicUserStatusRemsgClicked:(NSString *)blogid{
    [self performSegueWithIdentifier:@"toCommentList" sender:blogid];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_sortSeg.selectedSegmentIndex == 3) {
        return _nearByBabys.count;
    }else{
        return _blogs.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_sortSeg.selectedSegmentIndex == 3) {
        return ScreenWidth*TTHeaderWithRatio+2*TTBlogTableBorder;
    }else{
        TTBlogFrame* frame = [[TTBlogFrame alloc]init];
        frame.blog = _blogs[indexPath.row];
        return frame.cellHeight;
    }
}

- (void)selChanged:(UISegmentedControl *)sender {
    _pageIndexInt = 1;
    
    _i_sort = [NSString stringWithFormat:@"%ld", sender.selectedSegmentIndex + 1];
    if ([_i_sort isEqualToString:@"4"]) {
        [[TTCityMngTool sharedCityMngTool] startLocation:^(CLLocation *location, NSError *error) {
            if (location != nil) {
                _location = location;
            }else{
                _location = nil;
            }
            [self showNearByBaby];
            //回到顶部
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [_dongtaiTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }];
    }else{
        [self updateBlog];
        //回到顶部
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_dongtaiTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    

}

#pragma mark 查看回复全部列表
-(void)dynamicCommentsView:(TTDynamicCommentsView *)dynamicCommentsView didShowCommentList:(NSString *)blog_id{
    [self performSegueWithIdentifier:@"toCommentList" sender:blog_id];
}

#pragma mark 头像点击代理
-(void)dynamicUserStatusTopView:(TTDynamicUserStatusTopView *)view didIconTaped:(NSString *)uid{
    [self performSegueWithIdentifier:@"toUserDynamic" sender:uid];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[TTCommentListViewController class]]) {
        TTCommentListViewController* dvc = (TTCommentListViewController*)segue.destinationViewController;
        dvc.blog_id = sender;
    }
    if ([segue.destinationViewController isKindOfClass:[TTUserDongtaiViewController class]]) {
        
        TTUserDongtaiViewController* uvc = (TTUserDongtaiViewController*)segue.destinationViewController;
        uvc.i_uid = sender;
    }
}

-(void)showNearByBaby{
//    String result = WebServer
//    .requestByGet(WebServer.NEARBY_BABY + "&i_uid="
//                  + uid + "&i_psd=" + secondPassword
//                  + "&p_1=" + pageIndex + "&p_2=10" + "&i_x="
//                  + latitude + "&i_y=" + longitude);
    NSString* pageIndex = [NSString stringWithFormat:@"%ld", _pageIndexInt];
    NSString* lat = @"0";
    NSString* lon = @"0";
    if (_location != nil) {
        lat = [NSString stringWithFormat:@"%f", _location.coordinate.latitude];
        lon = [NSString stringWithFormat:@"%f", _location.coordinate.longitude];
    }
    
    NSDictionary* parameters = @{
                                 @"i_uid": [TTUserModelTool sharedUserModelTool].logonUser.ttid,
                                 @"i_psd": [TTUserModelTool sharedUserModelTool].password,
                                 @"p_1": pageIndex,
                                 @"p_2": @"10",
                                 @"i_x": lat,
                                 @"i_y": lon
                                 };
    
    [MBProgressHUD showHUDAddedTo:_dongtaiTable animated:YES];
    [[AFAppDotNetAPIClient sharedClient]apiGet:NEARBY_BABY Parameters:parameters Result:^(id result_data, ApiStatus result_status, NSString *api) {
        [MBProgressHUD hideAllHUDsForView:_dongtaiTable animated:YES];
        if (_nearByBabys == nil) {
            _nearByBabys = [NSMutableArray array];
        }
        if (result_status == ApiStatusSuccess) {
            if (_isGetMoreBlog) {
                [_dongtaiTable.footer endRefreshing];
                _isGetMoreBlog = NO;
            }else{
                [_dongtaiTable.header endRefreshing];
                [_nearByBabys removeAllObjects];
            }
            if ([result_data isKindOfClass:[NSMutableArray class]]) {
                NSMutableArray* array = result_data;
                if ([result_data[0] isKindOfClass:[NearByBabyModel class]] && array.count > 0) {
                    NearByBabyModel* msg = result_data[0];
                    if ([msg.msg isEqualToString:@"Get_Test_User_List_Distance"]) {
                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            if (idx > 0) {
                                if ([obj isKindOfClass:[NearByBabyModel class]]) {
                                    [_nearByBabys addObject:obj];
                                }
                            }
                        }];
                        
                        [_dongtaiTable reloadData];
                    }else{
                        [[UIAlertView alloc]showAlert:msg.msg byTime:2.f];
                    }

                }
                
            }
            
        }else{
            if (_isGetMoreBlog) {
                [_dongtaiTable.footer endRefreshing];
                _isGetMoreBlog = NO;
            }else{
                [_dongtaiTable.header endRefreshing];
            }
            if (result_status != ApiStatusNetworkNotReachable) {
                [[[UIAlertView alloc]init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
            }
        };
    }];
}

@end
