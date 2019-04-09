import 'dart:async';
import 'dart:html';

import 'package:angular_components/utils/browser/events/events.dart' as events;
import 'package:logging/logging.dart';

class TioPopupHierarchy {
  final log = Logger("${TioPopupHierarchy}");

  final _visiblePopupsStack = List<TioPopupHierarchyElement>();

  StreamSubscription _triggerListener;
  StreamSubscription _keyUpListener;

  var _currentZIndex = 0;

  void _attach(TioPopupHierarchyElement child) {
    assert(child != null);
    log.finest("In _attach");

    child.popupElement.style.zIndex = (_currentZIndex++).toString();
    _visiblePopupsStack.add(child);

    if (_triggerListener == null) {
      _triggerListener = events.triggersOutside(null).listen(_onTrigger);
    }

    if (_keyUpListener == null) {
      _keyUpListener = document.onKeyUp.listen(_onKeyUp);
    }
  }

  void _detach(TioPopupHierarchyElement child) {
    log.finest("In _detach");

    if (_visiblePopupsStack.remove(child) && _visiblePopupsStack.isEmpty) {
      _disposeListeners();
    }

    child.popupElement.style.removeProperty("z-index");
    _currentZIndex--;
  }

  void _disposeListeners() {
    log.finest("In _disposeListeners");

    _triggerListener.cancel();
    _keyUpListener.cancel();
    _triggerListener = null;
    _keyUpListener = null;
  }

  void _onTrigger(Event event) {
    log.finest("In _onTrigger");

    for (int i = _visiblePopupsStack.length - 1; i >= 0; i--) {
      final current = _visiblePopupsStack[i];
      if (events.isParentOf(current.popupElement, event.target as Node)) return;

      for (var blockerElement in current.autoDismissBlockers) {
        if (events.isParentOf(blockerElement, event.target as Node)) return;
      }

      if (current.shouldAutoDismiss) current.onAutoDismiss(event);
    }
  }

  void _onKeyUp(KeyboardEvent event) {
    log.finest("In _onKeyUp");

    if (event.keyCode == KeyCode.ESC) {
      for (int i = _visiblePopupsStack.length - 1; i >= 0; i--) {
        final current = _visiblePopupsStack[i];

        if (events.isParentOf(current.popupElement, event.target as Node)) {
          current.onDismiss();
        }
      }
    }
  }
}

abstract class TioPopupHierarchyElement {
  final log = Logger("${TioPopupHierarchyElement}");

  TioPopupHierarchy get hierarchy;

  List<Element> get autoDismissBlockers;

  bool get shouldAutoDismiss;

  HtmlElement get popupElement;

  void attachToVisibleHierarchy() => hierarchy._attach(this);

  void detachFromVisibleHierarchy() => hierarchy._detach(this);

  void onAutoDismiss(Event event) {
    log.finest("In onAutoDismiss");
    onDismiss();
  }

  void onDismiss();
}
