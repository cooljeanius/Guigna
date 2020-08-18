#import <Foundation/Foundation.h>

@class GItem;
@class GuignaAgent;

typedef enum _GState {
    GOffState = 0,
    GOnState,
    GHiddenState
} GState;

typedef enum _GMode {
    GOfflineMode = 0,
    GOnlineMode
} GMode;

@interface GSource : NSObject

@property(strong, atomic) NSString *name;
@property(strong, atomic) NSMutableArray *categories;
@property(strong, atomic) NSMutableArray *items;
@property(readwrite, atomic) GState status;
@property(readwrite, atomic) GMode mode;
@property(strong, atomic) NSString *homepage;
@property(strong, atomic) GuignaAgent *agent;
@property(strong, atomic) NSString *cmd;

- (id)initWithName:(NSString *)name agent:(GuignaAgent *)agent;
- (id)initWithName:(NSString *)name;
- (id)initWithAgent:(GuignaAgent *)agent;


- (NSString *)info:(GItem *)item;
- (NSString *)home:(GItem *)item;
- (NSString *)log:(GItem *)item;
- (NSString *)contents:(GItem *)item;
- (NSString *)cat:(GItem *)item;
- (NSString *)deps:(GItem *)item;
- (NSString *)dependents:(GItem *)item;

@end
