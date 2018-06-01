//
//  ViewController.m
//  GPUImageFilter
//
//  Created by David.Dai on 18/5/30.
//  Copyright © 2018年 David.Dai. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage3DFilter.h"
#import "GPUImage.h"

@interface ViewController ()

@property (nonatomic, strong) GPUImageView *filteredVideoView;
@property (nonatomic, strong) GPUImageVideoCamera *camera;
@property (nonatomic, strong) GPUImage3DFilter *filter;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.filteredVideoView];
    [self.view addSubview:self.slider];
    
    [self.camera addTarget:self.filter];
    [self.filter addTarget:self.filteredVideoView];
    [self.camera startCameraCapture];
}

- (void)didSliderValueChange:(UISlider *)slider {
    self.filter.radius = slider.value;
}

- (GPUImageView *)filteredVideoView {
    if(!_filteredVideoView) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width , screenSize.height)];
    }
    return _filteredVideoView;
}

- (GPUImageVideoCamera *)camera {
    if(!_camera) {
        _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    return _camera;
}

- (GPUImage3DFilter *)filter {
    if(!_filter) {
        _filter = [[GPUImage3DFilter alloc]init];
    }
    return _filter;
}

- (UISlider *)slider {
    if(!_slider) {
        _slider = [[UISlider alloc]initWithFrame:CGRectMake(25, 500, 320, 30)];
        _slider.value = self.filter.radius;
        _slider.minimumValue = 0.0f;
        _slider.maximumValue = 1.0f;
        [_slider addTarget:self action:@selector(didSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

@end
