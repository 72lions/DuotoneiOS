//
//  ViewController.m
//  Duotone
//
//  Created by Thodoris Tsiridis on 17/07/15.
//  Copyright © 2015 72lions. All rights reserved.
//

#import "ViewController.h"
#import "STLDuotoneConverter.h"

@interface ViewController () <STLDuotoneConverterDelegate>
@property (nonatomic, strong) UIImageView *imageViewOriginal;
@property (nonatomic, strong) UIImageView *imageViewConverted;
@property (nonatomic, strong) STLDuotoneConverter *duotoneConverter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *imageOriginal = [UIImage imageNamed:@"Rihanna"];
    self.imageViewOriginal = [[UIImageView alloc] initWithImage:imageOriginal];
    self.imageViewOriginal.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageViewOriginal.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewOriginal.clipsToBounds = YES;
    [self.view addSubview:self.imageViewOriginal];

    self.imageViewConverted = [[UIImageView alloc] init];
    self.imageViewConverted.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageViewConverted.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewConverted.clipsToBounds = YES;
    self.imageViewConverted.alpha = 0;
    self.imageViewConverted.hidden = YES;
    [self.view addSubview:self.imageViewConverted];

    UIColor *highlightsColor = [UIColor colorWithRed:(240.f / 255.f) green:(14.f / 255.f) blue:(46.f / 255.f) alpha:1.f];
    UIColor *shadowsColor = [UIColor colorWithRed:(25.f / 255.f) green:(37.f / 255.f) blue:(80.f / 255.f) alpha:1.f];

    self.duotoneConverter = [[STLDuotoneConverter alloc] init];
    self.duotoneConverter.delegate = self;
    [self.duotoneConverter convertImage:imageOriginal withHighlightColor:highlightsColor shadowColor:shadowsColor contrast:0.5f];
}

- (void)viewWillLayoutSubviews
{
    self.imageViewOriginal.frame = self.view.bounds;
    self.imageViewConverted.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - STLDuotoneConverterDelegate

- (void)duotoneConverter:(STLDuotoneConverter *)duotoneConverter didFinishConvertingImage:(UIImage *)image
{

    self.imageViewConverted.image = image;
    self.imageViewConverted.hidden = NO;

    __weak ViewController *weakSelf = self;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         ViewController *strongSelf = weakSelf;
                         strongSelf.imageViewConverted.alpha = 1;
                     }];
}

- (void)duotoneConverterDidFailToConvertImage:(STLDuotoneConverter *)duotoneConverter
{
    
}

@end
