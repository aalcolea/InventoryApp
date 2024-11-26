import 'package:flutter/material.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final List<String> messages = [
    'Message 1',
    'Message 2',
    'Message 3',
    'Message 4',
    'Message 5',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Acción al hacer tap en el elemento
            print("Mensaje ${messages[index]} tocado");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Message tapped: ${messages[index]}'),
            ));
          },
          child: Dismissible(
            key: Key(messages[index]),
            background: slideLeftBackground(),
            secondaryBackground: slideRightBackground(),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Message deleted'),
                ));
                return true;
              } else if (direction == DismissDirection.startToEnd) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Message marked as read'),
                ));
                return false;
              }
              return false;
            },
            onDismissed: (direction) {
              setState(() {
                messages.removeAt(index);
              });
            },
            child: ListTile(
              title: Text(messages[index]),
            ),
          ),
        );
      },
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.mark_email_read, color: Colors.white),
    );
  }
}