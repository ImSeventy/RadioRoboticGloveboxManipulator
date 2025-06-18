import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rrgbm/domain/models/AutomationProcess.dart';
import 'package:rrgbm/presentation/controller/bloc/cubits/controller_cubit.dart';
import 'package:rrgbm/presentation/controller/bloc/states/controller_states.dart';
import 'package:rrgbm/presentation/controller/widgets/delete_process_dialog.dart';
import 'package:rrgbm/presentation/shared/constants/communication_commands.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';
import 'package:rrgbm/presentation/shared/widgets/PropertyHolder.dart';
import 'package:rrgbm/presentation/shared/widgets/custom_button.dart';

class ProcessAutomationPageArgs {
  final AutomationProcess automationProcess;
  final void Function(String message) sendMessageFunction;
  final bool isConnecting;
  final bool isConnected;

  ProcessAutomationPageArgs(this.automationProcess, this.sendMessageFunction,
      this.isConnecting, this.isConnected);
}

class ProcessAutomationPage extends StatefulWidget {
  final AutomationProcess automationProcess;
  final void Function(String message) sendMessageFunction;
  final bool isConnecting;
  final bool isConnected;

  const ProcessAutomationPage(
      {Key? key,
      required this.automationProcess,
      required this.sendMessageFunction,
      required this.isConnecting,
      required this.isConnected})
      : super(key: key);

  @override
  State<ProcessAutomationPage> createState() => _ProcessAutomationPageState();
}

class _ProcessAutomationPageState extends State<ProcessAutomationPage> {
  bool isLoading = false;
  bool isPaused = false;
  bool isStarted = false;
  bool isUploaded = false;

  void clearSteps() {
    widget.sendMessageFunction(CommunicationCommands.clearSteps.command);
  }

  void endStep() {
    widget.sendMessageFunction(CommunicationCommands.endStep.command);
  }

  void uploadSteps() async {
    setState(() {
      isLoading = true;
    });
    clearSteps();
    for (var step in widget.automationProcess.steps) {
      for (String command in step) {
        await Future.delayed(
          const Duration(
            milliseconds: 100,
          ),
        );
        widget.sendMessageFunction("auto$command");
      }
      await Future.delayed(const Duration(milliseconds: 100));
      endStep();
    }

    setState(() {
      isUploaded = true;
      isLoading = false;
    });
  }

  void resumeOrPause() {
    setState(() {
      isLoading = true;
    });
    widget.sendMessageFunction(isPaused
        ? CommunicationCommands.resume.command
        : CommunicationCommands.pause.command);
    setState(() {
      isLoading = false;
      isPaused = !isPaused;
    });
  }

  void stop() {
    setState(() {
      isLoading = true;
    });
    widget.sendMessageFunction(CommunicationCommands.stop.command);
    setState(() {
      isLoading = false;
      isStarted = false;
    });
  }

  void delete(BuildContext context) async {
    ControllerCubit controllerCubit = context.read();
    bool success = await controllerCubit.deleteProcess(widget.automationProcess.uuid);

    if (context.mounted && success) {
      context.navigator.pop();
    }
  }

  void start() {
    if (!isUploaded) return;
    setState(() {
      isLoading = true;
    });
    widget.sendMessageFunction(CommunicationCommands.start.command);
    setState(() {
      isStarted = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ControllerCubit, ControllerState>(listener: (context, state) {
      if (state is DeleteProcessErrorState) {
        context.showSnackBar(state.message, Colors.red);
      }

      if (state is DeleteProcessSuccessState) {
        context.showSnackBar("Deleted process successfully", Colors.green);
        context.navigator.pop();
      }
    }, child: Scaffold(
      appBar: AppBar(
        title: Text("${widget.automationProcess.name} process"),
        centerTitle: true,
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        titleTextStyle: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: context.colorScheme.onPrimary),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DeleteProcessDialog(
                callback: () => delete(
                  context,
                ),
              ),
            ),
            icon: const Icon(
              Icons.delete,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PropertyHolder(
                propertyName: "Id", data: widget.automationProcess.uuid),
            PropertyHolder(
              propertyName: "Name",
              data: widget.automationProcess.name,
            ),
            PropertyHolder(
              propertyName: "Steps",
              data: (widget.automationProcess.steps.length).toString(),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  CustomButton(
                    callback: uploadSteps,
                    text: "Upload",
                    isLoading: isLoading,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomButton(
                    callback: isStarted ? resumeOrPause : () {},
                    text: isPaused ? "Resume" : "Pause",
                    isLoading: isLoading,
                    backgroundColor:
                    isPaused ? Colors.lightGreen : Colors.yellow,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomButton(
                    callback: isStarted ? stop : start,
                    text: isStarted ? "Stop" : "Start",
                    isLoading: isLoading,
                    backgroundColor: isStarted ? Colors.red : Colors.lightGreen,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),);
  }
}
