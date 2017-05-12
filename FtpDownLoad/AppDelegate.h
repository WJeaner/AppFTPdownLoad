//
//  AppDelegate.h
//  FtpDownLoad
//
//  Created by dev on 2017/5/12.
//  Copyright © 2017年 Jeaner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

