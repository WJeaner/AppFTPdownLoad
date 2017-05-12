//
//  WKViewController.h
//  FtpDownLoad
//
//  Created by Jeaner on 17-5-12.
//  Copyright (c) 2017年 atany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKViewController : UIViewController <UITextFieldDelegate,NSStreamDelegate>
@property (strong, nonatomic) IBOutlet UITextField *serverInput;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)downLoadAction:(id)sender;
- (IBAction)didEndEditing:(id)sender;
@end
