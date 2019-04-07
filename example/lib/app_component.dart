import 'package:angular/angular.dart';
import 'package:logging/logging.dart';

import 'package:tio_angular_components/tio_angular_components.dart';
import 'package:tio_angular_components/tio_popup/alignment.dart';
import 'package:tio_angular_components/tio_popup/tio_overlay_service.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_source.dart';

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [TioPopupComponent, PopupSourceDirective],
    providers: [overlayProviders],
    exports: [RelativePosition])
class AppComponent implements OnInit {
  var popup1Visible = false;
  var popup2Visible = false;
  var popup3Visible = false;

  @override
  void ngOnInit() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) =>
        print("[${record.time}] ${record.loggerName}: ${record.message}"));
  }
}
