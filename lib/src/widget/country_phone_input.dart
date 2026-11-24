import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        PaintingContext,
        PipelineOwner,
        RenderEditable,
        RenderObject,
        RenderProxyBox;
import 'package:flutter/scheduler.dart' show SchedulerPhase;
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_phone_rules.g.dart';
import 'package:flutter_simple_country_picker/src/util/country_flag_font_util.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart';
import 'package:meta/meta.dart';

/// {@template country_phone_input}
/// CountryPhoneInput widget.
///
/// This widget provides an input field for phone numbers with country selection.
/// {@endtemplate}
class CountryPhoneInput extends StatefulWidget {
  /// {@macro country_phone_input}
  const CountryPhoneInput({
    // Country selection.
    this.initialCountry,
    this.countryController,
    this.onCountryChanged,

    // Phone editing.
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.placeholder,
    this.shouldReplace8 = true,
    this.useCountryFormatting = false,

    // Picker presentation.
    this.enableOpenPicker = true,
    this.expand = true,
    this.isScrollControlled = true,
    this.shouldCloseOnSwipeDown = false,
    this.initialChildSize,
    this.minChildSize,
    this.surfaceBuilder,
    bool? useHapticFeedback,

    // Country list.
    this.filter,
    this.exclude,
    this.favorites,
    this.showGroup,
    this.showSearch,
    this.showPhoneCode = false,
    this.showWorldWide = false,

    super.key,
  }) : useHapticFeedback = useHapticFeedback ?? true;

  /// Creates a phone input with a country selector above the number field.
  const factory CountryPhoneInput.extended({
    // Country selection.
    Country? initialCountry,
    ValueNotifier<Country>? countryController,
    ValueChanged<Country>? onCountryChanged,

    // Phone editing.
    CountryPhoneController? controller,
    ValueChanged<String>? onChanged,
    bool autofocus,
    String? placeholder,
    bool shouldReplace8,
    bool useCountryFormatting,

    // Picker presentation.
    bool enableOpenPicker,
    bool expand,
    bool isScrollControlled,
    bool shouldCloseOnSwipeDown,
    double? initialChildSize,
    double? minChildSize,
    CountryPickerSurfaceBuilder? surfaceBuilder,
    bool? useHapticFeedback,

    // Country list.
    List<String>? filter,
    List<String>? exclude,
    List<String>? favorites,
    bool? showGroup,
    bool? showSearch,
    bool showPhoneCode,
    bool showWorldWide,

    Key? key,
  }) = CountryPhoneInput$Extended;

  // Country selection.

  /// The initial selection when [countryController] is omitted.
  final Country? initialCountry;

  /// An external controller for the selected country.
  final ValueNotifier<Country>? countryController;

  /// Called after the user selects a different country.
  final ValueChanged<Country>? onCountryChanged;
  // Phone editing.

  /// An external controller for the full phone number and its status.
  final CountryPhoneController? controller;

  /// Called with the full phone number when a user edit changes it.
  final ValueChanged<String>? onChanged;

  /// Whether to autofocus the phone input and the country search field.
  final bool autofocus;

  /// The placeholder shown in place of the default mask or hint.
  final String? placeholder;

  /// Whether to normalize a leading national prefix in pasted or preset text.
  ///
  /// This option originally handled the Russian trunk prefix `8`. Automatic
  /// formatting uses the selected country's prefix and supported lengths,
  /// while manual formatting retains its fixed-length normalization.
  final bool shouldReplace8;

  /// Whether to use country-specific masks and retain digits beyond the mask.
  ///
  /// Automatic formatting uses the country's supported lengths for completion.
  /// Manual formatting uses [Country.mask].
  final bool useCountryFormatting;
  // Picker presentation.

  /// Whether tapping the country selector opens the picker.
  final bool enableOpenPicker;

  /// Whether to expand the picker sheet to its full height.
  final bool expand;

  /// Whether the picker route can use the full available height.
  ///
  /// Defaults to true so country search results have room above the keyboard.
  final bool isScrollControlled;

  /// Whether dragging the country list to its minimum height dismisses the picker.
  final bool shouldCloseOnSwipeDown;

  /// The initial fraction of available height occupied by the picker sheet.
  final double? initialChildSize;

  /// The minimum fraction of available height occupied by the picker sheet.
  final double? minChildSize;

  /// {@macro country_picker_surface_builder}
  final CountryPickerSurfaceBuilder? surfaceBuilder;

  /// Whether picker interactions provide haptic feedback.
  final bool useHapticFeedback;
  // Country list.

  /// The country codes allowed in the picker.
  final List<String>? filter;

  /// The country codes omitted from the picker.
  final List<String>? exclude;

  /// The country codes shown first in the picker.
  final List<String>? favorites;

  /// Whether to group countries by their first letter.
  final bool? showGroup;

  /// Whether to show the country search field.
  final bool? showSearch;

  /// Whether to display calling codes in the country list.
  final bool showPhoneCode;

  /// Whether to include the [Country.worldWide] option in the picker.
  final bool showWorldWide;

  @override
  State<CountryPhoneInput> createState() => _CountryPhoneInputState();
}

