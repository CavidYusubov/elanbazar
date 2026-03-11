import 'package:flutter/material.dart';

import '../../models/ad_create_attribute.dart';

class AdCreateAttributeField extends StatelessWidget {
  final AdCreateAttribute attribute;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const AdCreateAttributeField({
    super.key,
    required this.attribute,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = attribute.required ? '${attribute.name} *' : attribute.name;

    switch (attribute.type) {
      case 'select':
        return _DarkDropdownField(
          label: label,
          value: value?.toString(),
          items: attribute.options
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.label),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );

      case 'multiselect':
        return _MultiChipField(
          label: label,
          options: attribute.options,
          values: (value as List?)?.map((e) => e.toString()).toList() ?? const [],
          onChanged: onChanged,
        );

      case 'number':
        return _DarkTextField(
          label: label,
          value: value?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        );

      case 'boolean':
      case 'bool':
        return _DarkDropdownField(
          label: label,
          value: value?.toString(),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Bəli')),
            DropdownMenuItem(value: '0', child: Text('Xeyr')),
          ],
          onChanged: onChanged,
        );

      case 'date':
        return _DarkTextField(
          label: label,
          value: value?.toString() ?? '',
          hintText: 'YYYY-MM-DD',
          onChanged: onChanged,
        );

      default:
        return _DarkTextField(
          label: label,
          value: value?.toString() ?? '',
          onChanged: onChanged,
        );
    }
  }
}

class _DarkTextField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? hintText;

  const _DarkTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.hintText,
  });

  @override
  State<_DarkTextField> createState() => _DarkTextFieldState();
}

class _DarkTextFieldState extends State<_DarkTextField> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _DarkTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_c.text != widget.value) {
      _c.text = widget.value;
      _c.selection = TextSelection.fromPosition(
        TextPosition(offset: _c.text.length),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _DarkDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DarkDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final values = items.map((e) => e.value).whereType<String>().toSet();
    final safeValue = value != null && values.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      dropdownColor: const Color(0xff1a1d24),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
      iconEnabledColor: Colors.white70,
    );
  }
}

class _MultiChipField extends StatelessWidget {
  final String label;
  final List<AdCreateAttributeOption> options;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const _MultiChipField({
    required this.label,
    required this.options,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final selected = values.contains(option.id);

          return FilterChip(
            label: Text(option.label),
            selected: selected,
            onSelected: (v) {
              final next = [...values];
              if (v) {
                if (!next.contains(option.id)) next.add(option.id);
              } else {
                next.remove(option.id);
              }
              onChanged(next);
            },
            selectedColor: const Color(0xff12bf82),
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: const Color(0xff20242d),
            side: BorderSide(
              color: selected ? const Color(0xff12bf82) : Colors.white12,
            ),
          );
        }).toList(),
      ),
    );
  }
}