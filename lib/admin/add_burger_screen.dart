import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/burger_provider.dart';
import '../models/burger.dart';

class AddBurgerScreen extends StatefulWidget {
  const AddBurgerScreen({super.key});

  @override
  State<AddBurgerScreen> createState() => _AddBurgerScreenState();
}

class _AddBurgerScreenState extends State<AddBurgerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  
  XFile? _pickedImage;
  String _selectedCategory = 'Classic';
  final List<String> _categories = ['Classic', 'Spicy', 'Sliders', 'Combo'];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a burger image'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final burgerProvider = Provider.of<BurgerProvider>(context, listen: false);
      
      // 1. Upload Image
      String? imageUrl;
      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        imageUrl = await burgerProvider.uploadImage(bytes);
      } else {
        imageUrl = await burgerProvider.uploadImage(File(_pickedImage!.path));
      }

      if (imageUrl == null) {
        throw 'Image upload failed';
      }

      // 2. Save Burger with Image URL
      final newBurger = Burger(
        id: '', 
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        rating: 4.5,
        imageUrl: imageUrl,
        category: _selectedCategory,
      );

      await burgerProvider.addBurger(newBurger);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Burger added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        title: const Text('Add New Burger', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFf06626)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFf06626).withOpacity(0.3)),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: kIsWeb 
                              ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                              : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Color(0xFFf06626)),
                              SizedBox(height: 10),
                              Text('Select Photo', style: TextStyle(color: Color(0xFFf06626))),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel('Burger Name'),
              _buildTextField(_nameController, 'Enter name', Icons.fastfood),
              
              const SizedBox(height: 20),
              _buildLabel('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration('', Icons.category),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              
              const SizedBox(height: 20),
              _buildLabel('Price (RS)'),
              _buildTextField(_priceController, 'Enter price', Icons.payments, isNumber: true),
              
              const SizedBox(height: 20),
              _buildLabel('Description'),
              _buildTextField(_descController, 'Enter description', Icons.description, maxLines: 3),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf06626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Burger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: _inputDecoration(hint, icon),
      validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFf06626)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFf06626))),
    );
  }
}
