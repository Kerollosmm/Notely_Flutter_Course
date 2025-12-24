import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/blocs/editor/editor_bloc.dart' as bloc;
import 'package:flutter_course_2/constants/app_colors.dart';
import 'package:flutter_course_2/constants/app_dimensions.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class EditScreen extends StatelessWidget {
  final CloudNote? note;

  const EditScreen({Key? key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as CloudNote?;
    final noteToLoad = note ?? routeArgs;

    return BlocProvider(
      create: (context) => bloc.EditorBloc(NoteRepository())..add(bloc.EditorLoadNote(noteToLoad)),
      child: const _EditScreenView(),
    );
  }
}

class _EditScreenView extends StatefulWidget {
  const _EditScreenView({Key? key}) : super(key: key);

  @override
  State<_EditScreenView> createState() => _EditScreenViewState();
}

class _EditScreenViewState extends State<_EditScreenView> {
  final QuillController _quillController = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _titleController = TextEditingController();
  bool _isToolbarVisible = true;

  @override
  void initState() {
    super.initState();
    _quillController.document.changes.listen((change) {
       final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
       context.read<bloc.EditorBloc>().add(bloc.EditorContentChanged(contentJson));
    });
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<bloc.EditorBloc, bloc.EditorState>(
      listenWhen: (previous, current) => previous is bloc.EditorInitial && current is bloc.EditorLoaded,
      listener: (context, state) {
        if (state is bloc.EditorLoaded) {
          _titleController.text = state.title;
          if (state.contentJson.isNotEmpty) {
             try {
               final json = jsonDecode(state.contentJson);
               _quillController.document = Document.fromJson(json);
             } catch (e) {
               // Fallback
             }
          }
        }
      },
      builder: (context, state) {
        if (state is bloc.EditorInitial || state is bloc.EditorLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is bloc.EditorLoaded) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () {
                 if (state.isDirty) {
                   context.read<bloc.EditorBloc>().add(bloc.EditorSaveNote());
                 }
                 Navigator.pop(context);
              }),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                     Share.share('${state.title}\n\n${_quillController.document.toPlainText()}');
                  },
                ),
                TextButton(
                  onPressed: () {
                     context.read<bloc.EditorBloc>().add(bloc.EditorSaveNote());
                     Navigator.pop(context);
                  },
                  child: Text('Done', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 8.w),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last edited: ${_formatDate(state.lastEdited)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      Hero(
                        tag: 'note_title_${state.originalNote?.documentId ?? 'new'}',
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: _titleController,
                            style: Theme.of(context).textTheme.headlineMedium,
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                            ),
                            onChanged: (val) => context.read<bloc.EditorBloc>().add(bloc.EditorTitleChanged(val)),
                          ),
                        ),
                      ),
                      _buildTags(state.tags, context),
                    ],
                  ),
                ),

                Expanded(
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(
                      placeholder: 'Start writing...',
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                // Toolbar attached to keyboard or bottom
                if (_isToolbarVisible)
                  Padding(
                    padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
                    child: _buildCustomToolbar(),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTags(List<String> tags, BuildContext context) {
    return Wrap(
      spacing: 8.w,
      children: [
        ...tags.map((tag) => Chip(
          label: Text(tag),
          onDeleted: () => context.read<bloc.EditorBloc>().add(bloc.EditorRemoveTag(tag)),
        )),
        ActionChip(
          label: const Icon(Icons.add, size: 16),
          onPressed: () {
             _showAddTagDialog(context);
          },
        ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () {
            if (controller.text.isNotEmpty) {
              context.read<bloc.EditorBloc>().add(bloc.EditorAddTag(controller.text));
              Navigator.pop(ctx);
            }
          }, child: const Text('Add')),
        ],
      );
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute}";
  }

  // Toolbar Implementation
  Widget _buildCustomToolbar() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolbarButton(icon: Icons.format_bold, attribute: Attribute.bold, tooltip: 'Bold'),
            _buildToolbarButton(icon: Icons.format_italic, attribute: Attribute.italic, tooltip: 'Italic'),
            _buildToolbarButton(icon: Icons.format_underlined, attribute: Attribute.underline, tooltip: 'Underline'),
            _buildVerticalDivider(),
            _buildToolbarButton(icon: Icons.format_list_bulleted, attribute: Attribute.ul, tooltip: 'Bullet List'),
            _buildToolbarButton(icon: Icons.format_list_numbered, attribute: Attribute.ol, tooltip: 'Numbered List'),
            _buildToolbarButton(icon: Icons.check_box_outline_blank, attribute: Attribute.unchecked, tooltip: 'Checkbox'),
            _buildVerticalDivider(),
            _buildColorButton(),
            _buildBackgroundColorButton(),
            _buildClearFormattingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({required IconData icon, required Attribute attribute, required String tooltip}) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _quillController,
      builder: (context, child) {
        final attr = _quillController.getSelectionStyle().attributes[attribute.key];
        final isActive = attr?.value == attribute.value;
        return Tooltip(
          message: tooltip,
          child: IconButton(
            icon: Icon(icon, color: isActive ? AppColors.primary : theme.iconTheme.color),
            onPressed: () => _quillController.formatSelection(attribute),
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.w,
      height: 24.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: Colors.grey.withAlpha(50),
    );
  }

  Widget _buildColorButton() {
     return IconButton(
       icon: const Icon(Icons.format_color_text),
       onPressed: () => _showColorPicker(isBackground: false),
     );
  }

  Widget _buildBackgroundColorButton() {
     return IconButton(
       icon: const Icon(Icons.format_color_fill),
       onPressed: () => _showColorPicker(isBackground: true),
     );
  }

  Widget _buildClearFormattingButton() {
     return IconButton(
       icon: const Icon(Icons.format_clear),
       onPressed: () {
          final attrs = {Attribute.bold, Attribute.italic, Attribute.underline, Attribute.ul, Attribute.ol, Attribute.color, Attribute.background};
          for (final attr in attrs) {
            _quillController.formatSelection(Attribute.clone(attr, null));
          }
       },
     );
  }

  void _showColorPicker({required bool isBackground}) {
     // Simplified color picker
     showDialog(context: context, builder: (ctx) {
       return AlertDialog(
         title: Text(isBackground ? 'Background Color' : 'Text Color'),
         content: Wrap(
           spacing: 8,
           runSpacing: 8,
           children: [Colors.black, Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.orange]
               .map((c) => _buildColorOption(c, isBackground)).toList(),
         ),
       );
     });
  }

  Widget _buildColorOption(Color color, bool isBackground) {
    return GestureDetector(
      onTap: () {
        final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
        final attribute = isBackground ? Attribute.background : Attribute.color;
        _quillController.formatSelection(Attribute.clone(attribute, hex));
        Navigator.pop(context);
      },
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
      ),
    );
  }
}
