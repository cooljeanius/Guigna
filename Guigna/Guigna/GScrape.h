#import "GSource.h"
#import "GItem.h"

#import "GuignaAgent.h"

@interface GScrape : GSource

@property(readwrite) NSInteger pageNumber;
@property(readwrite) NSInteger itemsPerPage;

- (id)initWithAgent:(GuignaAgent *)agent;
@end
