#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

@implementation XMPPMessageBaseNode (ContextHelpers)

- (XMPPMessageContextNode *)appendContextNodeWithStreamEventID:(NSString *)streamEventID
{
    NSAssert(self.managedObjectContext, @"Attempted to append a context node to a message node not associated with any managed object context");
    
    XMPPMessageContextNode *insertedNode = [XMPPMessageContextNode xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedNode.streamEventID = streamEventID;
    insertedNode.messageNode = self;
    return insertedNode;
}

@end

@implementation XMPPMessageContextNode (ContextHelpers)

- (XMPPMessageContextJIDItem *)appendJIDItemWithTag:(XMPPMessageContextJIDItemTag)tag value:(XMPPJID *)value
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextJIDItem *insertedItem = [XMPPMessageContextJIDItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.value = value;
    insertedItem.contextNode = self;
    return insertedItem;
}

- (XMPPMessageContextMarkerItem *)appendMarkerItemWithTag:(XMPPMessageContextMarkerItemTag)tag
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextMarkerItem *insertedItem = [XMPPMessageContextMarkerItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.contextNode = self;
    return insertedItem;
}

- (XMPPMessageContextStringItem *)appendStringItemWithTag:(XMPPMessageContextStringItemTag)tag value:(NSString *)value
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextStringItem *insertedItem = [XMPPMessageContextStringItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.value = value;
    insertedItem.contextNode = self;
    return insertedItem;
}

- (XMPPMessageContextTimestampItem *)appendTimestampItemWithTag:(XMPPMessageContextTimestampItemTag)tag value:(NSDate *)value
{
    NSAssert(self.managedObjectContext, @"Attempted to append an item to a context node not associated with any managed object context");
    
    XMPPMessageContextTimestampItem *insertedItem = [XMPPMessageContextTimestampItem xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    insertedItem.tag = tag;
    insertedItem.value = value;
    insertedItem.contextNode = self;
    return insertedItem;
}

- (void)removeJIDItemsWithTag:(XMPPMessageContextJIDItemTag)tag
{
    NSAssert(self.managedObjectContext, @"Attempted to remove an item from a context node not associated with any managed object context");
    
    for (XMPPMessageContextJIDItem *jidItem in [self jidItemsForTag:tag expectingSingleElement:NO]) {
        [self removeJidItemsObject:jidItem];
        [self.managedObjectContext deleteObject:jidItem];
    }
}

- (void)removeMarkerItemsWithTag:(XMPPMessageContextMarkerItemTag)tag
{
    NSAssert(self.managedObjectContext, @"Attempted to remove an item from a context node not associated with any managed object context");
    
    for (XMPPMessageContextMarkerItem *markerItem in [self markerItemsForTag:tag expectingSingleElement:NO]) {
        [self removeMarkerItemsObject:markerItem];
        [self.managedObjectContext deleteObject:markerItem];
    }
}

- (void)removeStringItemsWithTag:(XMPPMessageContextStringItemTag)tag
{
    NSAssert(self.managedObjectContext, @"Attempted to remove an item from a context node not associated with any managed object context");
    
    for (XMPPMessageContextStringItem *stringItem in [self stringItemsForTag:tag expectingSingleElement:NO]) {
        [self removeStringItemsObject:stringItem];
        [self.managedObjectContext deleteObject:stringItem];
    }
}

- (void)removeTimestampItemsWithTag:(XMPPMessageContextTimestampItemTag)tag
{
    NSAssert(self.managedObjectContext, @"Attempted to remove an item from a context node not associated with any managed object context");
    
    for (XMPPMessageContextTimestampItem *timestampItem in [self timestampItemsForTag:tag expectingSingleElement:NO]) {
        [self removeTimestampItemsObject:timestampItem];
        [self.managedObjectContext deleteObject:timestampItem];
    }
}

- (NSSet<XMPPMessageContextJIDItem *> *)jidItemsForTag:(XMPPMessageContextJIDItemTag)tag expectingSingleElement:(BOOL)isSingleElementExpected
{
    NSSet *filteredSet = [self.jidItems objectsPassingTest:^BOOL(XMPPMessageContextJIDItem * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL matchesTag = [obj.tag isEqualToString:tag];
#ifdef NS_BLOCK_ASSERTIONS
        if (matchesTag && isSingleElementExpected) {
            *stop = YES;
        }
#endif
        return matchesTag;
    }];
    NSAssert(!(isSingleElementExpected && filteredSet.count > 1) , @"Only one item expected");
    return filteredSet;
}

- (NSSet<XMPPMessageContextMarkerItem *> *)markerItemsForTag:(XMPPMessageContextMarkerItemTag)tag expectingSingleElement:(BOOL)isSingleElementExpected
{
    NSSet *filteredSet = [self.markerItems objectsPassingTest:^BOOL(XMPPMessageContextMarkerItem * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL matchesTag = [obj.tag isEqualToString:tag];
#ifdef NS_BLOCK_ASSERTIONS
        if (matchesTag && isSingleElementExpected) {
            *stop = YES;
        }
#endif
        return matchesTag;
    }];
    NSAssert(!(isSingleElementExpected && filteredSet.count > 1) , @"Only one item expected");
    return filteredSet;
}

- (NSSet<XMPPMessageContextStringItem *> *)stringItemsForTag:(XMPPMessageContextStringItemTag)tag expectingSingleElement:(BOOL)isSingleElementExpected
{
    NSSet *filteredSet = [self.stringItems objectsPassingTest:^BOOL(XMPPMessageContextStringItem * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL matchesTag = [obj.tag isEqualToString:tag];
#ifdef NS_BLOCK_ASSERTIONS
        if (matchesTag && isSingleElementExpected) {
            *stop = YES;
        }
#endif
        return matchesTag;
    }];
    NSAssert(!(isSingleElementExpected && filteredSet.count > 1) , @"Only one item expected");
    return filteredSet;
}

- (NSSet<XMPPMessageContextTimestampItem *> *)timestampItemsForTag:(XMPPMessageContextTimestampItemTag)tag expectingSingleElement:(BOOL)isSingleElementExpected
{
    NSSet *filteredSet = [self.timestampItems objectsPassingTest:^BOOL(XMPPMessageContextTimestampItem * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL matchesTag = [obj.tag isEqualToString:tag];
#ifdef NS_BLOCK_ASSERTIONS
        if (matchesTag && isSingleElementExpected) {
            *stop = YES;
        }
#endif
        return matchesTag;
    }];
    NSAssert(!(isSingleElementExpected && filteredSet.count > 1) , @"Only one item expected");
    return filteredSet;
}

@end
