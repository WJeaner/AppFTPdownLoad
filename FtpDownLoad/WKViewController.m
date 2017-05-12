//
//  WKViewController.m
//  FtpDownLoad
//
//  Created by Jeaner on 17-5-12.
//  Copyright (c) 2017年 atany. All rights reserved.
//

#define Your_FTP_Account @"test"
#define Your_FTP_Password @"test"

#import "WKViewController.h"

@interface WKViewController ()

@property (nonatomic, strong)   NSInputStream *   networkStream;//输入流
@property (nonatomic, copy)     NSString *        filePath;
@property (nonatomic, strong)   NSOutputStream *  fileStream;//输出流

@end

@implementation WKViewController
@synthesize serverInput = _serverInput;
@synthesize status = _status;
@synthesize imageView = _imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 点击下载按钮
- (IBAction)downLoadAction:(id)sender {
    
    
    CFReadStreamRef ftpStream;
    NSURL *url;
    
    //获得地址
    url =[NSURL URLWithString:_serverInput.text];

    
    NSString  *account = Your_FTP_Account;//_accountInput.text;
    NSString *password = Your_FTP_Password;//_passwordInput.text;
    
    NSLog(@"url is %@",url);

    // 为文件存储路径打开流，filePath为文件写入的路径,hello为图片的名字
//    self.filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    
    //这是本地电脑的路径
//    self.filePath = @"/Users/dev/Desktop/test.jpg";
    
    //这是手机沙盒路径
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    self.filePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"filename"]]];
    
    self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
    [self.fileStream open];
    
    
    
    // 打开CFFTPStream
    ftpStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    self.networkStream = (__bridge NSInputStream *) ftpStream;
    assert(ftpStream != NULL);
    
    //设置ftp账号密码
    [self.networkStream setProperty:account forKey:(id)kCFStreamPropertyFTPUserName];
    [self.networkStream setProperty:password forKey:(id)kCFStreamPropertyFTPPassword];
    
    // 设置代理
    self.networkStream.delegate = self;
    
    // 启动循环
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.networkStream open];

    CFRelease(ftpStream);
}

#pragma mark NSStreamDelegate委托方法
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSInteger bytesRead;
            uint8_t buffer[32768];//缓冲区的大小 32768可以设置，uint8_t为一个字节大小的无符号int类型
            
            // 读取数据
            bytesRead = [self.networkStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1) {
                [self _stopReceiveWithStatus:@"读取网络数据出错"];
            } else if (bytesRead == 0) {
                //下载成功
                [self _stopReceiveWithStatus:nil];
            } else {
                NSInteger   bytesWritten;//实际写入数据
                NSInteger   bytesWrittenSoFar;//当前数据写入位置
                
                // 写入文件
                bytesWrittenSoFar = 0;
                do {
                    bytesWritten = [self.fileStream write:&buffer[bytesWrittenSoFar] maxLength:bytesRead - bytesWrittenSoFar];
                    assert(bytesWritten != 0);
                    if (bytesWritten == -1) {
                        [self _stopReceiveWithStatus:@"文件写入出错"];
                        assert(NO);
                        break;
                    } else {
                        bytesWrittenSoFar += bytesWritten;
                    }
                } while (bytesWrittenSoFar != bytesRead);
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);     
        } break;
        case NSStreamEventErrorOccurred: {
            [self _stopReceiveWithStatus:@"打开出错，请检查路径"];
            assert(NO);
        case NSStreamEventEndEncountered: {
        } break;
        default:
            assert(NO);
            break;
        }
    }
}

#pragma mark 结果处理，关闭链接
- (void)_stopReceiveWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    if(statusString == nil){
        statusString = @"下载成功";
        _imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
    }
    self.status.text = statusString;
    
    self.filePath = nil;
}

-(IBAction)didEndEditing:(id)sender{
    [sender resignFirstResponder];
}


@end