/// Shares controller ownership and editing behavior between the input layouts.
mixin _CountryPhoneInputStateMixin<T extends CountryPhoneInput> on State<T> {
  /// Notifies the layout painters when the resolved theme changes.
  final ValueNotifier<CountryPickerTheme?> _pickerTheme = ValueNotifier(null);

  /// Tracks the horizontal offset shared by the editor and its mask.
  final ScrollController _phoneScrollController = ScrollController();

  /// Restores keyboard focus after a country selection.
  final FocusNode _phoneFocusNode = FocusNode();

  /// Owns the local text, selection, and IME composing range.
  late final TextEditingController _phoneController;

  /// Applies country checks to edits before they reach the local controller.
  late final _PhoneInputFormatter _inputFormatter;

  /// Holds the selected country, using the caller's controller when supplied.
  late ValueNotifier<Country> _countryController;

  /// Holds the active mask and its validation status.
  late final CountryInputFormatter _formatter;

  /// Holds the full phone number published to the caller.
  late CountryPhoneController _controller;

  /// Guards synchronous updates between the local and full-number controllers.
  bool _synchronizingPhone = false;

  /// The last visible IME draft, used to detect commits with identical text.
  String? _composingPhoneText;

  /// Whether the current edit changed the published number.
  ///
  /// The text field's callback consumes this value after the controller updates.
  bool? _phoneChangedByEdit;

  /// The configured initial country, defaulting to Russia.
  Country get _initialCountry => widget.initialCountry ?? Country.ru();

  @override
  void initState() {
    super.initState();
    _phoneController = _PhoneTextEditingController(_handleCompositionCommitted);
    _controller =
        widget.controller ??
        CountryPhoneController.apply(_initialCountry.countryCode);

    _countryController =
        widget.countryController ?? ValueNotifier<Country>(_initialCountry);
    _countryController.addListener(_handleCountryChanged);

    final leadingPrefixes = _manualLeadingPrefixes(_countryController.value);
    _formatter = widget.useCountryFormatting
        ? CountryInputFormatter.forCountry(
            country: _countryController.value,
            shouldTryStripLeadingPrefix: widget.shouldReplace8,
          )
        : CountryInputFormatter(
            filter: {'0': RegExp('[0-9]')},
            mask: _countryController.value.mask,
            example: _countryController.value.example,
            phoneCode: _countryController.value.phoneCode,
            leadingPrefixes: leadingPrefixes ?? const <String>{},
            shouldTryStripPhoneCode: true,
            shouldTryStripLeadingPrefix:
                widget.shouldReplace8 &&
                (leadingPrefixes == null || leadingPrefixes.isNotEmpty),
          );

    _inputFormatter = _PhoneInputFormatter(
      _formatter,
      countryCode: _countryController.value.phoneCode,
      onUnchangedEdit: _handleUnchangedEdit,
    );
    final text = _controller.text;
    if (text.isNotEmpty) {
      final value = _formatPhoneText(
        text,
        allowImplicitCountryCodeStrip: true,
        allowLeadingPrefixStrip: widget.shouldReplace8,
      );
      _phoneController.value = value;
      _inputFormatter.committedValue = value;
    }
    _phoneController.addListener(_handleEditingValueChanged);
    _controller.addListener(_handleControllerChanged);
    _updateControllerValue(text: text.isEmpty ? text : null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pickerTheme.value = CountryPickerTheme.resolve(context);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    final countryControllerChanged = !identical(
      oldWidget.countryController,
      widget.countryController,
    );
    final phoneControllerChanged = !identical(
      oldWidget.controller,
      widget.controller,
    );
    final initialCountryChanged =
        widget.initialCountry != oldWidget.initialCountry;
    final formattingChanged =
        widget.shouldReplace8 != oldWidget.shouldReplace8 ||
        widget.useCountryFormatting != oldWidget.useCountryFormatting;

    if (phoneControllerChanged) {
      final current = _controller..removeListener(_handleControllerChanged);
      if (oldWidget.controller == null) scheduleMicrotask(current.dispose);
      _controller =
          widget.controller ??
          CountryPhoneController.apply(_initialCountry.countryCode);
      _controller.addListener(_handleControllerChanged);
    }

    if (countryControllerChanged) {
      _countryController.removeListener(_handleCountryChanged);
      if (oldWidget.countryController == null) {
        scheduleMicrotask(_countryController.dispose);
      }
      _countryController =
          widget.countryController ?? ValueNotifier<Country>(_initialCountry);
      _countryController.addListener(_handleCountryChanged);
    }

    void updateValue({required bool updateInitialCountry}) {
      if (updateInitialCountry) {
        _countryController
          ..removeListener(_handleCountryChanged)
          ..value = _initialCountry
          ..addListener(_handleCountryChanged);
      }
      if (countryControllerChanged ||
          initialCountryChanged ||
          formattingChanged) {
        _updateFormatter(reformatPhone: !phoneControllerChanged);
      }
      if (!phoneControllerChanged) return;

      if (_controller.text.isEmpty &&
          !countryControllerChanged &&
          !initialCountryChanged &&
          !formattingChanged) {
        // Keep the replacement controller empty while clearing the field.
        _formatter.clear();
        _phoneController.removeListener(_handleEditingValueChanged);
        try {
          _phoneController.clear();
        } finally {
          _phoneController.addListener(_handleEditingValueChanged);
        }
        _inputFormatter.committedValue = _phoneController.value;
        _composingPhoneText = null;
        return;
      }
      _setEditingValue(
        _formatPhoneText(
          _controller.text,
          allowImplicitCountryCodeStrip: true,
          allowLeadingPrefixStrip: widget.shouldReplace8,
        ),
      );
    }

    final updateInitialCountry =
        initialCountryChanged && !countryControllerChanged;
    if (updateInitialCountry && widget.countryController != null) {
      final controller = _countryController;
      final previous = controller.value;
      final initialCountry = _initialCountry;
      final phoneController = _controller;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            identical(controller, _countryController) &&
            identical(phoneController, _controller) &&
            initialCountry == _initialCountry) {
          updateValue(
            updateInitialCountry: identical(controller.value, previous),
          );
        }
      });
    } else {
      updateValue(updateInitialCountry: updateInitialCountry);
    }
  }

  /// Returns null for countries that use the legacy prefix defaults.
  Set<String>? _manualLeadingPrefixes(Country country) =>
      switch (countryPhoneRules[country.countryCode.toUpperCase()]) {
        null => null,
        CountryPhoneRules(literalTrunkPrefix: String prefix) => {prefix},
        _ => const {},
      };

  void _updateFormatter({bool reformatPhone = true}) {
    final country = _countryController.value;
    _inputFormatter.countryCode = country.phoneCode;
    final editingValue = _phoneController.value;
    final isComposing = !editingValue.composing.isCollapsed;
    final value = isComposing ? _inputFormatter.committedValue : editingValue;
    final shouldFormat =
        reformatPhone &&
        !CountryUtil.hasForeignCallingCode(value.text, country.phoneCode);
    var formatted = value;
    if (widget.useCountryFormatting) {
      final updated = _formatter.updateCountry(
        country,
        newValue: shouldFormat ? value : .empty,
        shouldTryStripLeadingPrefix: widget.shouldReplace8,
      );
      if (shouldFormat) formatted = updated;
    } else {
      final leadingPrefixes = _manualLeadingPrefixes(country);
      _formatter.updateMask(
        newValue: .empty,
        mask: country.mask,
        example: country.example,
        phoneCode: country.phoneCode,
        shouldTryStripPhoneCode: true,
        shouldTryStripLeadingPrefix:
            widget.shouldReplace8 &&
            (leadingPrefixes == null || leadingPrefixes.isNotEmpty),
        leadingPrefixes: leadingPrefixes ?? const {},
      );
      if (shouldFormat) {
        formatted = _formatPhoneText(
          value.text,
          selection: value.selection,
          allowLeadingPrefixStrip: widget.shouldReplace8,
        );
      }
    }
    if (!reformatPhone) return;
    if (isComposing) {
      // Keep the draft visible while the formatter switches to the new mask.
      _formatter.formatEditUpdate(formatted, editingValue);
    } else {
      _setEditingValue(formatted);
    }
  }

  void _setEditingValue(TextEditingValue value) {
    final publishesEdit =
        value != _phoneController.value &&
        (_composingPhoneText != null ||
            value.text != _inputFormatter.committedValue.text);
    _phoneController.value = value;
    if (!publishesEdit) {
      // A new mask can change the status without changing the editing value.
      _updateControllerValue();
    }
  }

  void _updateControllerValue({String? text, bool preserveFormatting = false}) {
    if (_synchronizingPhone || !_phoneController.value.composing.isCollapsed) {
      return;
    }
    final phoneText = _phoneController.text;
    final countryCode = _countryController.value.phoneCode;
    final resolvedText =
        text ??
        switch ((countryCode, phoneText)) {
          ('', '') => '',
          ('', _) => '+$phoneText',
          _ when CountryUtil.hasForeignCallingCode(phoneText, countryCode) =>
            phoneText,
          _ => '+$countryCode $phoneText',
        };
    final controller = _controller;
    final previous = controller.value;
    final status = _formatter.valueStatus;
    var value = previous.copyWith(text: resolvedText, valueStatus: status);
    if (preserveFormatting &&
        value.resolution.phone == previous.resolution.phone) {
      value = previous.copyWith(valueStatus: status);
    }
    if (value == previous) return;

    final binding = WidgetsBinding.instance;
    if (widget.controller != null &&
        binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // An external controller can notify ancestors of this field.
      binding.addPostFrameCallback((_) {
        if (mounted &&
            identical(controller, _controller) &&
            identical(controller.value, previous)) {
          _updateControllerValue(
            text: text,
            preserveFormatting: preserveFormatting,
          );
        }
      });
      return;
    }

    _synchronizingPhone = true;
    try {
      controller.value = value;
    } finally {
      _synchronizingPhone = false;
    }
    if (controller.text != value.text) {
      if (controller.resolution.phone == value.resolution.phone) {
        // A formatting-only rewrite does not need to move the field's caret.
        _updateControllerValue(text: controller.text);
      } else {
        _handleControllerChanged(reformatControllerText: false);
      }
    }
  }

  void _handleControllerChanged({bool reformatControllerText = true}) {
    if (!mounted || _synchronizingPhone) return;
    final text = _controller.text;
    _synchronizingPhone = true;
    try {
      _phoneController.value = _formatPhoneText(
        text,
        allowImplicitCountryCodeStrip: true,
        allowLeadingPrefixStrip: widget.shouldReplace8,
      );
    } finally {
      _synchronizingPhone = false;
    }
    if (text.isNotEmpty) {
      _updateControllerValue(text: reformatControllerText ? null : text);
    }
  }

  TextEditingValue _formatPhoneText(
    String rawText, {
    bool allowImplicitCountryCodeStrip = false,
    bool allowLeadingPrefixStrip = false,
    TextSelection? selection,
  }) {
    if (CountryUtil.hasForeignCallingCode(
      rawText,
      _countryController.value.phoneCode,
    )) {
      _formatter.clear();
      return TextEditingValue(
        text: rawText,
        selection: TextSelection.collapsed(offset: rawText.length),
      );
    }
    final normalized = _formatter.normalizePhoneText(
      rawText,
      allowImplicitPhoneCodeStrip: allowImplicitCountryCodeStrip,
      allowLeadingPrefixStrip: allowLeadingPrefixStrip,
    );

    _formatter.clear();
    if (normalized.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formattedValue = _formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      ),
    );

    return formattedValue.copyWith(
      selection: _mapPhoneSelection(rawText, formattedValue.text, selection),
      composing: TextRange.empty,
    );
  }

  /// Restores both selection endpoints by their position among the digits.
  static TextSelection _mapPhoneSelection(
    String rawText,
    String formattedText,
    TextSelection? selection,
  ) {
    if (selection == null || !selection.isValid) {
      return TextSelection.collapsed(offset: formattedText.length);
    }

    final digit = RegExp(r'\d');
    final originalDigits = digit.allMatches(rawText).toList();
    final formattedDigits = digit.allMatches(formattedText).toList();
    final strippedDigits = originalDigits.length - formattedDigits.length;

    int offsetFor(int offset) {
      final precedingDigits = originalDigits
          .takeWhile((match) => match.end <= offset)
          .length;
      final digitIndex = (precedingDigits - strippedDigits).clamp(
        0,
        formattedDigits.length,
      );
      return digitIndex == 0 ? 0 : formattedDigits[digitIndex - 1].end;
    }

    return selection.copyWith(
      baseOffset: offsetFor(selection.baseOffset),
      extentOffset: offsetFor(selection.extentOffset),
    );
  }

  @override
  void dispose() {
    _pickerTheme.dispose();
    _phoneFocusNode.dispose();
    _phoneScrollController.dispose();
    _phoneController
      ..removeListener(_handleEditingValueChanged)
      ..dispose();
    _controller.removeListener(_handleControllerChanged);
    _countryController.removeListener(_handleCountryChanged);
    if (widget.controller == null) _controller.dispose();
    if (widget.countryController == null) _countryController.dispose();
    super.dispose();
  }

  void _handleEditingValueChanged() {
    if (!mounted) return;
    final value = _phoneController.value;
    if (!value.composing.isCollapsed) {
      _composingPhoneText = value.text;
      return;
    }
    final composingText = _composingPhoneText;
    final previousText = _inputFormatter.committedValue.text;
    _inputFormatter.committedValue = value;
    _composingPhoneText = null;
    if (composingText == null && value.text == previousText) return;

    final previous = _controller.value;
    _updateControllerValue(preserveFormatting: composingText != null);
    // A mask change can regroup the same number when composition ends.
    final changed = composingText == null
        ? previous.text != _controller.text
        : previous.resolution.phone != _controller.resolution.phone;
    _phoneChangedByEdit = changed;
    if (composingText == value.text && changed) {
      widget.onChanged?.call(_controller.text);
    }
  }

  void _handleUnchangedEdit(TextEditingValue value) {
    final controller = _controller;
    final previous = controller.value;
    // An accepted edit can leave the editor unchanged, such as pasting only
    // the calling code. Let EditableText finish applying the edit first.
    scheduleMicrotask(() {
      if (mounted &&
          identical(controller, _controller) &&
          identical(controller.value, previous) &&
          _phoneController.value == value) {
        _updateControllerValue();
      }
    });
  }

  void _handleCompositionCommitted() {
    final composing = _phoneController.value;
    final draft = _composingPhoneText;
    final previousPhone = _controller.resolution.phone;
    final value = _inputFormatter.formatEditUpdate(
      composing,
      composing.copyWith(composing: TextRange.empty),
    );
    _setEditingValue(value);
    if (draft != value.text && previousPhone != _controller.resolution.phone) {
      widget.onChanged?.call(_controller.text);
    }
  }

  void _handleCountryChanged() {
    if (!mounted) return;
    _updateFormatter();
  }

  void _handleCountrySelected(Country country) {
    if (!mounted) return;
    if (country == _countryController.value) return;
    _formatter.clear();
    _phoneController.clear();
    _phoneFocusNode.requestFocus();
    _countryController.value = country;
    widget.onCountryChanged?.call(country);
  }

  void _handleTextChanged(String _) {
    final changed = _phoneChangedByEdit;
    _phoneChangedByEdit = null;
    // EditableText also reports changes that restore a rejected draft.
    if (_phoneController.value.composing.isCollapsed && changed != false) {
      widget.onChanged?.call(_controller.text);
    }
  }

  /// Accessibility label of the country button.
  String _semanticsLabelOf(CountryLocalizations localization, Country country) {
    final name =
        localization.getFormatedCountryNameByCode(country.countryCode) ??
        country.name;
    return country.phoneCode.isEmpty ? name : '$name, +${country.phoneCode}';
  }

  Widget _buildPhoneField({
    required Key key,
    required Country country,
    required CountryPickerTheme pickerTheme,
    required TextStyle? textStyle,
    EdgeInsets? contentPadding,
  }) => _PhoneField(
    fieldKey: key,
    country: country,
    pickerTheme: pickerTheme,
    textStyle: textStyle,
    contentPadding: contentPadding,
    controller: _phoneController,
    focusNode: _phoneFocusNode,
    scrollController: _phoneScrollController,
    autofocus: widget.autofocus,
    onChanged: _handleTextChanged,
    useCountryFormatting: widget.useCountryFormatting,
    formatter: _formatter,
    inputFormatter: _inputFormatter,
    placeholder: widget.placeholder,
  );
}

