import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_registeration_app/providers/db_provider.dart'; // adjust path if needed

Future<void> showQuantityDialog(
    BuildContext context,
    int studentSno,
    String studentName,
    String columnName,
    ) async {
  int count = 1;
  final TextEditingController textController = TextEditingController();
  String? selectedChip;
  String? selectedPara;

  void updateNumber() {
    final current = textController.text.split(',').map((e) => e.trim()).toList();
    if (current.isNotEmpty) {
      current[0] = count.toString();
      textController.text = current.join(', ');
    } else {
      textController.text = count.toString();
    }
  }

  void addItem(String item) {
    final current = textController.text.split(',').map((e) => e.trim()).toList();
    if (current.isEmpty) {
      textController.text = "$count, $item";
    } else {
      if (!current.contains(item)) {
        current.add(item);
        textController.text = current.join(', ');
      }
    }
  }

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "$studentName - $columnName",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextFormField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Number and selected items",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            textController.clear();
                            count = 1;
                            selectedChip = null;
                            selectedPara = null;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (count > 1) {
                            setState(() {
                              count--;
                              updateNumber();
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                      ),
                      Text(
                        "$count",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            count++;
                            updateNumber();
                          });
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Choice Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      "Line",
                      "Page",
                      "Ruku",
                      "Ayat",
                      "Quarter",
                      "Half",
                      "Full",
                      "Memory",
                      "Pona",
                      "Sawa",
                    ].map((type) {
                      final isSelected = selectedChip == type;
                      return ChoiceChip(
                        label: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blue,
                        backgroundColor: Colors.grey.shade200,
                        onSelected: (_) {
                          setState(() {
                            selectedChip = type;
                            addItem(type);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Para Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Para",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedPara,
                    items: List.generate(
                      30,
                          (index) => DropdownMenuItem(
                        value: "Para ${index + 1}",
                        child: Text("Para ${index + 1}"),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPara = value;
                          addItem(value);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              Consumer<DBProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final text = textController.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Please enter lesson details"),
                          ),
                        );
                        return;
                      }

                      bool success = await provider.saveLessonDetails(
                        studentSno,
                        text,
                        columnName,
                      );

                      Navigator.pop(context);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("$columnName saved successfully"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Failed to save $columnName"),
                          ),
                        );
                      }
                    },

                    child: const Text("Save"),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}
