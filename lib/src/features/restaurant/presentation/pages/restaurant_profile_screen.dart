import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_reel_app/src/features/shared/domain/models.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';
import 'package:food_reel_app/src/shared/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class RestaurantProfileScreen extends ConsumerStatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  ConsumerState<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState
    extends ConsumerState<RestaurantProfileScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cuisineController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _localImagePath;
  String? _currentImageUrl;
  Restaurant? _restaurant;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    setState(() => _isLoading = true);
    final user = ref.read(authProvider).user;
    if (user != null) {
      try {
        final repo = ref.read(restaurantRepositoryProvider);
        final restaurants = await repo.getRestaurants();

        // Find restaurant by ownerId safely
        Restaurant? myRestaurant;
        try {
          myRestaurant = restaurants.firstWhere((r) => r.ownerId == user.id);
        } catch (_) {
          myRestaurant = null;
        }

        if (myRestaurant != null) {
          final r = myRestaurant;
          if (mounted) {
            setState(() {
              _restaurant = r;
              _nameController.text = r.name;
              _descriptionController.text = r.description;
              _addressController.text = r.address;
              _phoneController.text = r.phone;
              _cuisineController.text = r.cuisine;
              _currentImageUrl = r.imageUrl;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading restaurant: $e')),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createInitialShop() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shop name first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final newRestaurant = Restaurant(
        id: const Uuid().v4(),
        ownerId: user.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        cuisine: _cuisineController.text.trim(),
        imageUrl: '',
        location: 'Kozhikode City', // Default location
        rating: 4.5,
        isOpen: true,
        deliveryCharge: 40,
        deliveryTime: 30,
        minOrderValue: 100,
        distance: '0 km',
      );

      await ref.read(restaurantRepositoryProvider).addRestaurant(newRestaurant);

      if (mounted) {
        ref.invalidate(restaurantsProvider);

        setState(() {
          _restaurant = newRestaurant;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop created successfully! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create shop: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _localImagePath = picked.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_restaurant == null) return;

    setState(() => _isSaving = true);

    try {
      String finalImageUrl = _currentImageUrl ?? '';

      // 1. Upload new image if picked
      if (_localImagePath != null) {
        final uploadedUrl =
            await CloudinaryService.uploadImage(_localImagePath!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      // 2. Update restaurant object
      final updatedRestaurant = Restaurant(
        id: _restaurant!.id,
        ownerId: _restaurant!.ownerId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        cuisine: _cuisineController.text.trim(),
        imageUrl: finalImageUrl,
        location: _restaurant!.location,
        rating: _restaurant!.rating,
        isOpen: _restaurant!.isOpen,
        deliveryCharge: _restaurant!.deliveryCharge,
        deliveryTime: _restaurant!.deliveryTime,
        minOrderValue: _restaurant!.minOrderValue,
        distance: _restaurant!.distance,
      );

      // 3. Save to Firestore
      await ref
          .read(restaurantRepositoryProvider)
          .updateRestaurant(updatedRestaurant);

      if (mounted) {
        // 4. Invalidate provider to refresh UI
        ref.invalidate(restaurantProvider(_restaurant!.id));
        ref.invalidate(restaurantsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop profile updated successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shop Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading && _restaurant != null)
            IconButton(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _restaurant == null
                      ? _buildNoShopHeader()
                      : _buildImageHeader(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(_restaurant == null
                            ? 'Create Your Shop'
                            : 'Basic Information'),
                        const SizedBox(height: 16),
                        _buildTextField(_nameController, 'Shop Name',
                            Icons.store, 'Enter your restaurant name'),
                        const SizedBox(height: 16),
                        _buildTextField(_cuisineController, 'Cuisine Type',
                            Icons.restaurant, 'Chinese, Indian, Italian...'),
                        const SizedBox(height: 16),
                        _buildTextField(_phoneController, 'Contact Number',
                            Icons.phone, '+91 XXXXX XXXXX',
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Details & Location'),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _descriptionController,
                            'Short Description',
                            Icons.description,
                            'Tell customers about your shop',
                            maxLines: 3),
                        const SizedBox(height: 16),
                        _buildTextField(_addressController, 'Full Address',
                            Icons.location_on, 'Detailed shop address',
                            maxLines: 2),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSaving
                                ? null
                                : (_restaurant == null
                                    ? _createInitialShop
                                    : _saveProfile),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    _restaurant == null
                                        ? 'Create Shop Profile'
                                        : 'Save Changes',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNoShopHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.deepPurple[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_business, size: 64, color: Colors.deepPurple[200]),
          const SizedBox(height: 12),
          Text(
            'New Shop Setup',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[300]),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your shop profile to start selling',
            style: TextStyle(color: Colors.deepPurple[200]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[100],
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: _localImagePath != null
                ? Image.file(File(_localImagePath!), fit: BoxFit.cover)
                : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                    ? Image.network(
                        _currentImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
          ),

          // Image picker overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Change button
          Center(
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Change Shop Photo',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          // Status tag
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Live Shop',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.deepPurple[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 80, color: Colors.deepPurple[100]),
          const SizedBox(height: 8),
          Text('No Shop Image Set',
              style: TextStyle(color: Colors.deepPurple[200])),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[50],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }
}
