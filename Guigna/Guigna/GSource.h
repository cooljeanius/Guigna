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

@property(strong) NSString *name;
@property(strong) NSMutableArray *categories;
@property(strong) NSMutableArray *items;
@property(readwrite) GState status;
@property(readwrite) GMode mode;
@property(strong) NSString *homepage;
@property(strong) GuignaAgent *agent;
@property(strong) NSString *cmd;

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
