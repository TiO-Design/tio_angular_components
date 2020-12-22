import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/laminate/overlay/constants.dart';
import 'package:angular_components/utils/browser/events/events.dart' as events;

/// Tracks a hierarchy of visible popup and provides it closing logic.
@Injectable()
class TioPopupHierarchy {
  final _visiblePopupStack = <TioPopupHierarchyElement>[];

  /// Parent pane of the first popup hierarchy element.
  Element _rootPane;

  StreamSubscription _triggerListener;
  StreamSubscription _keyUpListener;

  Event _lastTriggerEvent;

  /// Whether last trigger event is a keyboard event or focus event.
  bool get islastTriggerWithKeyboard =>
      _lastTriggerEvent is KeyboardEvent || _lastTriggerEvent is FocusEvent;

  /// Closes every popup element present in the hierarchy.
  void closeHierarchy() {
    for (var popup in _visiblePopupStack) {
      popup.handleDismissed();
    }

    _visiblePopupStack.clear();
    _disposeListeners();
  }

  void _attach(TioPopupHierarchyElement child) {
    assert(child != null);
    if (_visiblePopupStack.isEmpty) {
      _rootPane = child.container;
    }
    _visiblePopupStack.add(child);

    _triggerListener ??= events.triggersOutside(null).listen(_onTrigger);
    _keyUpListener ??= document.onKeyUp.listen(_onKeyUp);
  }

  void _disposeListeners() {
    _triggerListener.cancel();
    _keyUpListener.cancel();
    _triggerListener = null;
    _keyUpListener = null;
  }

  void _detach(TioPopupHierarchyElement child) {
    if (_visiblePopupStack.remove(child) && _visiblePopupStack.isEmpty) {
      _rootPane = null;
      _disposeListeners();
    }
  }

  bool _isInHiddenModal() {
    // Find parent pane if any, done dynamically as the modal pane can be
    // created by another app using ACX.
    // TODO(google): Find a way to compute it only when needed and make it
    // globally accessible.
    var modalPanes = document
        .querySelectorAll('.$overlayContainerClassName .pane.modal.visible');
    if (modalPanes.isNotEmpty) {
      // Only close popups that belong to the currently visible modal or whose
      // modal is no longer visible. Note that since the modal may already
      // have closed prior to this event being processed, it's possible in
      // some situations that the popups of the level below will be closed as
      // well.
      if (_rootPane == null ||
          (_rootPane != modalPanes.last && modalPanes.contains(_rootPane))) {
        return true;
      }
    }
    return false;
  }

  void _onTrigger(Event event) {
    // Some weird event, ignore it.
    if (event?.target == null) return;

    _lastTriggerEvent = event;

    if (_isInHiddenModal()) return;

    for (var i = _visiblePopupStack.length - 1; i >= 0; i--) {
      final current = _visiblePopupStack[i];
      if (current?.container == null) continue;

      if (events.isParentOf(current.container, event.target as Node)) return;

      for (var blockerElement in current.autoDismissBlockers) {
        if (events.isParentOf(blockerElement, event.target as Node)) return;
      }

      if (current.autoDismiss) current.handleAutoDismissed(event);
    }
  }

  void _onKeyUp(KeyboardEvent event) {
    // Some weird event, ignore it.
    if (event?.target == null) return;

    _lastTriggerEvent = event;

    if (_isInHiddenModal()) return;

    if (event.keyCode == KeyCode.ESC) {
      // Dismiss the top most popup
      final current = _visiblePopupStack.last;
      if (current?.container != null) {
        event.stopPropagation();
        current.handleDismissed();
      }
    }
  }
}

/// An electable element for the [TioPopupHierarchy].
abstract class TioPopupHierarchyElement {
  TioPopupHierarchy get hierarchy;

  bool get autoDismiss;

  /// The html element corresponding to the popup.
  /// Usually the pane created by the overlay service.
  Element get container;

  /// The outer element which should prevent the auto dismiss logic.
  List<Element> get autoDismissBlockers;

  /// Attach this element to the hierarchy.
  ///
  /// This should only be done when the element is getting visibility.
  void attachToVisibleHierarchy() => hierarchy._attach(this);

  void detachFromVisibleHierarchy() => hierarchy._detach(this);

  /// Gets called when the user clicks outside of the component.
  void handleAutoDismissed(Event event) => handleDismissed();

  /// Gets called when the popup gets dismissed.
  /// Could be due to the user pressing ESC
  /// or clicking outside of the component.
  void handleDismissed();
}
