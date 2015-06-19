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
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIImageView *bufferImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIView *colorsView;
@property (weak, nonatomic) IBOutlet UIView *sizeView;


//Brush variables
@property CGPoint lastPoint;
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property CGFloat brushSize;
@property CGFloat opacity;
@property BOOL mouseSwiped;

@property (strong) NSMutableArray *undoStack;

@end


@implementation IPMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBrushVariables];
    
    self.undoStack = [[NSMutableArray alloc] init];
    
    [self configureButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (void)configureBrushVariables {
    self.red = 0.0;
    self.green = 0.0;
    self.blue = 0.0;
    self.brushSize = 10.0;
    self.opacity = 1.0;
}

- (void)configureButtons {
    
    self.paletteButton.layer.cornerRadius = CGRectGetWidth(self.paletteButton.bounds) / 2;
    self.brushButton.layer.cornerRadius = CGRectGetWidth(self.brushButton.bounds) / 2;
    self.undoButton.layer.cornerRadius = CGRectGetWidth(self.undoButton.bounds) / 2;
    self.clearButton.layer.cornerRadius = CGRectGetWidth(self.clearButton.bounds) / 2;
    self.saveButton.layer.cornerRadius = CGRectGetWidth(self.saveButton.bounds) / 2;
    
    
    for (UIButton *colorButton in self.colorsView.subviews) {
        colorButton.layer.cornerRadius = CGRectGetWidth(colorButton.bounds) / 2;
    }
    
    for (UIButton *sizeButton in self.sizeView.subviews) {
        sizeButton.layer.cornerRadius = CGRectGetWidth(sizeButton.bounds) / 2;
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
    self.mainImageView.image = nil;
    [self.undoStack removeAllObjects];
}

- (IBAction)tappedUndo:(UIButton *)sender {
    self.mainImageView.image = nil;
    UIImage *undone = [self popOffStack];
    if (undone != nil) {
        self.mainImageView.image = undone;
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
    UIImageWriteToSavedPhotosAlbum(self.mainImageView.image,nil,nil,nil);
}


- (void) showMenuFromButton:(UIButton *)originButton withView:(UIView *)view {
    view.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        int yOffset = 0;
        for (UIButton *button in view.subviews) {
            button.frame = CGRectMake(button.center.x - CGRectGetWidth(button.frame) / 2,
                                      yOffset, CGRectGetWidth(button.frame),
                                      CGRectGetHeight(button.frame));
            yOffset += 35;
        }
        
    }];
}

- (void) hideMenuFromButton:(UIButton *)originButton withView:(UIView *)view {
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (UIButton *button in view.subviews) {
                             [button setFrame:CGRectMake(button.center.x - CGRectGetWidth(button.frame) / 2,
                                                         CGRectGetMinY(view.bounds) + CGRectGetHeight(view.bounds) - 50,
                                                         CGRectGetWidth(button.frame),
                                                         CGRectGetHeight(button.frame))];
                         }
                     } completion:^(BOOL finished) {
                         view.hidden = YES;
                     }];
}



- (IBAction)tappedColor:(UIButton *)sender {
    [self hideMenuFromButton:self.paletteButton withView:self.colorsView];
    const CGFloat* colors = CGColorGetComponents(sender.backgroundColor.CGColor);
    self.red = colors[0];
    self.green = colors[1];
    self.blue = colors[2];
    if (colors[0] == colors[1]  && colors[1] == colors[2]) {
        self.paletteButton.backgroundColor = self.brushButton.backgroundColor;
    } else {
        self.paletteButton.backgroundColor = sender.backgroundColor;
    }

}

- (IBAction)tappedSize:(UIButton *)sender {
    [self hideMenuFromButton:self.brushButton withView:self.sizeView];
    
    self.brushSize = sender.tag;
}


#pragma mark - Drawing Functions


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    self.mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    self.lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    self.mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    [self.bufferImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brushSize );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.bufferImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.bufferImageView setAlpha:self.opacity];
    UIGraphicsEndImageContext();
    
    
    self.lastPoint = currentPoint;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!self.mouseSwiped) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
        [self.bufferImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brushSize);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, self.opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.bufferImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    [self.mainImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.bufferImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.opacity];
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self pushOntoStack:self.mainImageView.image];
    self.bufferImageView.image = nil;
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
