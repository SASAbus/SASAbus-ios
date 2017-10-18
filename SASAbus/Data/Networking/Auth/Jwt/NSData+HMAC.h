#import <Foundation/Foundation.h>

@interface NSData (HMAC)
- (NSData *_Nonnull)jwt_hmacSignatureWithSHAHashFuctionSize:(NSInteger)functionSize secret:(NSData *_Nonnull)secret;
@end
