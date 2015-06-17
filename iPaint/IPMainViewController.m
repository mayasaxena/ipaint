//
//  IPMainViewController.m
//  iPaint
//
//  Created by Maya Saxena on 6/17/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import "IPMainViewController.h"

@interface IPMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *paletteButton;
@property (weak, nonatomic) IBOutlet UIButton *brushButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

@end

@implementation IPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.paletteButton.layer.cornerRadius = self.paletteButton.bounds.size.width / 2;
    self.brushButton.layer.cornerRadius = self.brushButton.bounds.size.width / 2;
    self.undoButton.layer.cornerRadius = self.undoButton.bounds.size.width / 2;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
