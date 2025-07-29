import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traccar_client/constants/colors.dart';
import 'package:traccar_client/screens/widgets/start_ellipse_text.dart';
import 'sign_pad.dart';
import 'dart:io';

class DynamicFormWidget extends StatefulWidget {
  final List<Map<String, dynamic>> formSchema;

  const DynamicFormWidget({super.key, required this.formSchema});

  @override
  State<DynamicFormWidget> createState() => DynamicFormWidgetState();
}

class DynamicFormWidgetState extends State<DynamicFormWidget> {
  final Map<String, dynamic> _formValues = {};
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          widget.formSchema.map((field) {
            final type = field['type'];
            final id = field['id'];
            final label = field['label'] ?? id;

            switch (type) {
              case 'text':
                return _buildTextField(id, label);
              case 'toggle':
                return _buildToggle(id, label);
              case 'dropdown':
                return _buildDropdown(id, label, field['options']);
              case 'photo':
                return _buildPhotoPicker(id, label);
              case 'signature':
                return _buildSignaturePad(id, label);
              default:
                return const SizedBox.shrink();
            }
          }).toList(),
    );
  }

  Widget _buildTextField(String id, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) {
            _formValues[id] = {'type': 'text', 'value': value};
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: label,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildToggle(String id, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        Switch(
          value: _formValues[id]?['value'] ?? false,
          onChanged: (value) {
            setState(() {
              _formValues[id] = {'type': 'toggle', 'value': value};
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String id, String label, List options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        DropdownButtonFormField(
          value: _formValues[id]?['value'],
          items:
              options
                  .map<DropdownMenuItem<String>>(
                    (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
                  )
                  .toList(),
          onChanged: (value) {
            _formValues[id] = {'type': 'dropdown', 'value': value};
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoPicker(String id, String label) {
    final file = _formValues[id]?['value'] as File?;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),

              if (file != null)
                StartEllipsisText(
                  file.path.split(Platform.pathSeparator).last,
                  color: AppColors.primaryColor,
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: () async {
            final picked = await _picker.pickImage(source: ImageSource.camera);
            if (picked != null) {
              setState(() {
                _formValues[id] = {'type': 'photo', 'value': File(picked.path)};
              });
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSignaturePad(String id, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignaturePad(
          label: label,
          onSigned: (imageFile) {
            _formValues[id] = {'type': 'photo', 'value': imageFile};
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Map<String, dynamic> getFormValues() => _formValues;
}
