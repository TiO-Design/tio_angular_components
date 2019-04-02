import 'package:angular/angular.dart';

import 'package:tio_angular_components/tio_angular_components.dart';
import 'package:tio_angular_components/tio_popup/tio_overlay_service.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_hierarchy.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [TioPopupComponent],
    providers: [
      ClassProvider(TioOverlayService),
      ClassProvider(TioPopupHierarchy)
    ])
class AppComponent {
  var popupVisible = false;

  void handleClick() {
    popupVisible = !popupVisible;
  }
}
