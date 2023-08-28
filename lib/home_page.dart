import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<String> todoItems = [];

  void addTodoItem(String item) {
    setState(() {
      todoItems.add(item);
    });
  }

  void removeTodoItem(int index) {
    setState(() {
      todoItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Complete',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey,
      ),
      body: SpacedItemsList(
        items: todoItems,
        onItemFinished: (index) {
          removeTodoItem(index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: CreateButton(onAdd: addTodoItem),
            label: 'Create',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class SpacedItemsList extends StatelessWidget {
  final List<String> items;

  final Function(int) onItemFinished;

  const SpacedItemsList({
    required this.items,
    required this.onItemFinished,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
                items.length,
                (index) => ItemWidget(
                      text: items[index],
                      onFinished: () {
                        onItemFinished(
                            index); // Call the callback to finish the item
                      },
                    )),
          ),
        ),
      );
    });
  }
}

// class ItemWidget extends StatelessWidget {
//   const ItemWidget({
//     super.key,
//     required this.text,
//   });

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: SizedBox(
//         height: 100,
//         child: Center(child: Text(text)),
//       ),
//     );
//   }
// }

class ItemWidget extends StatefulWidget {
  const ItemWidget({
    Key? key,
    required this.text,
    required this.onFinished,
  }) : super(key: key);

  final String text;
  final VoidCallback onFinished;

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Timer? _timer; // Use Timer? instead of Timer
  bool _showButtons = false;
  bool _timerRunning = false;
  //late Timer _timer;
  int _seconds = 0;
  int _pausedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_timerRunning) {
      setState(() {
        _seconds++;
      });
    }
  }

  // void _toggleTimer() {
  //   setState(() {
  //     _timerRunning = !_timerRunning;
  //     if (_timerRunning) {
  //       _seconds = 0; // Reset the seconds when timer starts
  //     }
  //   });
  // }
  void _toggleTimer() {
    setState(() {
      _timerRunning = !_timerRunning;
      if (_timerRunning) {
        _resetTimer(); // Reset the timer when starting
      } else {
        _pausedSeconds = _seconds;
        _timer?.cancel(); // Cancel the timer when stopping
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel(); // Cancel the previous timer if it exists
    _seconds = _pausedSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  String _formatTime(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('HH:mm:ss').format(DateTime(0, 1, 1).add(duration));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showButtons = true;
        });
      },
      onTap: () {
        setState(() {
          _showButtons = false; // Hide the buttons when tapped
        });
        // Handle tapping the card, you can add your logic here
      },
      child: Card(
        child: Stack(
          children: [
            SizedBox(
              height: 100,
              child: Center(child: Text(widget.text)),
            ),
            if (_showButtons)
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    if (!_timerRunning)
                      IconButton(
                        onPressed: () {
                          _toggleTimer();
                        },
                        icon: Icon(Icons.play_arrow),
                      ),
                    if (_timerRunning)
                      IconButton(
                        onPressed: () {
                          _toggleTimer();
                        },
                        icon: Icon(Icons.pause),
                      ),
                    IconButton(
                      onPressed: () {
                        // Handle the action of the second button
                        widget
                            .onFinished(); // Call the callback to finish the item
                      },
                      //icon: Icon(Icons.delete),
                      icon: const Text(
                        "Finished",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                _timerRunning
                    ? _formatTime(_seconds)
                    : _seconds > 0
                        ? 'Elapsed: ${_formatTime(_seconds)}'
                        : 'Not Started',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _timerRunning ? Colors.black : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Create button at BottomNavigationBar
class CreateButton extends StatefulWidget {
  final Function(String) onAdd;

  const CreateButton({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<CreateButton> {
  final toDoName = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    toDoName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Add new to-do'),
          content: TextFormField(
            controller: toDoName,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter to-do',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onAdd(toDoName.text); // Add the new to-do item
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue, // Change this to the desired color
            ),
            padding: const EdgeInsets.all(8), // Adjust the padding as needed
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24, // Adjust the size of the icon
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red, // Change this to the desired mark color
              ),
              width: 12,
              height: 12,
            ),
          ),
        ],
      ),
    );
  }
}
