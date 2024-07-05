import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  TimerBloc() : super(TimerState.initial()) {
    on<StartTimerEvent>((event, emit) {
      _startTimer();
    });

    on<StopTimerEvent>((event, emit) {
      _stopTimer();
    });
    on<UpdateDurationEvent>((event, emit) {
      emit(TimerState(duration: event.duration));
    });
  }

  void _startTimer() async {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_timerIsolate, _receivePort!.sendPort);
    _receivePort!.listen((message) {
      add(UpdateDurationEvent(message));
    });
  }

  void _stopTimer() {
    _isolate?.kill(priority: Isolate.immediate);
    // _duration = const Duration(milliseconds: 0);
    // add(UpdateDurationEvent(_duration));
  }

  static void _timerIsolate(SendPort sendPort) {
    Duration duration = const Duration(milliseconds: 0);
    Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      duration = duration + const Duration(milliseconds: 100);
      sendPort.send(duration);
    });
  }

  @override
  Future<void> close() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    return super.close();
  }
}
