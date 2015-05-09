//
//  TTWoPersonalInfoViewController.m
//  TTzaojiao
//
//  Created by Liang Zhang on 15/5/7.
//  Copyright (c) 2015年 hegf. All rights reserved.
//

#import "TTWoPersonalInfoViewController.h"
#import <RDVTabBarController.h>
#import "TTUserModelTool.h"
#import "TTCityMngTool.h"
#import "TTUserDongtaiViewController.h"

@interface TTWoPersonalInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextField *accountTextFeild;
@property (strong, nonatomic) IBOutlet UITextField *nameTextFeild;
@property (strong, nonatomic) IBOutlet UIButton *commitButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButtonItem;

@end

@implementation TTWoPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _commitButton.layer.borderWidth = 1;
    _commitButton.layer.borderColor = (__bridge CGColorRef)([UIColor colorWithRed:0.710 green:0.251 blue:0.357 alpha:1.000]);
    _commitButton.layer.cornerRadius = 20.f;
    
    _accountTextFeild.text = [[TTUserModelTool sharedUserModelTool] account];
    _nameTextFeild.text = [[[TTUserModelTool sharedUserModelTool] logonUser] name];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)rightAction:(id)sender {
    UIStoryboard *storyBoardDongTai=[UIStoryboard storyboardWithName:@"DongTaiStoryboard" bundle:nil];
    TTUserDongtaiViewController *userViewController = (TTUserDongtaiViewController *)[storyBoardDongTai instantiateViewControllerWithIdentifier:@"UserUIM"];
    [userViewController setI_uid:[[[TTUserModelTool sharedUserModelTool] logonUser] ttid]];
    [self.navigationController pushViewController:userViewController animated:YES];
}

- (IBAction)commitAction:(UIButton *)sender {
    [[AFAppDotNetAPIClient sharedClient] apiGet:UPDATE_INFO
                                     Parameters:@{@"i_uid":[[[TTUserModelTool sharedUserModelTool] logonUser] ttid],
                                                  @"i_psd":[[TTUserModelTool sharedUserModelTool] password],
                                                  @"phone":_accountTextFeild.text,
                                                  @"name":_nameTextFeild.text,
                                                  @"city":[[TTCityMngTool sharedCityMngTool] citytoCode:[[[TTUserModelTool sharedUserModelTool] logonUser] city]],
                                                  @"address":@""}
                                         Result:^(id result_data, ApiStatus result_status, NSString *api) {
        if (result_status == ApiStatusSuccess) {
            [[TTUserModelTool sharedUserModelTool] setAccount:_accountTextFeild.text];
            [[[TTUserModelTool sharedUserModelTool] logonUser] setName:_nameTextFeild.text];
            [MBProgressHUD TTDelayHudWithMassage: @"更新成功！" View:self.navigationController.view];
        }
        else {
            [[[UIAlertView alloc] init] showWithTitle:@"友情提示" message:@"服务器好像罢工了" cancelButtonTitle:@"重试一下"];
        }
    }];
}

@end