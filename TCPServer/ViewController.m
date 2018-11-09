//
//  ViewController.m
//  TCPServer
//
//  Created by MM on 2018/11/9.
//  Copyright © 2018年 MM. All rights reserved.
//

#import "ViewController.h"
#import "GCD/GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *portContent;
@property (weak, nonatomic) IBOutlet UITextView *connectedClients;
@property (weak, nonatomic) IBOutlet UITextView *sendContent;
@property (weak, nonatomic) IBOutlet UITextView *receiveContent;
@property (weak, nonatomic) IBOutlet UIButton *monitorBtn;
@property(strong,nonatomic) GCDAsyncSocket* serverSocket;
@property(strong,nonatomic) GCDAsyncSocket* clientSocket;
@property (nonatomic,strong) NSMutableArray *clientArr;
@end

@implementation ViewController
- (NSMutableArray *)clientArr
{
    if (!_clientArr) {
        _clientArr = [NSMutableArray array];
    }
    return _clientArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.sendContent.layer.borderWidth = 0.5;
    
    self.receiveContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.receiveContent.layer.borderWidth = 0.5;
    
    [self start];
}
-(void)start{
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    BOOL result = [self.serverSocket acceptOnPort:2222 error:&error];
    if(result && !error) {
        NSLog(@"端口正在监听");
    }else {
        NSLog(@"端口监听失败，错误为:%@",error);
    }
}
- (IBAction)monitorAction:(UIButton *)sender {
    if (sender.isSelected == NO) {
        [sender setSelected:YES];
        
    }else{
        [sender setSelected:NO];
    }
    [self.view endEditing:YES];
}
- (IBAction)sendClearAction:(UIButton *)sender {
    self.sendContent.text = @"";
}

- (IBAction)sendAction:(UIButton *)sender {
    NSData *data = [self.sendContent.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
    [self.clientSocket disconnectAfterReadingAndWriting];
    [self.view endEditing:YES];
}

- (IBAction)receiveClearAction:(UIButton *)sender {
    self.receiveContent.text = @"";
}
#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"连接成功");
    NSLog(@"%@",[NSString stringWithFormat:@"链接地址:%@",newSocket.connectedHost]);
    self.clientSocket = newSocket; //使用这个newSocket和client通信，客户端方自己也有一个socket与服务器通信，这俩你个socket的建立通信通道是同一个的
    [self.clientSocket readDataWithTimeout:-1 tag:0];
    self.connectedClients.text = [NSString stringWithFormat:@"已连接的客户端--1个\n%@",newSocket.connectedHost];
//    if (self.clientArr.count == 0) {
//        [self.clientArr addObject:newSocket.connectedHost];
//    }else{
//        [self.clientArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isEqual:newSocket.connectedHost]) {
//                return ;
//            }
//            if (idx == self.clientArr.count-1) {
//                [self.clientArr addObject:newSocket.connectedHost];
//            }
//        }];
//    }
//    NSMutableString *str = [NSMutableString stringWithFormat:@"已连接的客户端--%lu个\n",(unsigned long)self.clientArr.count];
//    [self.clientArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [str appendFormat:@"%@\n",obj];
//    }];
//    self.connectedClients.text = str;
}
//成功读取客户端发过来的消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"读取客户端发过来的消息 = %@",message);
    _receiveContent.text = message;
    [self.clientSocket readDataWithTimeout:-1 tag:0];
    
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接");
    self.connectedClients.text = @"已连接的客户端--0个";
}

@end
