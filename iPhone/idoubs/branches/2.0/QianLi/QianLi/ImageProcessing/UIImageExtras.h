// From cscade on iphonedevbook.com forums
// And Bjorn Sallarp on blog.sallarp.com

@interface UIImage (Extras)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage*)imageByResizing:(CGSize)targetSize;
- (UIImage*)imageByResizingWithScale:(CGFloat)scale;
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;;

@end