/// Applies the country selection and IME rules to edits from the phone field.
final class _PhoneInputFormatter extends TextInputFormatter {
  _PhoneInputFormatter(
    this._formatter, {
    required this.countryCode,
    required this.onUnchangedEdit,
  });

  /// Formats national digits and retains the current mask and validation status.
  final CountryInputFormatter _formatter;

  /// The most recent accepted editing value, used while the IME has a draft.
  TextEditingValue committedValue = .empty;

  /// Reports a calling code pasted into an empty field.
  final ValueChanged<TextEditingValue> onUnchangedEdit;

  /// The selected calling code without a leading plus sign.
  String countryCode;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) {
      return _formatter.formatEditUpdate(oldValue, newValue);
    }
    final isForeign = CountryUtil.hasForeignCallingCode(
      newValue.text,
      countryCode,
    );
    final previousText = oldValue.composing.isCollapsed
        ? oldValue.text
        : committedValue.text;
    if (CountryUtil.hasForeignCallingCode(previousText, countryCode)) {
      // An externally supplied foreign number can be edited in place.
      _formatter.clear();
      return isForeign
          ? newValue
          : _formatter.formatEditUpdate(TextEditingValue.empty, newValue);
    }
    if (!isForeign) {
      final value = _formatter.formatEditUpdate(oldValue, newValue);
      if (oldValue.composing.isCollapsed &&
          oldValue.text.isEmpty &&
          value.text.isEmpty &&
          CountryUtil.hasOnlyCallingCode(newValue.text, countryCode)) {
        onUnchangedEdit(value);
      }
      return value;
    }
    if (oldValue.composing.isCollapsed) return oldValue;
    final committed = _formatter.getMaskedText();
    return _formatter.formatEditUpdate(
      oldValue,
      TextEditingValue(
        text: committed,
        selection: TextSelection.collapsed(offset: committed.length),
      ),
    );
  }
}

