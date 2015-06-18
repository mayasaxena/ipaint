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
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIView *colorsView;
@property (weak, nonatomic) IBOutlet UIView *sizeView;

@property (strong) NSMutableArray *undoStack;

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
    self.saveButton.layer.cornerRadius = self.saveButton.bounds.size.width / 2;
    
    self.undoStack = [[NSMutableArray alloc] init];
    
    for (UIButton *button in self.colorsView.subviews) {
        button.layer.cornerRadius = button.bounds.size.width / 2;
    }
    
    for (UIButton *button in self.sizeView.subviews) {
        button.layer.cornerRadius = button.bounds.size.width / 2;
    }
}

- (IBAction)tappedBrush:(UIButton *)sender {
    if (self.sizeView.hidden) {
        [self showMenuFromButton:self.brushButton withView:self.sizeView];
    } else {
        [self hideMenuFromButton:self.brushButton withView:self.sizeView];
    }
}

- (IBAction)tappedClear:(UIButton *)sender {
    self.mainImage.image = nil;
    [self.undoStack removeAllObjects];
}

- (IBAction)tappedUndo:(UIButton *)sender {
    self.mainImage.image = nil;
    UIImage *undone = [self popOffStack];
    if (undone != nil) {
        self.mainImage.image = undone;
    }
}

- (IBAction)tappedPalette:(UIButton *)sender {

    if (self.colorsView.hidden) {
        [self showMenuFromButton:self.paletteButton withView:self.colorsView];
    } else {
        [self hideMenuFromButton:self.paletteButton withView:self.colorsView];
    }
}

- (IBAction)tappedSave:(UIButton *)sender {
    UIImageWriteToSavedPhotosAlbum(self.mainImage.image,nil,nil,nil);
}


- (void) showMenuFromButton:(UIButton *)originButton withView:(UIView *)view {
    view.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        int yOffset = 0;
        for (UIButton *button in view.subviews) {
            [button setFrame:CGRectMake(button.center.x - button.frame.size.width / 2, yOffset, button.frame.size.width, button.frame.size.height)];
            yOffset += 35;
        }
        
    }];
}

- (void) hideMenuFromButton:(UIButton *)originButton withView:(UIView *)view {
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (UIButton *button in view.subviews) {
                             [button setFrame:CGRectMake(button.center.x - button.frame.size.width / 2, view.bounds.origin.y
                                                         + view.bounds.size.height - 50, button.frame.size.width, button.frame.size.height)];
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

- (IBAction)tappedSize:(UIButton *)sender {
    [self hideMenuFromButton:self.brushButton withView:self.sizeView];
    
    brush = sender.tag;
}


#pragma mark - Drawing Functions


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    
    lastPoint = currentPoint;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
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
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self pushOntoStack:self.mainImage.image];
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}

- (void) pushOntoStack:(UIImage *)image {
    if ([self.undoStack count] >= 10) {
        [self.undoStack removeObjectAtIndex:0];
    }
    [self.undoStack addObject:image];
    
}

- (UIImage *) popOffStack {
    if ([self.undoStack count] > 0) {
        [self.undoStack removeLastObject];
        return [self.undoStack lastObject];
    }
    return nil;
}



@end
