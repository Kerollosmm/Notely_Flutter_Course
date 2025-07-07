import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class NoteToolbar extends StatefulWidget {
  final quill.QuillController quillController;

  const NoteToolbar({
    Key? key,
    required this.quillController,
  }) : super(key: key);

  @override
  _NoteToolbarState createState() => _NoteToolbarState();
}

class _NoteToolbarState extends State<NoteToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isToolbarExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // To handle selection changes and update button states if necessary
    widget.quillController.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    widget.quillController.removeListener(_onSelectionChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    // This is needed to rebuild the toolbar buttons and reflect their active state
    // when text selection or formatting changes.
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleToolbar() {
    setState(() {
      _isToolbarExpanded = !_isToolbarExpanded;
    });
    if (_isToolbarExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive, // Determined by checking QuillController's current selection format
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: isActive ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildMinimalToolbar() {
    final theme = Theme.of(context);
    final quillAttrs = widget.quillController.getSelectionStyle().attributes;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            onPressed: () => widget.quillController.formatSelection(quill.Attribute.bold),
            isActive: quillAttrs.containsKey(quill.Attribute.bold.key),
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            onPressed: () => widget.quillController.formatSelection(quill.Attribute.italic),
            isActive: quillAttrs.containsKey(quill.Attribute.italic.key),
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.format_underlined,
            tooltip: 'Underline',
            onPressed: () => widget.quillController.formatSelection(quill.Attribute.underline),
            isActive: quillAttrs.containsKey(quill.Attribute.underline.key),
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bulleted List',
            onPressed: () => widget.quillController.formatSelection(quill.Attribute.ul),
            isActive: quillAttrs.containsKey(quill.Attribute.list.key) &&
                        quillAttrs[quill.Attribute.list.key]?.value == 'bullet',
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.check_box_outline_blank, // Or Icons.check_box
            tooltip: 'Checklist',
            onPressed: () => widget.quillController.formatSelection(quill.Attribute.checked),
            isActive: (quillAttrs[quill.Attribute.list.key]?.value == quill.Attribute.unchecked.value ||
                        quillAttrs[quill.Attribute.list.key]?.value == quill.Attribute.checked.value),
          ),
          const Spacer(),
          _buildToolbarButton(
            icon: _isToolbarExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            tooltip: _isToolbarExpanded ? 'Collapse Toolbar' : 'Expand Toolbar',
            onPressed: _toggleToolbar,
            isActive: false, 
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedToolbar() {
    final theme = Theme.of(context);
    return Container( // No AnimatedSize needed here as the parent will handle it or it's fixed size
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Formatting Tools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Collapse Toolbar',
                  onPressed: _toggleToolbar,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: quill.QuillSimpleToolbar(
              controller: widget.quillController,
              config: const quill.QuillSimpleToolbarConfig(
                multiRowsDisplay: true, // Allow multiple rows if needed
                showDividers: true,
                showFontFamily: false,
                showFontSize: false,
                showBoldButton: true,
                showItalicButton: true,
                showSmallButton: false,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showInlineCode: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showAlignmentButtons: true,
                showLeftAlignment: true,
                showCenterAlignment: true,
                showRightAlignment: true,
                showJustifyAlignment: true,
                showHeaderStyle: true,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: true, // Will be used in next step
                showCodeBlock: true,
                showIndent: true,
                showLink: true,
                showUndo: true,
                showRedo: true,
                showDirection: false,
                showSearchButton: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isToolbarExpanded ? _buildExpandedToolbar() : _buildMinimalToolbar(),
    );
  }
}
