#import <Foundation/Foundation.h>

@interface NSData (SHA)
- (NSData *_Nonnull)jwt_shaDigestWithSize:(NSInteger)functionSize;
@end
