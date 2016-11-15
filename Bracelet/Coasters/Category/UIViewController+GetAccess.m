//
//  UIViewController+GetAccess.m
//  Coasters
//
//  Created by 丁付德 on 15/12/18.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "UIViewController+GetAccess.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

#if isHaveMicrophoneAccess
#import <AVFoundation/AVFoundation.h>
#endif

#define kSD(_S)                         NSLocalizedString(_S, @"")

@implementation UIViewController (GetAccess)



#pragma mark  判断是否含有权限  当有权限的时候 进行操作  1: 相册  2: 摄像头  3:麦克风 4:   5:
- (void)getAccessNext:(AccessType)typeSub block:(GetAccessSuccessHander)block
{
    switch (typeSub)
    {
        case PhotosAccess:
        {
            ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = [NSString stringWithFormat:@"请在“设置-隐私-照片“选项中,允许'红马手环'访问你的照片"];
                    [[[UIAlertView alloc] initWithTitle:kSD(@"提示") message:kSD(message) delegate:nil cancelButtonTitle:nil otherButtonTitles:kSD(@"好"), nil] show];
                });
            }else{
                block();
            }
        }
            break;
        case CameraAccess:
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = [NSString stringWithFormat:@"请在“设置-隐私-相机“选项中,允许'红马手环'访问你的相机"];
                    [[[UIAlertView alloc] initWithTitle:kSD(@"提示") message:kSD(message) delegate:nil cancelButtonTitle:nil otherButtonTitles:kSD(@"好"), nil] show];
                });
            }else{
                block();
            }
        }
            break;
            
#if isHaveMicrophoneAccess
        case MicrophoneAccess:
        {
            AVAudioSession *avSession = [AVAudioSession sharedInstance];
            if ([avSession respondsToSelector:@selector(requestRecordPermission:)])
            {
                [avSession requestRecordPermission:^(BOOL available)
                 {
                     if (available) {
                         block();
                     }
                     else
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSString *message = [NSString stringWithFormat:@"请在“设置-隐私-麦克风“选项中,允许'红马手环'访问你的麦克风"];
                             [[[UIAlertView alloc] initWithTitle:kSD(@"提示") message:kSD(message) delegate:nil cancelButtonTitle:nil otherButtonTitles:kSD(@"好"), nil] show];
                         });
                     }
                 }];
            }
        }
            break;
#endif
            
        default:
            break;
    }
}


@end
