//
//  CS2MutableArray.m
//  P2PTester
//
//  Created by yc on 2022/4/7.
//

#import "CS2MutableArray.h"

@interface CS2MutableArray()

@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation CS2MutableArray

- (instancetype)initCommon {
    self = [super init];
    if (self) {
        NSString *uuid = [NSString stringWithFormat:@"com.p2p.%p", self];
        _syncQueue = dispatch_queue_create([uuid UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init {
    self = [self initCommon];
    if (self) {
        _array = [NSMutableArray array];
    }
    return self;
}

#pragma mark date

-(NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(_syncQueue, ^{
        count = _array.count;
    });
    return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    __block id obj = nil;
    dispatch_sync(_syncQueue, ^{
        if (index < [_array count]) {
            obj = _array[index];
        }
    });
    return obj;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    dispatch_sync(_syncQueue, ^{
        if (anObject && index < [_array count]) {
            [_array insertObject:anObject atIndex:index];
        }
    });
}

- (void)addObject:(id)anObject {
    dispatch_sync(_syncQueue, ^{
        if (anObject) {
            [_array addObject:anObject];
        }
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    dispatch_sync(_syncQueue, ^{
        if (anObject && index < [_array count]) {
            [_array replaceObjectAtIndex:index withObject:anObject];
        }
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_sync(_syncQueue, ^{
        if (index < [_array count]) {
            [_array removeObjectAtIndex:index];
        }
    });
}

- (void)removeAllObjects {
    dispatch_sync(_syncQueue, ^{
        [_array removeAllObjects];
    });
}

@end
