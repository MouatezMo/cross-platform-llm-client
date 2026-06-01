import 'package:flutter/material.dart';

/// Detects the base text direction of a string by scanning for the first
/// strong directional character. Returns [TextDirection.rtl] for Arabic,
/// Hebrew, Persian, Urdu, etc. and [TextDirection.ltr] otherwise.
///
/// Neutral characters (digits, punctuation, whitespace) are skipped so that
/// a paragraph starting with "Hello, 2024:" is correctly detected as LTR.
TextDirection detectTextDirection(String text) {
  for (int i = 0; i < text.length; i++) {
    final code = text.codeUnitAt(i);
    if (_isWhitespace(code) || _isNeutral(code)) continue;
    if (_isStrongRtl(code)) return TextDirection.rtl;
    if (_isStrongLtl(code)) return TextDirection.ltr;
  }
  return TextDirection.ltr;
}

bool _isWhitespace(int c) =>
    c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0x0B || c == 0x0C;

bool _isNeutral(int c) {
  return (c >= 0x0021 && c <= 0x002F) ||
      (c >= 0x003A && c <= 0x0040) ||
      (c >= 0x005B && c <= 0x0060) ||
      (c >= 0x007B && c <= 0x007E) ||
      (c >= 0x2000 && c <= 0x206F);
}

bool _isStrongRtl(int c) {
  return (c >= 0x0590 && c <= 0x05FF) ||
      (c >= 0x0600 && c <= 0x06FF) ||
      (c >= 0x0700 && c <= 0x074F) ||
      (c >= 0x0750 && c <= 0x077F) ||
      (c >= 0x0780 && c <= 0x07BF) ||
      (c >= 0x07C0 && c <= 0x07FF) ||
      (c >= 0x0840 && c <= 0x085F) ||
      (c >= 0x08A0 && c <= 0x08FF) ||
      (c >= 0xFB1D && c <= 0xFB4F) ||
      (c >= 0xFE70 && c <= 0xFEFF);
}

bool _isStrongLtl(int c) {
  return (c >= 0x0041 && c <= 0x005A) ||
      (c >= 0x0061 && c <= 0x007A) ||
      (c >= 0x00C0 && c <= 0x024F) ||
      (c >= 0x0370 && c <= 0x03FF) ||
      (c >= 0x0400 && c <= 0x04FF) ||
      (c >= 0x1E00 && c <= 0x1EFF);
}

/// A [Text] widget that auto-detects its base direction from the string
/// content. The paragraph alignment and cursor movement follow the
/// detected direction, so mixed LTR/RTL text is rendered correctly
/// regardless of the device locale.
class DirectionalText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final StrutStyle? strutStyle;
  final Locale? locale;

  const DirectionalText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.strutStyle,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: detectTextDirection(data),
      child: Text(
        data,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
        strutStyle: strutStyle,
        locale: locale,
      ),
    );
  }
}

/// A [SelectableText] widget that auto-detects its base direction from the
/// string content.
class DirectionalSelectableText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool showCursor;
  final FocusNode? focusNode;
  final TextSelectionControls? selectionControls;
  final bool enableInteractiveSelection;

  const DirectionalSelectableText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.showCursor = false,
    this.focusNode,
    this.selectionControls,
    this.enableInteractiveSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: detectTextDirection(data),
      child: SelectableText(
        data,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        showCursor: showCursor,
        focusNode: focusNode,
        selectionControls: selectionControls,
        enableInteractiveSelection: enableInteractiveSelection,
      ),
    );
  }
}

/// A [TextField] widget that auto-detects its base direction from the
/// current value of its [TextEditingController]. The direction is updated
/// on every change so the cursor and text alignment follow what the user
/// is typing.
class DirectionalTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool expands;
  final TextAlign textAlign;

  const DirectionalTextField({
    super.key,
    this.controller,
    this.style,
    this.decoration,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.expands = false,
    this.textAlign = TextAlign.start,
  });

  @override
  State<DirectionalTextField> createState() => _DirectionalTextFieldState();
}

class _DirectionalTextFieldState extends State<DirectionalTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant DirectionalTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
      _controller.addListener(_onTextChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: detectTextDirection(_controller.text),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: widget.style,
        decoration: widget.decoration,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        expands: widget.expands,
        textAlign: widget.textAlign,
      ),
    );
  }
}
