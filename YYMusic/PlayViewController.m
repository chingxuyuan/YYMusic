//
//  PlayViewController.m
//  YYMusic
//
//  Created by CXY on 16/4/13.
//  Copyright © 2016年 CXY. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *btnPlay;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *btnNext;
@property (weak, nonatomic) IBOutlet UIImageView *btnUnfav;
@property (weak, nonatomic) IBOutlet UIImageView *btnBan;

@end

@implementation PlayViewController

@synthesize channel;
NSString *musicUrl;

AVPlayer *player;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    //设置点击事件
    self.btnPlay.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapPlay =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPlay)];
    [self.btnPlay addGestureRecognizer:tapPlay];
    
    
    self.imgBg.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapStop =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickStop)];

    [self.imgBg addGestureRecognizer:tapStop];
    
    
    self.btnNext.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapNext =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickNext)];
    
    [self.btnNext addGestureRecognizer:tapNext];

    
    
    self.btnBan.userInteractionEnabled=YES;
      UITapGestureRecognizer *tapDelete =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickNext)];
    [self.btnBan addGestureRecognizer:tapDelete];

    
  
    NSLog(@"channel: %ld", (long)(self.channel));
    [self requestList];
    
}


- (void)requestList {
    
    [self reset];
    NSString *u = @"http://douban.fm/j/mine/playlist?type=n&channel=&from=mainsite";
    NSMutableString *url = [[NSMutableString alloc] initWithString:u];
    
    
   NSString *strChannel = [NSString stringWithFormat:@"%d", channel];
        [url insertString:strChannel atIndex:48];
    
    NSString *req  = [NSString stringWithFormat:@"%@",url];
    
   
       NSLog(@"url: %@", url);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:req];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
            
            NSDictionary *dict = [self toArrayOrNSDictionary:jsonData];
            
            NSArray *ary = [dict objectForKey:@"song"];
            NSDictionary *song = [ary objectAtIndex:0];
            NSString *url = [song  objectForKey:@"url"];
            
             NSString *title = [song  objectForKey:@"title"];
            [self.labelTitle setText:title];
            musicUrl = url;
            
            
            double delayInSeconds = 0.1;
          
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               [self clickPlay];
            
            });
      
        }
    }];
    
    [dataTask resume];
    
    
    
}


-(void)playSong{
    // 创建本地URL（也可创建基于网络的URL)
    if(musicUrl == nil){
        return ;
    }
    
    if(player != nil){
        [player play];
        return;
    }
  
   NSURL *URL = [NSURL URLWithString:musicUrl];
    player = [AVPlayer playerWithURL:URL];
    AVPlayerViewController *controller=[[AVPlayerViewController alloc]init];
    controller.player=player;
    [self addChildViewController:controller];
    [player play];


}




// 将JSON串转化为字典或者数组
- (id)toArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}



//点击播放按钮
-(void)clickPlay{
    // here, do whatever you wantto do
    [_imgBg setAlpha:1.0];
     [_btnPlay setAlpha:0];
       NSLog(@"play is clicked!");
    
    [self playSong];
}

//点击播放按钮
-(void)clickNext{
    [self reset];
    [self requestList];
}


//点击唱片停止播放
-(void)clickStop{
    
    // here, do whatever you wantto do
    
     [_imgBg setAlpha:0.1];
    
     [_btnPlay setAlpha:1.0];
    
    NSLog(@"stop is clicked!");
    
    if(player != nil){
        [player pause];
        return;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
 [self clickStop];
 
    player = nil;

}

-(void)reset{

      [_imgBg setAlpha:0.1];
    
    [_btnPlay setAlpha:1.0];
    
    NSLog(@"stop is clicked!");
    
    if(player != nil){
        [player pause];
       
    }

    player = nil;

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
