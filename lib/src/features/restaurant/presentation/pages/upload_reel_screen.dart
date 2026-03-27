import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/shared/services/cloudinary_service.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UploadReelScreen extends ConsumerStatefulWidget {
  const UploadReelScreen({super.key});

  @override
  ConsumerState<UploadReelScreen> createState() => _UploadReelScreenState();
}

class _UploadReelScreenState extends ConsumerState<UploadReelScreen> {
  final _dishNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  bool _isUploading = false;
  String? _selectedFilePath;
  String _uploadStatus = '';
  bool _isSelectedFileVideo = false;
  String _selectedCategory = AppCategories.mainCourse;

  void _pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );
    if (picked != null) {
      setState(() {
        _selectedFilePath = picked.path;
        _isSelectedFileVideo = true;
      });
    }
  }

  void _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedFilePath = picked.path;
        _isSelectedFileVideo = false;
      });
    }
  }

  void _upload() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (_dishNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter dish name')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading to Cloudinary...';
    });

    try {
      // Upload to Cloudinary using appropriate method
      final url = _isSelectedFileVideo
          ? await CloudinaryService.uploadVideo(_selectedFilePath!)
          : await CloudinaryService.uploadImage(_selectedFilePath!);

      if (url == null) {
        throw Exception('Failed to get URL from Cloudinary');
      }

      setState(() {
        _uploadStatus = 'Saving to database...';
      });

      // Save to Firestore
      final reel = FoodReel(
        id: const Uuid().v4(),
        restaurantId: user.id,
        videoUrl: url,
        dishName: _dishNameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        likes: 0,
        category: _selectedCategory,
      );

      await ref.read(reelRepositoryProvider).addReel(reel);

      // Refresh reels
      ref.invalidate(reelsProvider);
      ref.invalidate(restaurantReelsProvider(user.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reel uploaded successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Food Reel'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media picker area
            GestureDetector(
              onTap: _isUploading ? null : _showPickerOptions,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFilePath != null
                        ? Colors.deepOrange
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: _selectedFilePath == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Tap to select video or image',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Supports images & videos',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Show image preview if it's an image
                            if (_selectedFilePath!.endsWith('.jpg') ||
                                _selectedFilePath!.endsWith('.jpeg') ||
                                _selectedFilePath!.endsWith('.png') ||
                                _selectedFilePath!.endsWith('.webp'))
                              Image.file(
                                File(_selectedFilePath!),
                                fit: BoxFit.cover,
                              )
                            else
                              const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.videocam,
                                        size: 50, color: Colors.deepOrange),
                                    SizedBox(height: 8),
                                    Text('Video selected',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            // Overlay with checkmark
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _dishNameController,
              decoration: InputDecoration(
                labelText: 'Dish Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (₹)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.category),
              ),
              items: AppCategories.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'What makes this dish special?',
              ),
            ),
            const SizedBox(height: 32),

            // Upload status
            if (_isUploading && _uploadStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _uploadStatus,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            ElevatedButton(
              onPressed:
                  (_isUploading || _selectedFilePath == null) ? null : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Upload Reel', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.deepOrange),
                title: const Text('Pick Video from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.deepPurple),
                title: const Text('Pick Image from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
