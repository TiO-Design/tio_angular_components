import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import 'package:tio_angular_components/tio_angular_components.dart';

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [TioPopupComponent, PopupSourceDirective],
    providers: <Object>[popupBindings])
class AppComponent implements OnInit {
  var popup1Visible = false;

  @override
  void ngOnInit() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) =>
        print("[${record.time}] ${record.loggerName}: ${record.message}"));
  }
}
