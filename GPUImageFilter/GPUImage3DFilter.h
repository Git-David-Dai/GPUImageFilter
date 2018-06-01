//
//  GPUImage3DFilter.h
//  GPUImageFilter
//
//  Created by David.Dai on 18/5/30.
//  Copyright © 2018年 David.Dai. All rights reserved.
//

#import "GPUImage.h"

@interface GPUImage3DFilter : GPUImageFilter

// effect scope
@property(readwrite, nonatomic) CGFloat diffusionRange;

// filter scope
@property(readwrite, nonatomic) CGPoint center;// [0,1] default[0.5,0.5]
@property(readwrite, nonatomic) CGFloat radius;// [0,1]

@end
