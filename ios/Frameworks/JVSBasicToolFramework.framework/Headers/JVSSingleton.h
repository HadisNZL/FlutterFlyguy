//
//  JVSSingleton.h
//  JVSUserAccountComponents
//
//  Created by 李华 on 2024/9/19.
//

#ifndef JVSSingleton_h
#define JVSSingleton_h

#define JVS_SINGLETON_DEFINE() + (instancetype)sharedInstance; \
+(instancetype) alloc __attribute__((unavailable("call sharedInstance instead"))); \
+(instancetype) new __attribute__((unavailable("call sharedInstance instead"))); \
-(instancetype) copy __attribute__((unavailable("call sharedInstance instead"))); \
-(instancetype) mutableCopy __attribute__((unavailable("call sharedInstance instead")));


#define JVS_SINGLETON_IMP(_typeClass_) + (instancetype)sharedInstance{ \
static _typeClass_ * sharedInstance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
sharedInstance = [[self alloc] init]; \
}); \
return sharedInstance; \
}

#endif /* JVSSingleton_h */
