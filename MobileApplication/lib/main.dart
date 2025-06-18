import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rrgbm/presentation/controller/bloc/cubits/controller_cubit.dart';
import 'package:rrgbm/router/router.dart';
import 'package:rrgbm/router/routes.dart';
import 'dependency_container.dart' as dc;
import 'dependency_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await dc.setUp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            var cubit = getIt<ControllerCubit>();
            cubit.getProcesses();
            return cubit;
          },
        )
      ],
      child: ScreenUtilInit(
          designSize: const Size(428, 926),
          minTextAdapt: true,
          builder: (context, _) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: const MaterialApp(
                title: 'RRGBM',
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: Routes.root,
              ),
            );
          }),
    );
  }
}
