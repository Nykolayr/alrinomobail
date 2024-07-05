part of 'timer_bloc.dart';

class TimerState extends Equatable {
  final Duration duration;

  const TimerState({required this.duration});

  factory TimerState.initial() {
    return const TimerState(duration: Duration(seconds: 0));
  }

  @override
  List<Object> get props => [duration];
}
