#import <Foundation/Foundation.h>



@interface NSMutableDictionary (Extension)

- (void)removeKeys:(NSArray *)keys;

@end


@interface NSDictionary (GetValue)
/**
 *  字符串转化
 *
 *  @param newKey NSString
 *
 *  @return NSString
 */
- (NSString *)getStringForKey:(NSString *)newKey;
/**
 *  Integer转化
 *
 *  @param newKey NSString
 *
 *  @return NSInteger
 */
- (NSInteger)getIntegerForKey:(NSString *)newKey;
/**
 *  NSNumber转化
 *
 *  @param newKey NSString
 *
 *  @return NSNumber
 */
- (NSNumber *)getCurrencyForKey:(NSString *)newKey;
- (BOOL)safeDictContainsObject:(NSString *)key;
- (BOOL)safeDictContainsObject:(NSString *)key classType:(Class)classType;

- (id)safeObjectFromKey:(NSString *)key classType:(Class)classType;
- (id)safeObjectFromKey:(NSString *)key classTypeArr:(NSArray <Class>*)classTypeArr;
- (id)safeObjectFromKey:(NSString *)key;


/**
 @brief 字典数据中是否 包含key的数据
 
 @param key key
 */
-(BOOL)containsObjectForKey:(id)key;

@end
