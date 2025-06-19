import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/utailates/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(CloudNote note);

class NoteListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final DeleteNoteCallback onDelete;
  const NoteListView({super.key, required this.notes, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(onPressed: ()async {
            final shouldDelete = await showDeleteDialog(context);
            
            if(shouldDelete){
              onDelete(note);
            }
          }, icon: Icon(Icons.delete)),
        );
      },
    );
  }
}
