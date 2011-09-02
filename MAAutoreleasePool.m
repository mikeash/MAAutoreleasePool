#import "MAAutoreleasePool.h"

#import <objc/runtime.h>


@implementation MAAutoreleasePool : NSObject

+ (CFMutableArrayRef)_threadPoolStack
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    
    NSString *key = @"MAAutoreleasePool thread-local pool stack";
    
    CFMutableArrayRef array = (CFMutableArrayRef)[threadDictionary objectForKey: key];
    if(!array)
    {
        array = CFArrayCreateMutable(NULL, 0, NULL);
        [threadDictionary setObject: (id)array forKey: key];
        CFRelease(array);
    }
    return array;
}

+ (void)addObject: (id)object
{
    CFArrayRef stack = [self _threadPoolStack];
    CFIndex count = CFArrayGetCount(stack);
    if(count == 0)
    {
        fprintf(stderr, "Object of class %s autoreleased with no pool, leaking\n", class_getName(object_getClass(object)));
    }
    else
    {
        MAAutoreleasePool *pool = (id)CFArrayGetValueAtIndex(stack, count - 1);
        [pool addObject: object];
    }
}

- (id)init
{
    if((self = [super init]))
    {
        _objects = CFArrayCreateMutable(NULL, 0, NULL);
        CFArrayAppendValue([[self class] _threadPoolStack], self);
    }
    return self;
}

- (void)dealloc
{
    if(_objects)
    {
        for(id object in (id)_objects)
            [object release];
        CFRelease(_objects);
    }
    
    CFMutableArrayRef stack = [[self class] _threadPoolStack];
    CFIndex index = CFArrayGetCount(stack);
    while(index-- > 0)
    {
        MAAutoreleasePool *pool = (id)CFArrayGetValueAtIndex(stack, index);
        if(pool == self)
        {
            CFArrayRemoveValueAtIndex(stack, index);
            break;
        }
        else
        {
            [pool release];
        }
    }
    
    [super dealloc];
}

- (void)addObject: (id)object
{
    CFArrayAppendValue(_objects, object);
}

@end


@implementation NSObject (MAAutoreleasePool)

- (id)ma_autorelease
{
    [MAAutoreleasePool addObject: self];
    return self;
}

@end
