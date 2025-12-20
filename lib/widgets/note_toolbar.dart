import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoteToolbar extends StatefulWidget {
  final quill.QuillController quillController;

  const NoteToolbar({super.key, required this.quillController});

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
    required bool
    isActive, // Determined by checking QuillController's current selection format
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 40.w,
      height: 40.w, // Square button
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Material(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20.sp,
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 20.h,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildMinimalToolbar() {
    final theme = Theme.of(context);
    final quillAttrs = widget.quillController.getSelectionStyle().attributes;
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            onPressed: () =>
                widget.quillController.formatSelection(quill.Attribute.bold),
            isActive: quillAttrs.containsKey(quill.Attribute.bold.key),
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            onPressed: () =>
                widget.quillController.formatSelection(quill.Attribute.italic),
            isActive: quillAttrs.containsKey(quill.Attribute.italic.key),
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.format_underlined,
            tooltip: 'Underline',
            onPressed: () => widget.quillController.formatSelection(
              quill.Attribute.underline,
            ),
            isActive: quillAttrs.containsKey(quill.Attribute.underline.key),
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bulleted List',
            onPressed: () =>
                widget.quillController.formatSelection(quill.Attribute.ul),
            isActive:
                quillAttrs.containsKey(quill.Attribute.list.key) &&
                quillAttrs[quill.Attribute.list.key]?.value == 'bullet',
          ),
          _buildDivider(),
          _buildToolbarButton(
            icon: Icons.check_box_outline_blank, // Or Icons.check_box
            tooltip: 'Checklist',
            onPressed: () =>
                widget.quillController.formatSelection(quill.Attribute.checked),
            isActive:
                (quillAttrs[quill.Attribute.list.key]?.value ==
                    quill.Attribute.unchecked.value ||
                quillAttrs[quill.Attribute.list.key]?.value ==
                    quill.Attribute.checked.value),
          ),
          const Spacer(),
          _buildToolbarButton(
            icon: _isToolbarExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
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
    return Container(
      // No AnimatedSize needed here as the parent will handle it or it's fixed size
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Formatting Tools',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 20.sp),
                  tooltip: 'Collapse Toolbar',
                  onPressed: _toggleToolbar,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.r),
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
      child: _isToolbarExpanded
          ? _buildExpandedToolbar()
          : _buildMinimalToolbar(),
    );
  }
}
