//
//  TTUserBlogFrame.h
//  TTzaojiao
//
//  Created by hegf on 15-4-30.
//  Copyright (c) 2015年 hegf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BlogUserDynamicModel.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define TTHeaderWithRatio 44.f/320.f
#define TTBlogTableBorder 8
#define TTBlogMaintitleFont [UIFont systemFontOfSize:16.f]
#define TTBlogSubtitleFont [UIFont systemFontOfSize:14.f]
#define TTBlogBackgroundColor [UIColor colorWithRed:244.f/255.f green:247.f/255.f blue:244.f/255.f alpha:1.f]
#define TTCellWidth [UIScreen mainScreen].bounds.size.width - 2*TTBlogTableBorder

#define TTPhotoW ((TTCellWidth-TTHeaderWithRatio*TTCellWidth - 2*TTBlogTableBorder)-2*TTPhotoMargin)*1/3
#define TTPhotoH TTPhotoW
#define TTPhotoMargin 2.f

//根据用户微博模型 计算微博控件的frame
@interface TTUserBlogFrame : NSObject

/** 顶部topView 以下是topView的子控件*/
@property (nonatomic, assign, readonly) CGRect topViewF;

/** 头像 */
@property (nonatomic, assign, readonly) CGRect iconViewF;
/** 昵称 */
@property (nonatomic, assign, readonly) CGRect nameLabelF;
/** 时间 */
@property (nonatomic, assign, readonly) CGRect timeLabelF;
/** 正文\内容 */
@property (nonatomic, assign, readonly) CGRect contentLabelF;
/** 配图 */
@property (nonatomic, assign, readonly) CGRect photosViewF;

/** 回复数和赞数 以下是回复数和赞数子控件*/
@property (nonatomic, assign, readonly) CGRect zanCountViewF;
/**回复按钮 */
@property (nonatomic, assign, readonly) CGRect remsgBtnF;
/**删除 */
@property (nonatomic, assign, readonly) CGRect delBtnF;

/** 微博模型 后设置*/
@property (strong, nonatomic) BlogUserDynamicModel* userblog;

@property (nonatomic, assign, readonly) CGFloat cellHeight;


@end
