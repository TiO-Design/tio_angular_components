import 'dart:async';
import 'dart:html';

import 'package:angular_components/utils/browser/events/events.dart' as events;

class TioPopupHierarchy {
  final _visiblePopupsStack = List<TioPopupHierarchyElement>();

  StreamSubscription _triggerListener;
  StreamSubscription _keyUpListener;

  void _attach(TioPopupHierarchyElement child) {
    assert(child != null);
    _visiblePopupsStack.add(child);

    if (_triggerListener == null) {
      _triggerListener = events.triggersOutside(null).listen(_onTrigger);
    }

    if (_keyUpListener == null) {
      _keyUpListener = document.onKeyUp.listen(_onKeyUp);
    }
  }

  void _detach(TioPopupHierarchyElement child) {
    if (_visiblePopupsStack.remove(child) && _visiblePopupsStack.isEmpty) {
      _disposeListeners();
    }
  }

  void _disposeListeners() {
    _triggerListener.cancel();
    _keyUpListener.cancel();
    _triggerListener = null;
    _keyUpListener = null;
  }

  void _onTrigger(Event event) {
    for (int i = _visiblePopupsStack.length - 1; i >= 0; i--) {
      final current = _visiblePopupsStack[i];
      if (events.isParentOf(current.popupElement, event.target)) return;

      if (current.shouldAutoDismiss) current.onAutoDismiss(event);
    }
  }

  void _onKeyUp(KeyboardEvent event) {
    if (event.keyCode == KeyCode.ESC) {
      for (int i = _visiblePopupsStack.length - 1; i >= 0; i--) {
        final current = _visiblePopupsStack[i];

        if (events.isParentOf(current.popupElement, event.target)) {
          current.onDismiss();
        }
      }
    }
  }
}

abstract class TioPopupHierarchyElement {
  TioPopupHierarchy get hierarchy;

  bool get shouldAutoDismiss;

  HtmlElement get popupElement;

  void attachToVisibleHierarchy() => hierarchy._attach(this);

  void detachFromVisibleHierarchy() => hierarchy._detach(this);

  void onAutoDismiss(Event event) {
    onDismiss();
  }

  void onDismiss();
}
