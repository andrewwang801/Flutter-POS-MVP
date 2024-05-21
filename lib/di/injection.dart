import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:raptorpos/di/injection.config.dart';

@injectableInit
void configureInjection() => $initGetIt(GetIt.instance);
