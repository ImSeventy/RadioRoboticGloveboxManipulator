enum CommunicationCommands {
  clearSteps("clear-steps"),
  pause("pause"),
  stop("stop"),
  resume("resume"),
  start("start"),
  endStep("end-step");

  final String command;

  const CommunicationCommands(this.command);
}