//
//  TTLaMaViewController.m
//  TTzaojiao
//
//  Created by Liang Zhang on 15/4/21.
//  Copyright (c) 2015年 hegf. All rights reserved.
//

#import "TTLaMaViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LamaModel.h"
#import "LamaTotalModel.h"
#import "UserModel.h"
#import "TTBaseViewController.h"
#import "LamaTableViewCell.h"
#import "LaMaDetailViewController.h"
#import "TTUserDongtaiViewController.h"
#import "LaMaAddRegCompayViewController.h"
#import "TSLocateView.h"
#import "CustomDatePicker.h"
#import <MapKit/MapKit.h>
@interface TTLaMaViewController () <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSUInteger _pageIndexInt;
}
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *locationCity;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *models;
@property (copy, nonatomic) NSString* cityCode; //110000
@property (weak, nonatomic) IBOutlet UILabel *location;

@end

@implementation TTLaMaViewController

#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 150;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _pageIndexInt = 1;
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars
        = NO;
        self.modalPresentationCapturesStatusBarAppearance
        = NO;
    }
    
    
    [self setting];
    
}

- (void)loadData
{
    NSString* i_uid = [TTUserModelTool sharedUserModelTool].logonUser.ttid;
    NSString* pageIndex = [NSString stringWithFormat:@"%ld", _pageIndexInt];
    
    if (_cityCode == nil) {
        _cityCode = @"210200";
    }
    _locationCity.text = [[TTCityMngTool sharedCityMngTool]codetoCity:_cityCode];
    NSDictionary* parameters = @{
                                 @"i_uid":i_uid,
                                 @"p_1":pageIndex,
                                 @"p_2":@"10",
                                 @"i_city":_cityCode
                                 };
    //加载网络数据
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AFAppDotNetAPIClient sharedClient]apiGet:GET_LIST_ACTIVE Parameters:parameters  Result:^(id result_data, ApiStatus result_status, NSString *api) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result_status == ApiStatusSuccess) {
            //
            // NSLog(@"%@",result_data);
            
            if ([result_data isKindOfClass:[NSMutableArray class]]) {
                
                //暂时不知道有什么用途
                //              LamaTotalModel *total= [LamaTotalModel LamaTotalModelWithdict:result_data[0]];
                NSMutableArray *tempArray = [NSMutableArray array];
                
                
                [result_data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[LamaModel class]]) {
                        [tempArray addObject:obj];
                    }
                }];
                
                _models = tempArray;
                //NSLog(@"count is %zi",_models.count);
                [_tableView reloadData];
                
                //当前用户信息
                //UserModel *user = [TTUserModelTool sharedUserModelTool].logonUser;
                // NSLog(@"%@ %@", user.name, user.icon);
                
            }
            
            
        }else{
            if (result_status != ApiStatusNetworkNotReachable) {
                [[[UIAlertView alloc]init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
            }
        };
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //定位获得城市码
    [[TTCityMngTool sharedCityMngTool] startLocation:^(CLLocation *location, NSError *error) {
        //NSLog(@"latitude is %f",location.coordinate.latitude);
        if(location!=nil){
            [[TTCityMngTool sharedCityMngTool] getReverseGeocode:location Result:^(NSString *cityCode, NSError *error) {
                //假数据 macmini定位不好用
                _cityCode = cityCode;
            }];
        }
        //加载异步网络数据
        [self loadData];
    }];
    
}

#pragma mark
//ADD_REG_COMPAY
-(void) leftBtnClick
{
    
    LaMaAddRegCompayViewController *addRegCompayController = [[LaMaAddRegCompayViewController alloc]init];
    // [addRegCompayController setI_uid:[[[TTUserModelTool sharedUserModelTool] logonUser] ttid]];
    [self.navigationController pushViewController:addRegCompayController animated:YES];
    
}

#pragma mark 显示个人信息
- (void) rightBtnClick:(UIBarButtonItem*)btn
{
    
    UIStoryboard *storyBoardDongTai=[UIStoryboard storyboardWithName:@"DongTaiStoryboard" bundle:nil];
    TTUserDongtaiViewController *userViewController = (TTUserDongtaiViewController *)[storyBoardDongTai instantiateViewControllerWithIdentifier:@"UserUIM"];
    [userViewController setI_uid:[[[TTUserModelTool sharedUserModelTool] logonUser] ttid]];
    [self.navigationController pushViewController:userViewController animated:YES];
    //导航
}

- (UIImage *) loadWebImage
{
    UIImage* image=nil;
    NSString *url = [NSString stringWithFormat:@"%@%@",TTBASE_URL,[[[TTUserModelTool sharedUserModelTool] logonUser] icon]];
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];//获取网咯图片数据
    if(data!=nil)
    {
        image = [[UIImage alloc] initWithData:data];//根据图片数据流构造image
    }
    return image;
}

#pragma mark 导航条布局
- (void) setting
{
    
    
    //left
    UIButton *leftbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftbutton setImage:[UIImage imageNamed:@"icon_apply_join"]  forState:UIControlStateNormal];
    [leftbutton addTarget:self action:@selector(leftBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    leftbutton.frame = CGRectMake(50, 5, 100, 30);
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithCustomView:leftbutton];
    self.navigationItem.leftBarButtonItem= left;
    
    
    //right
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[self loadWebImage] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightBtnClick:)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem= right;
    
}


#pragma mark
//懒加载模型
- (NSMutableArray *)models
{
    
    
    return _models;
    
}


#pragma tableview 数据源以及代理方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.models.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //create cell
    
    LamaTableViewCell *cell = [LamaTableViewCell lamaCellWithTabelView:tableView];
    
    //data
    LamaModel * model=
    _models[indexPath.row];
    
    //set cell
    cell.lamaModel = model;
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerFrame = CGRectMake(0, 0, tableView.frame.size.width, 44.f);
    _headerView.frame = headerFrame;
    return _headerView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LamaModel *model = _models[indexPath.row];
    LaMaDetailViewController *detailController = [[LaMaDetailViewController alloc]init];
    //UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(160, 0, 120, 50)];
    //[title setText:@"详情"];
    // controller.navigationItem.titleView= title;
    detailController.ttid = model.ttid;
    
    self.navigationController.title = @"详情";
    [self.navigationController pushViewController:detailController animated:YES];
}



//- (IBAction)locationAction:(id)sender {
//    [self performSegueWithIdentifier:@"cityListSegue" sender:self];
//}



#pragma mark 更改位置
- (IBAction)changLocation:(UIButton *)sender {
    //[_babyName resignFirstResponder];
    
    TSLocateView *locateView = [[[NSBundle mainBundle] loadNibNamed:@"TSLocateView" owner:self options:nil] objectAtIndex:0];
    locateView.titleLabel.text = @"定位城市";
    locateView.delegate = self;
    //[[TSLocateView alloc] initWithTitle:@"定位城市" delegate:self];
    [locateView showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet isKindOfClass:[TSLocateView class]]) {
        TSLocateView *locateView = (TSLocateView *)actionSheet;
        TSLocation *location = locateView.locate;

        //You can uses location to your application.
        
        if(buttonIndex == 0) {
            _cityCode = @"";
        }else {
            NSString* cityName = [NSString stringWithFormat:@"%@市", location.city];
            _locationCity.text = cityName;
            _cityCode = [[TTCityMngTool sharedCityMngTool]citytoCode:cityName];
            NSString* cityString = [NSString stringWithFormat:@"%@ %@",location.state, location.city];
            [_location setText:cityString];
            //重新加载网络数据
            [self loadData];
        }
        
    }
}


@end
