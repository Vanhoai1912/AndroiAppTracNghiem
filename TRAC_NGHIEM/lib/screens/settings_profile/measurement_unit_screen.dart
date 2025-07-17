import 'package:flutter/material.dart';

class MeasurementUnitScreen extends StatefulWidget {
  const MeasurementUnitScreen({super.key});

  @override
  State<MeasurementUnitScreen> createState() => _MeasurementUnitScreenState();
}

class _MeasurementUnitScreenState extends State<MeasurementUnitScreen> {
  String selectedFormat = 'dd/MM/yyyy - Ngày/Tháng/Năm';

  final List<String> dateFormats = [
    'dd/MM/yyyy - Ngày/Tháng/Năm',
    'MM/dd/yyyy - Tháng/Ngày/Năm',
    'yyyy/MM/dd - Năm/Tháng/Ngày',
  ];

  void _saveSetting() {
    // TODO: Lưu setting vào SharedPreferences hoặc DB
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu định dạng ngày tháng')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn vị đo"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Định dạng hiển thị Ngày tháng năm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedFormat,
              items: dateFormats.map((format) {
                return DropdownMenuItem<String>(
                  value: format,
                  child: Text(format),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedFormat = newValue!;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _saveSetting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0033CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Lưu"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
