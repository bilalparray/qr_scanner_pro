import 'package:flutter/material.dart';

/// Barcode category enum with a display name and icon.
enum BarcodeCategory {
  qrCodes('QR Codes', Icons.qr_code_2),
  oneDimensional('1D Linear', Icons.view_stream),
  twoDimensional('2D Matrix', Icons.grid_4x4),
  postal('Postal', Icons.local_post_office),
  specialized('Specialized', Icons.settings);

  const BarcodeCategory(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Barcode code types with metadata.
enum BarcodeCodeType {
  // QR Codes
  qrCode(
    'QR Code',
    'Standard QR Code',
    BarcodeCategory.qrCodes,
    'https://flutter.dev',
  ),
  qrCodeWiFi(
    'QR WiFi',
    'WiFi credentials QR',
    BarcodeCategory.qrCodes,
    'MyWiFi',
  ),
  microQR(
    'Micro QR',
    'Compact QR for small data',
    BarcodeCategory.qrCodes,
    '12345',
  ),
  qrCodeSms(
    'QR SMS',
    'SMS message QR',
    BarcodeCategory.qrCodes,
    'SMSTO:+1234567890:Hello from QR!',
  ),
  qrCodeEmail(
    'QR Email',
    'Email QR',
    BarcodeCategory.qrCodes,
    'mailto:example@example.com?subject=Hello&body=This%20is%20a%20test',
  ),
  qrCodePDF(
    'QR PDF',
    'PDF document link QR',
    BarcodeCategory.qrCodes,
    'https://www.example.com/myfile.pdf',
  ),
  qrCodeMultiURl(
    'QR Multi-URL',
    'Multiple URLs in one QR (comma-separated or custom)',
    BarcodeCategory.qrCodes,
    'https://example1.com,https://example2.com',
  ),
  qrCodeVCard(
    'QR Contact',
    'Contact info QR',
    BarcodeCategory.qrCodes,
    '''
BEGIN:VCARD
VERSION:3.0
N:Doe;Jane;;;
FN:Jane Doe
ORG:Company;
TEL;TYPE=WORK,VOICE:+1234567890
EMAIL:jane.doe@example.com
END:VCARD
''',
  ),
  qrCodeGeo(
    'QR Geo',
    'Geolocation QR',
    BarcodeCategory.qrCodes,
    'geo:37.7749,-122.4194',
  ),
  qrCodeAPP(
    'QR App',
    'App download or deep link QR',
    BarcodeCategory.qrCodes,
    'https://play.google.com/store/apps/details?id=com.example.app',
  ),
  qrCodePhone(
    'QR Phone',
    'Phone call QR',
    BarcodeCategory.qrCodes,
    'TEL:+1234567890',
  ),

  // 1D Linear Barcodes
  code128(
    'Code 128',
    'High-density linear barcode',
    BarcodeCategory.oneDimensional,
    'Hello World',
  ),
  code128A(
    'Code 128A',
    'Uppercase and control chars',
    BarcodeCategory.oneDimensional,
    'HELLO123',
  ),
  code128B(
    'Code 128B',
    'ASCII character set',
    BarcodeCategory.oneDimensional,
    'Hello123!',
  ),
  code128C(
    'Code 128C',
    'Numeric pairs only',
    BarcodeCategory.oneDimensional,
    '123456',
  ),
  code39(
    'Code 39',
    'Alphanumeric barcode',
    BarcodeCategory.oneDimensional,
    'CODE39',
  ),
  code39Extended(
    'Code 39 Ext',
    'Extended ASCII Code 39',
    BarcodeCategory.oneDimensional,
    'Code39+',
  ),
  code93(
    'Code 93',
    'Compact alphanumeric',
    BarcodeCategory.oneDimensional,
    'CODE93',
  ),
  code93Extended(
    'Code 93 Ext',
    'Extended ASCII Code 93',
    BarcodeCategory.oneDimensional,
    'Code93+',
  ),
  ean8(
    'EAN-8',
    '7-digit product code',
    BarcodeCategory.oneDimensional,
    '1234567',
  ),
  ean13(
    'EAN-13',
    '13-digit product code',
    BarcodeCategory.oneDimensional,
    '1234567890123',
  ),
  upcA(
    'UPC-A',
    '12-digit Universal Product Code',
    BarcodeCategory.oneDimensional,
    '123456789012',
  ),
  upcE('UPC-E', 'Compressed UPC', BarcodeCategory.oneDimensional, '01234567'),
  codabar(
    'Codabar',
    'Self-checking barcode',
    BarcodeCategory.oneDimensional,
    'A123456B',
  ),
  itf(
    'ITF',
    'Interleaved 2 of 5',
    BarcodeCategory.oneDimensional,
    '1234567890',
  ),
  itf14(
    'ITF-14',
    '14-digit shipping code',
    BarcodeCategory.oneDimensional,
    '12345678901234',
  ),

  // 2D Barcodes
  dataMatrix(
    'Data Matrix',
    '2D matrix barcode',
    BarcodeCategory.twoDimensional,
    'Data Matrix Test',
  ),
  pdf417(
    'PDF417',
    'Portable Data File',
    BarcodeCategory.twoDimensional,
    'PDF417 Example',
  ),
  aztec(
    'Aztec Code',
    '2D barcode with bullseye',
    BarcodeCategory.twoDimensional,
    'Aztec Test',
  ),
  // maxiCode(
  //   'MaxiCode',
  //   'Fixed-size postal barcode',
  //   BarcodeCategory.twoDimensional,
  //   '12345',
  // ),

  // Postal Barcodes
  // postnet('POSTNET', 'US Postal Service', BarcodeCategory.postal, '12345'),
  // planet(
  //   'PLANET',
  //   'US Postal tracking',
  //   BarcodeCategory.postal,
  //   '123456789012',
  // ),
  // australianPost(
  //   'AU Post',
  //   'Australian Post barcode',
  //   BarcodeCategory.postal,
  //   '1234567890',
  // ),
  // royalMail(
  //   'Royal Mail',
  //   'UK Royal Mail barcode',
  //   BarcodeCategory.postal,
  //   'SN34RD1A',
  // ),

  // Specialized
  gs1_128(
    'GS1-128',
    'Supply chain barcode',
    BarcodeCategory.specialized,
    '01123456789012',
  ),
  pharmacode(
    'Pharmacode',
    'Pharmaceutical barcode',
    BarcodeCategory.specialized,
    '12345',
  ),
  pzn('PZN', 'German pharmaceutical', BarcodeCategory.specialized, '1234567');

  const BarcodeCodeType(
    this.displayName,
    this.description,
    this.category,
    this.exampleData,
  );

  final String displayName;
  final String description;
  final BarcodeCategory category;
  final String exampleData;
}

/// Extension on BarcodeCodeType for convenience getters
extension BarcodeCodeTypeExtensions on BarcodeCodeType {
  bool get isQR => [
        BarcodeCodeType.qrCode,
        BarcodeCodeType.qrCodeWiFi,
        BarcodeCodeType.microQR,
        BarcodeCodeType.qrCodeSms,
        BarcodeCodeType.qrCodeEmail,
        BarcodeCodeType.qrCodePDF,
        BarcodeCodeType.qrCodeMultiURl,
        BarcodeCodeType.qrCodeVCard,
        BarcodeCodeType.qrCodeGeo,
        BarcodeCodeType.qrCodeAPP,
        BarcodeCodeType.qrCodePhone,
      ].contains(this);

  bool get is2D => [
        BarcodeCodeType.qrCode,
        BarcodeCodeType.qrCodeWiFi,
        BarcodeCodeType.microQR,
        BarcodeCodeType.qrCodeSms,
        BarcodeCodeType.qrCodeEmail,
        BarcodeCodeType.qrCodePDF,
        BarcodeCodeType.qrCodeMultiURl,
        BarcodeCodeType.qrCodeVCard,
        BarcodeCodeType.qrCodeGeo,
        BarcodeCodeType.qrCodeAPP,
        BarcodeCodeType.qrCodePhone,
        BarcodeCodeType.dataMatrix,
        BarcodeCodeType.pdf417,
        BarcodeCodeType.aztec,
        // BarcodeCodeType.maxiCode,
      ].contains(this);
}

/// Represents input field configuration for barcodes.
class BarcodeInputField {
  final String key;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? pattern;
  final bool isRequired;
  final List<String>? dropdownOptions;

  const BarcodeInputField({
    required this.key,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.pattern,
    this.isRequired = true,
    this.dropdownOptions,
  });

  /// Returns a list of input fields required for the given barcode type.
  static List<BarcodeInputField> configForType(BarcodeCodeType type) {
    switch (type) {
      // QR Codes
      case BarcodeCodeType.qrCode:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Enter text, URL, or any data',
          )
        ];
      case BarcodeCodeType.qrCodePDF:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'PDF Link',
            hint: 'Enter PDF Link',
          )
        ];
      case BarcodeCodeType.qrCodeWiFi:
        return const [
          BarcodeInputField(
              key: 'ssid', label: 'WiFi SSID', hint: 'MyWiFiNetwork'),
          BarcodeInputField(
              key: 'password', label: 'Password', hint: 'WiFi password'),
          BarcodeInputField(
            key: 'security',
            label: 'Security Type',
            hint: 'WPA',
            dropdownOptions: ['WPA', 'WEP', 'nopass'],
          ),
        ];
      case BarcodeCodeType.microQR:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Numeric Data',
            hint: '12345 (max 5 digits)',
            keyboardType: TextInputType.number,
            maxLength: 5,
            pattern: r'^\d{1,5}$',
          ),
        ];
      case BarcodeCodeType.qrCodeSms:
        return const [
          BarcodeInputField(
              key: 'phone',
              label: 'Phone Number',
              hint: '+1234567890',
              keyboardType: TextInputType.phone),
          BarcodeInputField(
              key: 'message',
              label: 'Message',
              hint: 'Hello from QR',
              isRequired: false),
        ];
      case BarcodeCodeType.qrCodeEmail:
        return const [
          BarcodeInputField(
              key: 'email',
              label: 'Email Address',
              hint: 'example@example.com',
              pattern: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              keyboardType: TextInputType.emailAddress),
          BarcodeInputField(
              key: 'subject',
              label: 'Subject',
              hint: 'Hello',
              isRequired: false),
          BarcodeInputField(
              key: 'body',
              label: 'Body',
              hint: 'This is a test',
              isRequired: false),
        ];
      case BarcodeCodeType.qrCodeVCard:
        return const [
          BarcodeInputField(key: 'name', label: 'Full Name', hint: 'Jane Doe'),
          BarcodeInputField(
              key: 'phone',
              label: 'Phone',
              hint: '+1234567890',
              keyboardType: TextInputType.phone),
          BarcodeInputField(
              key: 'email',
              label: 'Email',
              hint: 'jane.doe@example.com',
              pattern: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              isRequired: false,
              keyboardType: TextInputType.emailAddress),
          BarcodeInputField(
              key: 'organization',
              label: 'Organization',
              hint: 'Company',
              isRequired: false),
        ];
      case BarcodeCodeType.qrCodeGeo:
        return const [
          BarcodeInputField(
              key: 'latitude',
              label: 'Latitude',
              hint: '37.7749',
              keyboardType: TextInputType.number),
          BarcodeInputField(
              key: 'longitude',
              label: 'Longitude',
              hint: '-122.4194',
              keyboardType: TextInputType.number),
        ];
      case BarcodeCodeType.qrCodeAPP:
        return const [
          BarcodeInputField(
              key: 'url',
              label: 'App URL or Deep Link',
              hint:
                  'https://play.google.com/store/apps/details?id=com.qayham.qrscanner',
              keyboardType: TextInputType.url),
        ];
      case BarcodeCodeType.qrCodePhone:
        return const [
          BarcodeInputField(
              key: 'phone',
              label: 'Phone Number',
              hint: '+1234567890',
              keyboardType: TextInputType.phone),
        ];

      // 1D Linear Barcodes
      case BarcodeCodeType.code128:
      case BarcodeCodeType.code128B:
        return const [
          BarcodeInputField(key: 'data', label: 'Data', hint: 'Any ASCII text'),
        ];
      case BarcodeCodeType.code128A:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'UPPERCASE and numbers only',
            pattern: r'^[A-Z0-9\s]*$',
          ),
        ];
      case BarcodeCodeType.code128C:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Numeric Data',
            hint: 'Even number of digits (e.g., 123456)',
            keyboardType: TextInputType.number,
            pattern: r'^\d*$',
          ),
        ];
      case BarcodeCodeType.code39:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'A-Z, 0-9, and symbols (-.\$/+%)',
            pattern: r'^[A-Z0-9\-\.\$\/\+\%\s]*$',
          ),
        ];
      case BarcodeCodeType.code39Extended:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Extended ASCII characters',
          ),
        ];
      case BarcodeCodeType.code93:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'A-Z, 0-9, and symbols',
            pattern: r'^[A-Z0-9\-\.\$\/\+\%\s]*$',
          ),
        ];
      case BarcodeCodeType.code93Extended:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Extended ASCII characters',
          ),
        ];
      case BarcodeCodeType.ean8:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'EAN-8 Code',
            hint: '8 digits (e.g., 1234567)',
            keyboardType: TextInputType.number,
            maxLength: 7,
            pattern: r'^\d{7}$',
          ),
        ];
      case BarcodeCodeType.ean13:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'EAN-13 Code',
            hint: '13 digits (e.g., 123456789012)',
            keyboardType: TextInputType.number,
            maxLength: 12, // Only 12 digits, 13th calculated
            pattern: r'^\d{12}$',
          ),
        ];

      case BarcodeCodeType.upcA:
        return const [
          // For generator fields:
          BarcodeInputField(
            key: 'data',
            label: 'UPC-A Code',
            hint: '11 digits (e.g., 03600029145)',
            keyboardType: TextInputType.number,
            maxLength: 11,
            pattern: r'^\d{11}$',
          ),
        ];

      case BarcodeCodeType.upcE:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'UPC-E Code',
            hint: '6 digits (e.g., 0123456)',
            keyboardType: TextInputType.number,
            maxLength: 6,
            pattern: r'^\d{6}$',
          ),
        ];

      case BarcodeCodeType.codabar:
        return const [
          BarcodeInputField(
              key: 'data',
              label: 'Codabar Data',
              hint: 'e.g., 123456',
              pattern: r'^[0-9\-\$\:\/\.\+]+$'),
        ];
      case BarcodeCodeType.itf:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'ITF Data',
            hint: 'Even number of digits',
            keyboardType: TextInputType.number,
            pattern: r'^(\d{2})+$',
          ),
        ];
      case BarcodeCodeType.itf14:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'ITF-14 Code',
            hint: '14 digits (e.g., 12345678901234)',
            keyboardType: TextInputType.number,
            maxLength: 14,
            pattern: r'^\d{14}$',
          ),
        ];

      // 2D Barcodes
      case BarcodeCodeType.dataMatrix:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Any text or binary data',
          ),
        ];
      case BarcodeCodeType.pdf417:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Large data capacity',
          ),
        ];
      case BarcodeCodeType.aztec:
        return const [
          BarcodeInputField(
              key: 'data', label: 'Data', hint: 'Up to 3750 bytes'),
        ];
      // case BarcodeCodeType.maxiCode:
      //   return const [
      //     BarcodeInputField(
      //         key: 'primaryMessage', label: 'Postal Code', hint: '12345'),
      //     BarcodeInputField(key: 'country', label: 'Country Code', hint: 'US'),
      //     BarcodeInputField(
      //         key: 'serviceClass', label: 'Service Class', hint: '001'),
      //   ];

      // Postal Barcodes
      // case BarcodeCodeType.postnet:
      //   return const [
      //     BarcodeInputField(
      //       key: 'zipCode',
      //       label: 'ZIP Code',
      //       hint: '5 or 9 digit ZIP (e.g., 12345)',
      //       keyboardType: TextInputType.number,
      //       pattern: r'^\d{5}(\d{4})?$',
      //     ),
      //   ];
      // case BarcodeCodeType.planet:
      //   return const [
      //     BarcodeInputField(
      //       key: 'trackingNumber',
      //       label: 'Tracking Number',
      //       hint: '12-digit tracking number',
      //       keyboardType: TextInputType.number,
      //       maxLength: 12,
      //       pattern: r'^\d{12}$',
      //     ),
      //   ];
      // case BarcodeCodeType.australianPost:
      //   return const [
      //     BarcodeInputField(
      //       key: 'sortingCode',
      //       label: 'Sorting Code',
      //       hint: '8-digit sorting code',
      //       keyboardType: TextInputType.number,
      //       maxLength: 8,
      //       pattern: r'^\d{8}$',
      //     ),
      //     BarcodeInputField(
      //       key: 'customerInfo',
      //       label: 'Customer Info',
      //       hint: 'Optional customer information',
      //       isRequired: false,
      //     ),
      //   ];
      // case BarcodeCodeType.royalMail:
      //   return const [
      //     BarcodeInputField(
      //       key: 'postCode',
      //       label: 'Post Code',
      //       hint: 'UK postcode (e.g., SW1A 1AA)',
      //       pattern: r'^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][A-Z]{2}$',
      //     ),
      //   ];

      // Specialized
      case BarcodeCodeType.gs1_128:
        return const [
          BarcodeInputField(
            key: 'applicationId',
            label: 'Application ID',
            hint: '01 (for GTIN)',
            pattern: r'^\d{2,4}$',
          ),
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Data corresponding to AI',
          ),
        ];
      // case BarcodeCodeType.pharmacode:
      //   return const [
      //     BarcodeInputField(
      //       key: 'number',
      //       label: 'Pharmacode Number',
      //       hint: '3-131070',
      //       keyboardType: TextInputType.number,
      //       pattern: r'^([3-9]|[1-9][0-9]{1,4}|13[0-1][0-9]{3}|13107[0-9])$',
      //     ),
      //   ];
      // case BarcodeCodeType.pzn:
      //   return const [
      //     BarcodeInputField(
      //       key: 'pznNumber',
      //       label: 'PZN Number',
      //       hint: '7-digit pharmaceutical number',
      //       keyboardType: TextInputType.number,
      //       maxLength: 7,
      //       pattern: r'^\d{7}$',
      //     ),
      //   ];

      default:
        return const [
          BarcodeInputField(
            key: 'data',
            label: 'Data',
            hint: 'Enter barcode data',
          ),
        ];
    }
  }
}

/// Validation result class for input validation.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  static const ValidationResult valid = ValidationResult(isValid: true);

  static ValidationResult invalid(String message) {
    return ValidationResult(isValid: false, errorMessage: message);
  }
}
