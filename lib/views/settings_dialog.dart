import 'dart:async';

import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final Future<List<int>> Function() readTrim;
  final Future<void> Function(int left, int right) writeTrim;
  final Stream<bool> connected;

  const SettingsDialog({
    required this.readTrim,
    required this.writeTrim,
    required this.connected,
    super.key,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  StreamSubscription<bool>? _connection;
  bool _loading = true;
  bool _saving = false;
  bool _connected = true;
  String? _error;
  int _left = 100;
  int _right = 100;

  @override
  void initState() {
    super.initState();
    _connection = widget.connected.listen((connected) {
      if (!mounted) return;
      setState(() {
        _connected = connected;
        if (!connected) _error = 'Device disconnected. Reconnect to edit settings.';
      });
    });
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trim = await widget.readTrim();
      if (!mounted || !_connected) return;
      setState(() {
        _left = trim[0];
        _right = trim[1];
        _loading = false;
      });
    } catch (_) {
      if (!mounted || !_connected) return;
      setState(() {
        _error = 'Could not read motor trims. Check the connection and device firmware.';
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.writeTrim(_left, _right);
      if (!mounted || !_connected) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted || !_connected) return;
      setState(() {
        _saving = false;
        _error = 'Could not save motor trims. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _connection?.cancel();
    super.dispose();
  }

  Widget _trimSlider(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value%'),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '$value%',
          semanticFormatterCallback: (value) => '$label: ${value.round()}%',
          onChanged: _connected && !_saving
              ? (value) => setState(() => onChanged(value.round()))
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Motor trim', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Reduce the faster wheel to correct drift. Trims reset to 100% when the device restarts.'),
              const SizedBox(height: 16),
              if (_loading && _error == null)
                const Center(child: CircularProgressIndicator()),
              if (!_loading) ...[
                _trimSlider('Left motor', _left, (value) => _left = value),
                _trimSlider('Right motor', _right, (value) => _right = value),
                TextButton(
                  onPressed: _connected && !_saving
                      ? () => setState(() { _left = 100; _right = 100; })
                      : null,
                  child: const Text('Reset trims to 100%'),
                ),
              ],
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                if (_connected && _loading)
                  TextButton(onPressed: _load, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _connected && !_loading && !_saving ? _save : null,
          child: Text(_saving ? 'Saving…' : 'Save'),
        ),
      ],
    );
  }
}
