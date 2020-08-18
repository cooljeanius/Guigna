#import "GSource.h"
#import "GItem.h"

#import "GuignaAgent.h"

@interface GScrape : GSource

@property(readwrite, atomic) NSInteger pageNumber;
@property(readwrite, atomic) NSInteger itemsPerPage;

- (id)initWithAgent:(GuignaAgent *)agent;
@end
