// lib/widgets/qr_fields_widget.dart
import 'package:flutter/material.dart';

class QrFieldsWidget extends StatelessWidget {
  final String selectedQrType;
  final TextEditingController contentController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final TextEditingController urlController;
  final TextEditingController eventNameController;
  final TextEditingController locationController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController descriptionController;
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final TextEditingController encryptionTypeController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final Future<void> Function(BuildContext, TextEditingController) selectDate;

  const QrFieldsWidget({
    Key? key,
    required this.selectedQrType,
    required this.contentController,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.subjectController,
    required this.messageController,
    required this.urlController,
    required this.eventNameController,
    required this.locationController,
    required this.startDateController,
    required this.endDateController,
    required this.descriptionController,
    required this.ssidController,
    required this.passwordController,
    required this.encryptionTypeController,
    required this.latitudeController,
    required this.longitudeController,
    required this.selectDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (selectedQrType) {
      case 'url':
        return TextFormField(
          controller: urlController,
          decoration: const InputDecoration(labelText: 'URL'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Enter a URL' : null,
        );
      case 'contact':
        return Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter name' : null,
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null,
            ),
          ],
        );
      case 'email':
        return Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null,
            ),
            TextFormField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextFormField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        );
      case 'sms':
        return Column(
          children: [
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null,
            ),
            TextFormField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        );
      case 'event':
        return Column(
          children: [
            TextFormField(
              controller: eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Enter event name' : null,
            ),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: startDateController,
              decoration: const InputDecoration(labelText: 'Start Date'),
              readOnly: true,
              onTap: () => selectDate(context, startDateController),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Select a start date' : null,
            ),
            TextFormField(
              controller: endDateController,
              decoration: const InputDecoration(labelText: 'End Date'),
              readOnly: true,
              onTap: () => selectDate(context, endDateController),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Select an end date' : null,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        );
      case 'wifi':
        return Column(
          children: [
            TextFormField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'SSID'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter SSID' : null,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null,
            ),
            DropdownButtonFormField<String>(
              value: encryptionTypeController.text.isEmpty
                  ? 'WPA'
                  : encryptionTypeController.text,
              decoration: const InputDecoration(labelText: 'Encryption Type'),
              items: const [
                DropdownMenuItem(value: 'WPA', child: Text('WPA')),
                DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                DropdownMenuItem(value: 'nopass', child: Text('No Password')),
              ],
              onChanged: (v) {
                if (v != null) encryptionTypeController.text = v;
              },
            ),
          ],
        );
      case 'geo':
        return Column(
          children: [
            TextFormField(
              controller: latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter latitude' : null,
            ),
            TextFormField(
              controller: longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter longitude' : null,
            ),
          ],
        );
      case 'text':
      default:
        return TextFormField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Text'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Enter text' : null,
        );
    }
  }
}
