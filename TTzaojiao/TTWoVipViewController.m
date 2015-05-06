//
//  TTWoVipViewController.m
//  TTzaojiao
//
//  Created by Liang Zhang on 15/5/6.
//  Copyright (c) 2015年 hegf. All rights reserved.
//

#import "TTWoVipViewController.h"
#import "AlipayRequestConfig+TTAlipay.h"
#import <RDVTabBarController.h>
#import "TTUserModelTool.h"

@interface TTWoVipViewController ()
@property (strong, nonatomic) IBOutlet UITextField *accountTextFiled;
@property (strong, nonatomic) IBOutlet UITextField *cardTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *commitButton;
@property (strong, nonatomic) IBOutlet UIButton *payButton;

@end

@implementation TTWoVipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _commitButton.layer.borderWidth = 1;
    _commitButton.layer.borderColor = (__bridge CGColorRef)([UIColor colorWithRed:0.710 green:0.251 blue:0.357 alpha:1.000]);
    _commitButton.layer.cornerRadius = 20.f;
    _payButton.layer.borderWidth = 1;
    _payButton.layer.borderColor = (__bridge CGColorRef)([UIColor colorWithRed:0.710 green:0.251 blue:0.357 alpha:1.000]);
    _payButton.layer.cornerRadius = 20.f;
    
    NSString *account = [[[TTUserModelTool sharedUserModelTool] logonUser] name];
    if (account != nil &&
        ![account isEqualToString:@""]) {
        _accountTextFiled.text = account;
    }
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

- (IBAction)commitAction:(UIButton *)sender {
//    PAY_BY_CARD
}

- (IBAction)alipayAction:(UIButton *)sender {
//    VIP_PRICE
    [self performSegueWithIdentifier:@"vippriceSegue" sender:self];
}

@end