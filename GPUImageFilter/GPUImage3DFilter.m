//
//  GPUImage3DFilter.m
//  GPUImageFilter
//
//  Created by David.Dai on 18/5/30.
//  Copyright © 2018年 David.Dai. All rights reserved.
//

#import "GPUImage3DFilter.h"
@interface GPUImage3DFilter(){
    GLint diffusionRangeUniform, aspectRatioUniform, centerUniform, radiusUniform;
}
@property(readwrite, nonatomic) CGFloat aspectRatio;
@end

NSString *const kGPUImage3DFragmentShaderString = SHADER_STRING
(
 // gl外部传入变量
 uniform sampler2D inputImageTexture;
 uniform highp vec2 imagePixel;
 
 uniform highp float diffusionRange;
 
 uniform highp float aspectRatio;
 uniform lowp vec2 filterCenter;
 uniform highp float filterRadius;
 
 // 顶点着色器输出变量
 varying highp vec2 textureCoordinate;
 
 void main()
{
    // 左右纹理互补法
    lowp vec4 right = texture2D(inputImageTexture, textureCoordinate + imagePixel * diffusionRange);
    lowp vec4 left = texture2D(inputImageTexture, textureCoordinate - imagePixel * diffusionRange);
    lowp vec4 origin = texture2D(inputImageTexture, textureCoordinate);

    // 效果在一个圆内，从圆心计算当前坐标是否在圆心半径内
    highp vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
    highp float dist = distance(filterCenter, textureCoordinateToUse);
    
    if (dist < filterRadius)
    {
        gl_FragColor = vec4(left.r, right.g, right.b, 1.0);
    }
    else
    {
        gl_FragColor = origin.rgba;
    }
}
);

@implementation GPUImage3DFilter

- (instancetype)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImage3DFragmentShaderString])) {
        return nil;
    }
    
    diffusionRangeUniform = [filterProgram uniformIndex:@"diffusionRange"];
    aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
    centerUniform = [filterProgram uniformIndex:@"filterCenter"];
    radiusUniform = [filterProgram uniformIndex:@"filterRadius"];
    
    self.diffusionRange = 5.0f;
    self.center = CGPointMake(0.5f, 0.5f);
    self.radius = 0.5f;
    
    return self;
}

- (void)setDiffusionRange:(CGFloat)diffusionRange {
    _diffusionRange = diffusionRange;
    [self setFloat:_diffusionRange forUniform:diffusionRangeUniform program:filterProgram];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
}

- (void)setCenter:(CGPoint)center
{
    _center = center;
    CGPoint rotatedPoint = [self rotatedPoint:center forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:centerUniform program:filterProgram];
}

- (void)setAspectRatio:(CGFloat)aspectRatio {
    _aspectRatio = aspectRatio;
    [self setFloat:_aspectRatio forUniform:aspectRatioUniform program:filterProgram];
}

#pragma mark - GPUImage回调重写
- (void)setupFilterForSize:(CGSize)filterFrameSize {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        CGSize imagePixel;
        imagePixel.width = 1.0 / filterFrameSize.width;
        imagePixel.height = 1.0 / filterFrameSize.height;
        [self setSize:imagePixel forUniformName:@"imagePixel"];
        
        self.aspectRatio = filterFrameSize.height / filterFrameSize.width;
    });
}
@end
