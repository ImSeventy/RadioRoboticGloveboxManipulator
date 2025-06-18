import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rrgbm/presentation/controller/bloc/cubits/controller_cubit.dart';
import 'package:rrgbm/presentation/controller/bloc/states/controller_states.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

import '../../shared/widgets/DataCard.dart';

class AutomationPage extends StatelessWidget {
  final void Function(String message) sendMessageFunction;
  final bool isConnecting;
  final bool isConnected;
  const AutomationPage({
    Key? key,
    required this.sendMessageFunction,
    required this.isConnecting,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ControllerCubit, ControllerState>(
      buildWhen: (oldState, newState) => oldState != newState,
      listenWhen: (oldState, newState) => oldState != newState,
      listener: (context, state) {},
      builder: (context, state) {
        ControllerCubit controllerCubit = context.read();
        return Scaffold(
          appBar: AppBar(
            title: const Text("Process Automation"),
            centerTitle: true,
            backgroundColor: context.colorScheme.primary,
            titleTextStyle: context.textTheme.titleLarge?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold),
            foregroundColor: context.colorScheme.onPrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: controllerCubit.processes
                      .map(
                        (e) => DataCard.fromProcess(
                          e,
                          isConnected,
                          isConnecting,
                          sendMessageFunction,
                          context,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