/// The editable national number field shared by both phone input layouts.
class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.fieldKey,

    // Text editing.
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.autofocus,
    required this.onChanged,

    // Phone formatting.
    required this.country,
    required this.useCountryFormatting,
    required this.formatter,
    required this.inputFormatter,

    // Appearance.
    required this.pickerTheme,
    required this.textStyle,
    this.placeholder,
    this.contentPadding,
  });

  /// The key attached to the underlying [TextFormField].
  final Key fieldKey;
  // Text editing.

  /// The editing controller for the text inside the field.
  final TextEditingController controller;

  /// The focus node used to return to the field after country selection.
  final FocusNode focusNode;

  /// The horizontal scroll controller shared by the editor and the mask.
  final ScrollController scrollController;

  /// Whether the field requests focus when it first appears.
  final bool autofocus;

  /// Receives changes from [TextFormField.onChanged] before the owning state
  /// decides whether to emit the full phone number.
  final ValueChanged<String> onChanged;
  // Phone formatting.

  /// The selected country that supplies the fallback mask.
  final Country country;

  /// Whether the field displays the unfilled part of the country-specific mask.
  final bool useCountryFormatting;

  /// Provides the remaining mask and the last formatted text for painting.
  final CountryInputFormatter formatter;

  /// Applies the country check and formatting to edits from the keyboard.
  final TextInputFormatter inputFormatter;
  // Appearance.

  /// Provides the color used to derive the mask hint color.
  final CountryPickerTheme pickerTheme;

  /// The style used for the entered text and the cursor.
  final TextStyle? textStyle;

  /// A custom hint that takes precedence over the mask and localized hint.
  final String? placeholder;

  /// The padding applied to the text field's decoration.
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final localization = CountryLocalizations.of(context);
    final showMask =
        useCountryFormatting &&
        placeholder == null &&
        formatter.maskHint != null;
    final pickerTextStyle = pickerTheme.textStyle;
    final hintColor =
        (pickerTextStyle?.foreground?.color ?? pickerTextStyle?.color)
            ?.withValues(alpha: .5);
    final decoration = InputDecoration(
      hintText: showMask
          ? null
          : placeholder ??
                (useCountryFormatting ? null : country.mask) ??
                localization.phonePlaceholder,
      hintStyle: hintColor == null
          ? textStyle
          : textStyle?.copyWith(foreground: Paint()..color = hintColor),
      contentPadding: contentPadding,
      border: InputBorder.none,
      errorBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );

    final field = TextFormField(
      key: fieldKey,
      keyboardType: .number,
      autofocus: autofocus,
      focusNode: focusNode,
      controller: controller,
      inputFormatters: <TextInputFormatter>[inputFormatter],
      scrollController: showMask ? scrollController : null,
      onChanged: onChanged,
      cursorColor: textStyle?.color,
      style: textStyle,
      decoration: decoration,
      textDirection: showMask ? TextDirection.ltr : null,
    );
    return Semantics(
      label: localization.phonePlaceholder,
      child: _PhoneMask(
        color: showMask ? hintColor : null,
        scrollController: scrollController,
        controller: controller,
        formatter: formatter,
        child: field,
      ),
    );
  }
}

