//
//  IPMainViewController.m
//  iPaint
//
//  Created by Maya Saxena on 6/17/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import "IPMainViewController.h"

CGPoint lastPoint;
CGFloat red;
CGFloat green;
CGFloat blue;
CGFloat brush;
CGFloat opacity;
BOOL mouseSwiped;

@interface IPMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *paletteButton;
@property (weak, nonatomic) IBOutlet UIButton *brushButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIView *colorsView;

@property CGMutablePathRef currentPaths;
@property NSMutableArray *points;

@end


@implementation IPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    
    self.paletteButton.layer.cornerRadius = self.paletteButton.bounds.size.width / 2;
    self.brushButton.layer.cornerRadius = self.brushButton.bounds.size.width / 2;
    self.undoButton.layer.cornerRadius = self.undoButton.bounds.size.width / 2;
    self.clearButton.layer.cornerRadius = self.clearButton.bounds.size.width / 2;
    self.currentPaths = CGPathCreateMutable();
    self.points = [[NSMutableArray alloc] init];
    
    
    
    for (UIButton *button in self.colorsView.subviews) {
        button.layer.cornerRadius = button.bounds.size.width / 2;
    }
}


- (IBAction)tappedClear:(id)sender {
    self.mainImage.image = nil;
}

- (IBAction)tappedPalette:(UIButton *)sender {

    if (self.colorsView.hidden) {
        [self showMenuFromButton:self.paletteButton withView:self.colorsView];
    } else {
        [self hideMenuFromButton:self.paletteButton withView:self.colorsView];
    }
}


- (void) showMenuFromButton:(UIButton *)originButton withView:(UIView *)view {
    view.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        int yOffset = 0;
        for (UIButton *button in view.subviews) {
            [button setFrame:CGRectMake(originButton.frame.origin.x - 5, yOffset, 30, 30)];
            yOffset += 35;
        }
        
    }];
}

- (void) hideMenuFromButton:(UIButton *)originButton withView:(UIView *)view {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (UIButton *button in view.subviews) {
                             [button setFrame:CGRectMake(originButton.frame.origin.x - 5, view.bounds.origin.y
                                                         + view.bounds.size.height - 50, 30, 30)];
                         }
                     } completion:^(BOOL finished) {
                         view.hidden = YES;
                     }];
}



- (IBAction)tappedColor:(UIButton *)sender {
    [self hideMenuFromButton:self.paletteButton withView:self.colorsView];
    const CGFloat* colors = CGColorGetComponents(sender.backgroundColor.CGColor);
    red = colors[0];
    green = colors[1];
    blue = colors[2];
    if (colors[0] == colors[1]  && colors[1] == colors[2]) {
        self.paletteButton.backgroundColor = self.brushButton.backgroundColor;
    } else {
        self.paletteButton.backgroundColor = sender.backgroundColor;
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
    [self.points addObject:[NSValue valueWithCGPoint:lastPoint]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    [self.points addObject:[NSValue valueWithCGPoint:lastPoint]];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGPathAddPath(self.currentPaths, NULL, CGContextCopyPath(UIGraphicsGetCurrentContext()));
//    NSLog(@"%@",self.currentPaths);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    
    lastPoint = currentPoint;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPathAddLines(self.currentPaths, NULL, [self getCGPointArrayFromNSMutableArray], [self.points count]);
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}

- (const CGPoint *) getCGPointArrayFromNSMutableArray {
    CGPoint *points = (CGPoint *)calloc([self.points count], sizeof(CGPoint));
    
    for (int i = 0; i < [self.points count]; i++) {
        points[i] = [self.points[i] CGPointValue];
    }
    
    return points;
}

@end
