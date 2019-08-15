//
//  ZYRecordBoxView.h
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZYRecordBoxView;

@protocol ZYRecorderBoxViewDelegate <NSObject>

/// 按住说话
- (void)chatBoxDidStartRecordingVoice:(ZYRecordBoxView *)chatBox;
/// 松开结束
- (void)chatBoxDidStopRecordingVoice:(ZYRecordBoxView *)chatBox;
/// 取消说话
- (void)chatBoxDidCancelRecordingVoice:(ZYRecordBoxView *)chatBox;
/// 是否在按钮区域内
- (void)chatBoxDidDrag:(BOOL)inside;

@end

@interface ZYRecordBoxView : UIView

@property (nonatomic, weak) id<ZYRecorderBoxViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