/// Commits the formatted phone value when the editor clears composition.
final class _PhoneTextEditingController extends TextEditingController {
  _PhoneTextEditingController(this._commitComposition);

  /// Handles composition that ends through Done or a focus change.
  final VoidCallback _commitComposition;

  @override
  void clearComposing() {
    if (value.composing.isCollapsed) {
      super.clearComposing();
    } else {
      // EditableText calls this on Done and focus loss without running formatters.
      _commitComposition();
    }
  }
}

/// State for widget [CountryPhoneInput].
class _CountryPhoneInputState extends State<CountryPhoneInput>
    with _CountryPhoneInputStateMixin {
  /// Paints the background of the number field in the compact layout.
  late final _BackgroundPainter _painter = _BackgroundPainter(
    pickerTheme: _pickerTheme,
  );

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final textStyle = pickerTheme.textStyle;
    final measuredStyle = MediaQuery.boldTextOf(context)
        ? textStyle?.merge(const TextStyle(fontWeight: FontWeight.bold))
        : textStyle;
    final painter = TextPainter(
      text: TextSpan(text: 'Mg', style: measuredStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final height = painter.height + pickerTheme.padding;
    painter.dispose();
    final constraints = BoxConstraints.tightFor(
      height: height > pickerTheme.inputHeight
          ? height
          : pickerTheme.inputHeight,
    );
    return ValueListenableBuilder(
      valueListenable: _countryController,
      builder: (context, selected, _) => LayoutBuilder(
        builder: (context, available) {
          final label = TextPainter(
            text: TextSpan(
              style: measuredStyle,
              children: [
                TextSpan(
                  text: selected.flagEmoji,
                  style: TextStyle(fontFamily: CountryFlagFontUtil.fontFamily),
                ),
                if (selected.phoneCode.isNotEmpty)
                  TextSpan(text: ' +${selected.phoneCode}'),
              ],
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          // Keep a useful number field instead of squeezing it beside a large code.
          final stacked =
              available.maxWidth <
              label.width +
                  pickerTheme.padding * 2 +
                  pickerTheme.padding / 1.6 +
                  pickerTheme.inputHeight * 2;
          label.dispose();
          final button = ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.minHeight),
            child: Semantics(
              enabled: widget.enableOpenPicker,
              child: CupertinoButton(
                key: const ValueKey<String>('country_picker_phone_code'),
                padding: EdgeInsets.symmetric(horizontal: pickerTheme.padding),
                color: pickerTheme.onBackgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(pickerTheme.baseCornerRadius),
                ),
                pressedOpacity: .6,
                onPressed: widget.enableOpenPicker
                    ? () => showCountryPicker(
                        context: context,
                        exclude: widget.exclude,
                        favorites: widget.favorites,
                        filter: widget.filter,
                        expand: widget.expand,
                        autofocus: widget.autofocus,
                        showGroup: widget.showGroup,
                        showSearch: widget.showSearch,
                        showPhoneCode: widget.showPhoneCode,
                        showWorldWide: widget.showWorldWide,
                        shouldCloseOnSwipeDown: widget.shouldCloseOnSwipeDown,
                        useHapticFeedback: widget.useHapticFeedback,
                        isScrollControlled: widget.isScrollControlled,
                        initialChildSize: widget.initialChildSize,
                        minChildSize: widget.minChildSize,
                        surfaceBuilder: widget.surfaceBuilder,
                        selected: _countryController,
                        onSelect: _handleCountrySelected,
                      )
                    : null,
                child: Semantics(
                  // Announce the country instead of the emoji flag name.
                  label: _semanticsLabelOf(localization, selected),
                  child: ExcludeSemantics(
                    child: Center(
                      heightFactor: 1,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 3,
                        children: <Widget>[
                          if (selected.flagEmoji.isNotEmpty) ...[
                            Text.rich(
                              TextSpan(
                                text: selected.flagEmoji,
                                style: TextStyle(
                                  fontFamily: CountryFlagFontUtil.fontFamily,
                                ),
                              ),
                              style: textStyle?.copyWith(letterSpacing: 0),
                            ),
                          ],
                          if (selected.phoneCode.isNotEmpty)
                            Text('+${selected.phoneCode}', style: textStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          final field = ConstrainedBox(
            constraints: constraints,
            child: RepaintBoundary(
              key: const ValueKey<String>('country_phone_number_background'),
              child: CustomPaint(
                painter: _painter,
                child: Center(
                  child: _buildPhoneField(
                    key: const ValueKey<String>('country_phone_number'),
                    country: selected,
                    pickerTheme: pickerTheme,
                    textStyle: textStyle,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: pickerTheme.padding,
                    ),
                  ),
                ),
              ),
            ),
          );
          if (stacked) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: pickerTheme.padding / 1.6,
              children: [button, field],
            );
          }
          return Row(
            spacing: pickerTheme.padding / 1.6,
            children: [
              button,
              Flexible(child: field),
            ],
          );
        },
      ),
    );
  }
}

/// CountryPhoneInput$Extended widget.
/// {@macro country_phone_input}
@internal
class CountryPhoneInput$Extended extends CountryPhoneInput {
  /// {@macro country_phone_input}
  const CountryPhoneInput$Extended({
    // Country selection.
    super.initialCountry,
    super.countryController,
    super.onCountryChanged,

    // Phone editing.
    super.controller,
    super.onChanged,
    super.autofocus,
    super.placeholder,
    super.shouldReplace8,
    super.useCountryFormatting,

    // Picker presentation.
    super.enableOpenPicker,
    super.expand,
    super.isScrollControlled,
    super.shouldCloseOnSwipeDown,
    super.initialChildSize,
    super.minChildSize,
    super.surfaceBuilder,
    super.useHapticFeedback,

    // Country list.
    super.filter,
    super.exclude,
    super.favorites,
    super.showGroup,
    super.showSearch,
    super.showPhoneCode,
    super.showWorldWide,

    super.key,
  });

  @override
  State<CountryPhoneInput$Extended> createState() =>
      _CountryPhoneInput$ExtendedState();
}

/// State for the layout with the country selector above the phone field.
class _CountryPhoneInput$ExtendedState extends State<CountryPhoneInput$Extended>
    with _CountryPhoneInputStateMixin {
  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: pickerTheme.padding / 2,
      vertical: pickerTheme.padding / 1.6,
    );
    final textStyle = pickerTheme.textStyle?.copyWith(
      fontSize: CountryPickerTheme.maybeOf(context)?.textStyle?.fontSize ?? 20,
    );
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: pickerTheme.dividerColor,
    );
    return Material(
      color: pickerTheme.onBackgroundColor,
      child: ValueListenableBuilder(
        valueListenable: _countryController,
        builder: (_, selected, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            divider,

            // --- Country name with flag --- //
            Semantics(
              enabled: widget.enableOpenPicker,
              child: CupertinoButton(
                key: const ValueKey<String>('country_picker_button_extended'),
                padding: EdgeInsets.only(
                  top: pickerTheme.padding / 1.6,
                  left: pickerTheme.padding,
                  bottom: pickerTheme.padding / 1.6,
                  right: pickerTheme.padding / 2,
                ),
                onPressed: widget.enableOpenPicker
                    ? () => showCountryPicker(
                        context: context,
                        exclude: widget.exclude,
                        favorites: widget.favorites,
                        filter: widget.filter,
                        expand: widget.expand,
                        autofocus: widget.autofocus,
                        showGroup: widget.showGroup,
                        showSearch: widget.showSearch,
                        showPhoneCode: widget.showPhoneCode,
                        showWorldWide: widget.showWorldWide,
                        isScrollControlled: widget.isScrollControlled,
                        useHapticFeedback: widget.useHapticFeedback,
                        shouldCloseOnSwipeDown: widget.shouldCloseOnSwipeDown,
                        initialChildSize: widget.initialChildSize,
                        minChildSize: widget.minChildSize,
                        surfaceBuilder: widget.surfaceBuilder,
                        selected: _countryController,
                        onSelect: _handleCountrySelected,
                      )
                    : null,
                child: SizedBox(
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: selected.flagEmoji,
                          style: TextStyle(
                            fontFamily: CountryFlagFontUtil.fontFamily,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${localization.getFormatedCountryNameByCode(selected.countryCode) ?? selected.name}',
                        ),
                      ],
                    ),
                    // Announce the country instead of the emoji flag name.
                    semanticsLabel: _semanticsLabelOf(localization, selected),
                    style: textStyle?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // --- Divider --- //
            SizedBox(
              height: 1,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 1),
                painter: _DividerPainter(pickerTheme: _pickerTheme),
              ),
            ),

            // --- Input with mask --- //
            LayoutBuilder(
              builder: (context, constraints) => Row(
                children: <Widget>[
                  if (selected.phoneCode.isNotEmpty) ...[
                    // --- Phone code --- //
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth / 2,
                      ),
                      child: Padding(
                        padding: padding,
                        child: Text(
                          '+${selected.phoneCode}',
                          style: textStyle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // --- Divider --- //
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        color: pickerTheme.dividerColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                  // --- Phone input --- //
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding.horizontal / 2.5,
                      ),
                      child: _buildPhoneField(
                        key: const ValueKey<String>(
                          'country_phone_input_extended',
                        ),
                        country: selected,
                        pickerTheme: pickerTheme,
                        textStyle: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            divider,
          ],
        ),
      ),
    );
  }
}

/// Paints the unfilled template alongside the field without editing its text.
class _PhoneMask extends SingleChildRenderObjectWidget {
  const _PhoneMask({
    required this.scrollController,
    required this.controller,
    required this.formatter,
    required this.color,
    required super.child,
  });

  /// The scroll controller that keeps the hint aligned with the editor.
  final ScrollController scrollController;

  /// The source of the editor text and composing range.
  final TextEditingController controller;

  /// The source of the formatted text and remaining mask.
  final CountryInputFormatter formatter;

  /// The hint color. A null value disables mask painting.
  final Color? color;

  @override
  _RenderPhoneMask createRenderObject(BuildContext context) => _RenderPhoneMask(
    scrollController: scrollController,
    controller: controller,
    formatter: formatter,
    color: color,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderPhoneMask renderObject) {
    renderObject.update(
      scrollController: scrollController,
      controller: controller,
      formatter: formatter,
      color: color,
    );
  }
}

/// Positions the remaining mask using the descendant [RenderEditable].
class _RenderPhoneMask extends RenderProxyBox {
  _RenderPhoneMask({
    required ScrollController scrollController,
    required TextEditingController controller,
    required CountryInputFormatter formatter,
    required Color? color,
  }) : _scrollController = scrollController,
       _controller = controller,
       _formatter = formatter,
       _color = color;

  /// The editor's horizontal scroll notifications.
  ScrollController _scrollController;

  /// The text and composition changes that require repainting the hint.
  TextEditingController _controller;

  /// Supplies the remaining mask for the current editing value.
  CountryInputFormatter _formatter;

  /// The color of the hint, or null when it is hidden.
  Color? _color;

  /// Updates the paint inputs and rebinds listeners when controllers change.
  void update({
    required ScrollController scrollController,
    required TextEditingController controller,
    required CountryInputFormatter formatter,
    required Color? color,
  }) {
    if (_controller != controller || _scrollController != scrollController) {
      // Both controllers are owned by the field's state and keep their identity
      // across rebuilds.
      // coverage:ignore-start
      if (attached) _removeListeners();
      _controller = controller;
      _scrollController = scrollController;
      if (attached) _addListeners();
      // coverage:ignore-end
    }
    _formatter = formatter;
    _color = color;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _addListeners();
  }

  @override
  void detach() {
    _removeListeners();
    super.detach();
  }

  void _addListeners() {
    _controller.addListener(markNeedsPaint);
    _scrollController.addListener(markNeedsPaint);
  }

  void _removeListeners() {
    _controller.removeListener(markNeedsPaint);
    _scrollController.removeListener(markNeedsPaint);
  }

  static RenderEditable? _findEditable(RenderObject object) {
    if (object is RenderEditable) return object;
    RenderEditable? editable;
    object.visitChildren((child) {
      editable ??= _findEditable(child);
    });
    return editable;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final child = this.child;
    final color = _color;
    final hint = _formatter.maskHint;
    final value = _controller.value;
    if (child == null ||
        color == null ||
        hint == null ||
        hint.isEmpty ||
        !value.composing.isCollapsed ||
        value.text != _formatter.getMaskedText()) {
      return;
    }

    final editable = _findEditable(child);
    if (editable == null || !editable.hasSize) return;
    final origin = offset + editable.localToGlobal(Offset.zero, ancestor: this);
    final bounds = (origin & editable.size).intersect(offset & size);
    if (bounds.isEmpty) return;

    // The collapsed selection endpoint includes the horizontal scroll offset.
    final end = editable
        .getEndpointsForSelection(
          TextSelection.collapsed(offset: value.text.length),
        )
        .single
        .point;
    final baseline = editable.getDryBaseline(
      editable.constraints,
      TextBaseline.alphabetic,
    );
    if (baseline == null || origin.dx + end.dx >= bounds.right) return;

    final style = editable.text?.style ?? const TextStyle();
    final painter = TextPainter(
      text: TextSpan(
        text: hint,
        style: style.copyWith(foreground: Paint()..color = color),
      ),
      textDirection: editable.textDirection,
      textScaler: editable.textScaler,
      locale: editable.locale,
      strutStyle: editable.strutStyle,
      textHeightBehavior: editable.textHeightBehavior,
      maxLines: 1,
    )..layout();

    final canvas = context.canvas
      ..save()
      ..clipRect(bounds);
    painter.paint(
      canvas,
      origin +
          Offset(
            end.dx,
            baseline -
                painter.computeDistanceToActualBaseline(
                  TextBaseline.alphabetic,
                ),
          ),
    );
    canvas.restore();
    painter.dispose();
  }
}

/// Paints the divider under the extended phone field.
/// {@macro country_phone_input}
class _DividerPainter extends CustomPainter {
  /// Creates a [_DividerPainter].
  _DividerPainter({required this.pickerTheme}) : super(repaint: pickerTheme);

  /// Notifier for country picker theme.
  final ValueNotifier<CountryPickerTheme?> pickerTheme;

  /// The color to fill in the background of the rounded rectangle.
  Color? get dividerColor => pickerTheme.value?.dividerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset.zero,
      const Offset(22, 0),
      const Offset(30, 8),
      const Offset(38, 0),
      Offset(size.width, 0),
    ];
    final paint = Paint()
      ..color = dividerColor ?? Colors.black
      ..strokeCap = .round
      ..strokeWidth = 1;
    canvas.drawPoints(ui.PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Background painter for [CountryPhoneInput].
/// {@macro country_phone_input}
class _BackgroundPainter extends CustomPainter {
  /// Creates a [CustomPaint] that paints a rounded rectangle.
  const _BackgroundPainter({required this.pickerTheme})
    : super(repaint: pickerTheme);

  /// Notifier for country picker theme.
  final ValueNotifier<CountryPickerTheme?> pickerTheme;

  /// The color to fill in the background of the rounded rectangle.
  Color? get color => pickerTheme.value?.onBackgroundColor;

  /// The radius of the rounded corners of the rectangle.
  double? get radius => pickerTheme.value?.baseCornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveRadius = Radius.circular(radius ?? 10);
    final paint = Paint()..color = color ?? Colors.grey;
    final rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      effectiveRadius,
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}
