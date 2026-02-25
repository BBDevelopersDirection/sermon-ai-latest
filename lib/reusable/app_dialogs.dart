import 'package:flutter/material.dart';
import 'package:sermon_tv/utils/app_color.dart';

class MyAppDialogs {
  void info_dialog({
    required BuildContext context,
    required String title,
    required String body,
    Function? onOkCallback,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(body, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              if (onOkCallback != null) {
                onOkCallback();
              }
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void phoneNumberDialog({
    required BuildContext context,
    required List<String> numbers,
    required Function(String) onNumberSelected,
    String title = "Select Number",
  }) {
    // Keep only last 10 digits and remove duplicates
    numbers = numbers
        .map((n) {
          String digits = n.replaceAll(RegExp(r'\D'), '');
          return digits.length >= 10
              ? digits.substring(digits.length - 10)
              : digits;
        })
        .toSet()
        .toList();

    if (numbers.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("No phone numbers available.")),
      // );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: MyAppColor.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: numbers.length > 3 ? 200 : numbers.length * 60.0,
          child: ListView.builder(
            itemCount: numbers.length,
            itemBuilder: (_, index) {
              return ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFFD89118)),
                title: Text(
                  numbers[index],
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                onTap: () {
                  onNumberSelected(numbers[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white, // Text color
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ), // Red border
                  elevation: 4, // Shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "None of the above",
                  style: TextStyle(
                    color: Colors.black, // Text color
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void conf_dialog({
    required BuildContext context,
    required String title,
    required String body,
    Function? onOkCallback,
    Function? onCancelCallback,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              if (onCancelCallback != null) {
                onCancelCallback();
              }
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              if (onOkCallback != null) {
                onOkCallback();
              }
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
