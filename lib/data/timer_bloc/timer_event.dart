part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class StartTimerEvent extends TimerEvent {}

class PauseTimerEvent extends TimerEvent {}

class ResumeTimerEvent extends TimerEvent {}

class StopTimerEvent extends TimerEvent {}

class UpdateDurationEvent extends TimerEvent {
  final Duration duration;

  const UpdateDurationEvent(this.duration);

  @override
  List<Object> get props => [duration];
}
