//
//  ViewController.m
//  WRFileDownLoad
//
//  Created by zjsruxxxy3 on 15/4/19.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import "ViewController.h"
#import "WRFileDownLoadTool.h"

@import MediaPlayer;

@interface ViewController ()<UITextFieldDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *fileButton;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputField;


@property (strong, nonatomic) IBOutlet UIProgressView *processe;

@property(nonatomic,strong)WRFileDownLoadTool *fileDownLoadTool;

@property(nonatomic,strong)NSString *downLoadedFile;


- (IBAction)FileHandle:(id)sender;

- (IBAction)CancelDownLoad:(id)sender;

- (IBAction)openFile:(UIButton *)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.processe.progress = 0;
    
    self.percentLabel.text = @"0.0%";
    
    self.inputField.delegate= self;
    
    self.fileButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textLengthChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

-(void)textLengthChange:(NSNotification *)notification
{
//    UITextField *text
    
    self.fileButton.enabled = !(self.inputField.text.length == 0);
    
    
}

-(WRFileDownLoadTool *)fileDownLoadTool
{
    if (_fileDownLoadTool == nil)
    {
        
        _fileDownLoadTool = [WRFileDownLoadTool fileDownLoadWithWebPath:@"http://192.168.191.2/school/2014WWDC/" FileName:self.downLoadedFile];

        __weak typeof(self) weak_self = self;
        
        _fileDownLoadTool.handleProgress =^(double progress,BOOL success)
        {
            weak_self.processe.progress = progress;
            
            weak_self.percentLabel.text = [NSString stringWithFormat:@"%.1f%%",progress*100];
            NSLog(@"%f",progress);
            
        };
        
        _fileDownLoadTool.handleCompletion = ^(){
            
            [weak_self.fileButton setTitle:@"FileHandle" forState:UIControlStateNormal];
            
        };

        
    }
    
    return _fileDownLoadTool;
    
}

- (IBAction)FileHandle:(id)sender
{

    if (!self.fileDownLoadTool.isDownLoad)
    {
        [self.fileButton setTitle:@"pasue" forState:UIControlStateNormal];

        [self.fileDownLoadTool startDonwLoadWithHanle:nil];
        
    }else
    {
        [self.fileButton setTitle:@"download" forState:UIControlStateNormal];

        [self.fileDownLoadTool pauseDonwLoadWithHanle:nil];
        
    }

}

-(void)CancelDownLoad:(id)sender
{
    if (self.fileDownLoadTool.isDownLoad)
    {
        NSLog(@"can't deleted");

    }else
    {
        [self.fileDownLoadTool cancelDonwLoadWithHanle:^{
            self.percentLabel.text = @"0.0%";
            self.processe.progress = 0.0;
            NSLog(@"deleted");
            
        }];
        
    }


}

- (IBAction)openFile:(UIButton *)sender
{
    
    NSString *cachePath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *destinationFilePath = [cachePath stringByAppendingPathComponent:self.downLoadedFile];
    
    if ([destinationFilePath hasSuffix:@"mov"])
    {
        NSURL *movURL = [[NSURL alloc]initFileURLWithPath:destinationFilePath];
        
        MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:movURL];
        
        [self presentViewController:playerViewController animated:YES completion:^{

            NSLog(@"playVideo");
            
        }];
        
    }
    
}

#pragma mark -textFieldDelegate
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

    self.downLoadedFile = textField.text;
    
    NSLog(@"%@",self.downLoadedFile);
    
    [self FileHandle:nil];

    return YES;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.downLoadedFile = textField.text;
    
    NSLog(@"%@",self.downLoadedFile);
    
    
}

@end
