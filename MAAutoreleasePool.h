
#import <Foundation/Foundation.h>


@interface MAAutoreleasePool : NSObject
{
    CFMutableArrayRef _objects;
}

+ (void)addObject: (id)object;

- (void)addObject: (id)object;

@end

@interface NSObject (MAAutoreleasePool)

- (id)ma_autorelease;

@end
