//
//  CommonMacro.h
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#ifndef CommonMacro_h
#define CommonMacro_h

#define HEIGHT_SCREEN       [UIScreen mainScreen].bounds.size.height
#define WIDTH_SCREEN        [UIScreen mainScreen].bounds.size.width

// RGB颜色
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define HEXRGBCOLOR(h)      RGBCOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF))
#define HEXRGBACOLOR(h,a)   RGBACOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF), a)

//适配 X 系列
#define IS_IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
//适配X 状态栏
#define STATUSBAR_HEIGHT (IS_IPHONE_X ? 44.f : 20.f)
//适配X tabbar高度
#define TABBAR_HEIGHT (IS_IPHONE_X ? (49.f + 34.f) : 49.f)
//适配X Tabbar距离底部的距离
#define TABBAR_SAFE_BOTTOM_MARGIN (IS_IPHONE_X ? 34.f : 0.f)
//适配X 导航栏高度
#define NAV_HEIGHT (IS_IPHONE_X ? 88.f : 64.f)

#endif /* CommonMacro_h */
