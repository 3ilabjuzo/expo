#import "ABI46_0_0RNCSafeAreaViewComponentView.h"

#import <react/renderer/components/safeareacontext/EventEmitters.h>
#import <react/renderer/components/safeareacontext/Props.h>
#import <react/renderer/components/safeareacontext/ABI46_0_0RCTComponentViewHelpers.h>
#import <react/renderer/components/safeareacontext/ABI46_0_0RNCSafeAreaViewComponentDescriptor.h>
#import <react/renderer/components/safeareacontext/ABI46_0_0RNCSafeAreaViewShadowNode.h>

#import <ABI46_0_0React/ABI46_0_0RCTConversions.h>
#import <ABI46_0_0React/ABI46_0_0RCTFabricComponentsPlugins.h>

#import "ABI46_0_0RNCSafeAreaProviderComponentView.h"
#import "ABI46_0_0RNCSafeAreaUtils.h"

using namespace ABI46_0_0facebook::react;

@interface ABI46_0_0RNCSafeAreaViewComponentView () <ABI46_0_0RCTRNCSafeAreaViewViewProtocol>
@end

@implementation ABI46_0_0RNCSafeAreaViewComponentView {
  ABI46_0_0RNCSafeAreaViewShadowNode::ConcreteState::Shared _state;
  UIEdgeInsets _currentSafeAreaInsets;
  __weak UIView *_Nullable _providerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const ABI46_0_0RNCSafeAreaViewProps>();
    _props = defaultProps;
  }

  return self;
}

- (NSString *)description
{
  NSString *superDescription = [super description];

  // Cutting the last `>` character.
  if (superDescription.length > 0 && [superDescription characterAtIndex:superDescription.length - 1] == '>') {
    superDescription = [superDescription substringToIndex:superDescription.length - 1];
  }

  return [NSString stringWithFormat:@"%@; ABI46_0_0RNCSafeAreaInsets = %@; appliedRNCSafeAreaInsets = %@>",
                                    superDescription,
                                    NSStringFromUIEdgeInsets(_providerView.safeAreaInsets),
                                    NSStringFromUIEdgeInsets(_currentSafeAreaInsets)];
}

- (void)didMoveToWindow
{
  UIView *previousProviderView = _providerView;
  _providerView = [self findNearestProvider];

  [self updateStateIfNecessary];

  if (previousProviderView != _providerView) {
    [NSNotificationCenter.defaultCenter removeObserver:self name:ABI46_0_0RNCSafeAreaDidChange object:previousProviderView];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(safeAreaProviderInsetsDidChange:)
                                               name:ABI46_0_0RNCSafeAreaDidChange
                                             object:_providerView];
  }
}

- (void)safeAreaProviderInsetsDidChange:(NSNotification *)notification
{
  [self updateStateIfNecessary];
}

- (void)updateStateIfNecessary
{
  if (_providerView == nil) {
    return;
  }
  UIEdgeInsets safeAreaInsets = _providerView.safeAreaInsets;

  if (UIEdgeInsetsEqualToEdgeInsetsWithThreshold(safeAreaInsets, _currentSafeAreaInsets, 1.0 / ABI46_0_0RCTScreenScale())) {
    return;
  }

  _currentSafeAreaInsets = safeAreaInsets;
  [self updateState];
}

- (UIView *)findNearestProvider
{
  UIView *current = self.superview;
  while (current != nil) {
    if ([current isKindOfClass:ABI46_0_0RNCSafeAreaProviderComponentView.class]) {
      return current;
    }
    current = current.superview;
  }
  return self;
}

- (void)updateState
{
  if (!_state) {
    return;
  }

  _state->updateState(
      [=](ABI46_0_0RNCSafeAreaViewShadowNode::ConcreteState::Data const &oldData)
          -> ABI46_0_0RNCSafeAreaViewShadowNode::ConcreteState::SharedData {
        auto newData = oldData;
        newData.insets = ABI46_0_0RCTEdgeInsetsFromUIEdgeInsets(_currentSafeAreaInsets);
        return std::make_shared<ABI46_0_0RNCSafeAreaViewShadowNode::ConcreteState::Data const>(newData);
      });
}

#pragma mark - ABI46_0_0RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<ABI46_0_0RNCSafeAreaViewComponentDescriptor>();
}

- (void)updateState:(State::Shared const &)state oldState:(State::Shared const &)oldState
{
  _state = std::static_pointer_cast<ABI46_0_0RNCSafeAreaViewShadowNode::ConcreteState const>(state);
}

- (void)finalizeUpdates:(ABI46_0_0RNComponentViewUpdateMask)updateMask
{
  [super finalizeUpdates:updateMask];
  [self updateStateIfNecessary];
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];

  [NSNotificationCenter.defaultCenter removeObserver:self];
  _state.reset();
  _providerView = nil;
  _currentSafeAreaInsets = UIEdgeInsetsZero;
}

@end

Class<ABI46_0_0RCTComponentViewProtocol> ABI46_0_0RNCSafeAreaViewCls(void)
{
  return ABI46_0_0RNCSafeAreaViewComponentView.class;
}
