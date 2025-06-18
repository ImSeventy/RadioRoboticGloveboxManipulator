import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rrgbm/presentation/controller/bloc/cubits/controller_cubit.dart';
import 'package:rrgbm/presentation/controller/bloc/states/controller_states.dart';
import 'package:rrgbm/presentation/shared/constants/joints_data.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';
import 'package:rrgbm/presentation/shared/widgets/custom_button.dart';

import '../widgets/save_process_dialog.dart';
import '../widgets/sliders_grid.dart';
import '../widgets/speed_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';


class ControllerPage extends StatefulWidget {
  final void Function(String message) sendMessageFunction;
  final bool isConnecting;
  final bool isConnected;
  const ControllerPage({Key? key, required this.sendMessageFunction, required this.isConnecting, required this.isConnected}) : super(key: key);

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {

  void _saveProcess(BuildContext context, String? name) {
    if (name == null || name.isEmpty) return;

    ControllerCubit controllerCubit = context.read();
    controllerCubit.saveProcess(name);
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<ControllerCubit, ControllerState>(
      buildWhen: (oldState, newState) => oldState != newState,
      listenWhen: (oldState, newState) => oldState != newState,
      listener: (context, state) {
        if (state is ControllerErrorState) {
          context.showSnackBar(state.message, Colors.red);
        }

        if (state is ControllerSaveProcessSuccessState) {
          context.showSnackBar("Saved process successfully", context.colorScheme.primary);
        }
      },
      builder: (context, state) {
        ControllerCubit controllerCubit = context.read();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: context.colorScheme.primary,
            centerTitle: true,
            leading: IconButton(onPressed: () {
              controllerCubit.clearSteps();
              context.navigator.pop();
            }, icon: const Icon(Icons.arrow_back)),
            title: (widget.isConnecting
                ? const Text('Connecting to Glovebox...')
                : widget.isConnected
                ? const Text('Live Control GloveBox')
                : const Text('Disconnected with Glovebox')),
            titleTextStyle: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onPrimary, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: context.colorScheme.onPrimary),
            actions: [
              IconButton(
                onPressed: widget.isConnected ? controllerCubit.saveStep : null,
                icon: const Icon(
                  Icons.add_box_outlined,
                ),
              ),
              IconButton(
                onPressed: !widget.isConnected ? null : () async {
                  if (controllerCubit.steps.isEmpty) return;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SaveProcessDialog(callback: (String? name) => _saveProcess(context, name));
                    },
                  );
                },
                icon: const Icon(
                  Icons.save,
                ),
              ),
            ]
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Left",
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Right",
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SlidersGrid(
                    enabled: widget.isConnected,
                    jointsData: jointsData,
                    onJointChange: (String code, double value) {
                      controllerCubit.setCurrentReading(code, value.toInt());
                      widget.sendMessageFunction("$code${value.toInt()}");
                    },
                  ),
                  SpeedSlider(
                    enabled: widget.isConnected,
                    onChange: (double value) {
                      widget.sendMessageFunction("ss${value.toInt()}");
                    },
                  ),
                  const SizedBox(height: 15,),
                  CustomButton(callback: () => widget.sendMessageFunction("go-live"), text: "Control by hand", isLoading: false),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
