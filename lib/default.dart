import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DefaultFilter extends ProductionFilter {
  DefaultFilter() {
    Logger.level = Level.info;
  }
}

class ShortTimePrinter extends SimplePrinter {
  ShortTimePrinter({bool colors = true})
      : super(printTime: true, colors: colors);

  @override
  List<String> log(LogEvent event) {
    final String original = super.log(event)[0];
    final shortTime = DateFormat.Hms().format(event.time);
    return [original.replaceFirst(RegExp(r'TIME: \S+'), shortTime)];
  }
}

final defaultLogger = Logger(
  printer: HybridPrinter(PrettyPrinter(), info: ShortTimePrinter()),
  filter: DefaultFilter(),
);
