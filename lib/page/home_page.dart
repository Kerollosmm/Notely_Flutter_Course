import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInalidNumber)
                ? state.invalidValue
                : '';

            return Column(
              children: [
                SizedBox(height: 50, width: 20),
                Text('Current Value => ${state.value}'),
                Visibility(
                  child: Text('invalid input:$invalidValue'),
                  visible: state is! CounterStateInalidNumber,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Mother Fucker '),
                  keyboardType: TextInputType.number,
                ),
              Row(
                children: [
                  TextButton(onPressed: (){
                    context.read<CounterBloc>()
                    .add(DecrementEvent(_controller.text));
                  }, child: Text('+')),
                  TextButton(onPressed: (){
                    context.read<CounterBloc>()
                    .add(IncrementEvent(_controller.text));
                  }, child: Text('-')),

                ],
              )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  CounterStateValid(int value) : super(value);
}

class CounterStateInalidNumber extends CounterState {
  final String invalidValue;

  CounterStateInalidNumber({
    required this.invalidValue,
    required int previewValue,
  }) : super(previewValue);
}

abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer != null) {
        emit(
          CounterStateInalidNumber(
            invalidValue: event.value,
            previewValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value + integer!));
      }
    });
    on<DecrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer != null) {
        emit(
          CounterStateInalidNumber(
            invalidValue: event.value,
            previewValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value - integer!));
      }
    });
  }
}
