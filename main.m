// gcc -framework Foundation -W -Wall -Wno-unused-parameter main.m MAAutoreleasePool.m

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "MAAutoreleasePool.h"


@interface Test : NSObject
{
}
@end

@implementation Test

- (void)dealloc
{
    fprintf(stderr, "Test object %p being destroyed\n", self);
    [super dealloc];
}

@end


static id AllocateMAAutoreleasePool(id self, SEL _cmd, NSZone *zone)
{
    return [MAAutoreleasePool alloc];
}

int main(int argc, char **argv)
{
    SEL allocWithZoneSEL = @selector(allocWithZone:);
    Method allocWithZoneM = class_getClassMethod([NSAutoreleasePool class], allocWithZoneSEL);
    class_replaceMethod(object_getClass([NSAutoreleasePool class]), allocWithZoneSEL, (IMP)AllocateMAAutoreleasePool, method_getTypeEncoding(allocWithZoneM));
    
    SEL autoreleaseSEL = @selector(autorelease);
    Method autoreleaseM = class_getInstanceMethod([NSObject class], autoreleaseSEL);
    class_replaceMethod([NSObject class], autoreleaseSEL, [NSObject instanceMethodForSelector: @selector(ma_autorelease)], method_getTypeEncoding(autoreleaseM));
    
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSMutableArray *a = [NSMutableArray array];
    [a addObject: [[[Test alloc] init] autorelease]];
    
    [pool release];
    
    return 0;
}
