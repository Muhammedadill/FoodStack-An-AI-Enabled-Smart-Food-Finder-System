import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role; // 'customer' or 'restaurant'

  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Restaurant specific
  final _restaurantNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedLocation;

  final List<String> kozhikodeLocations = [
    'Katangal',
    'Mukkam',
    'Kunnamangalam',
    'Kallamthode',
    'Kozhikode City',
    'Feroke',
    'Ramanattukara',
    'Koyilandy',
    'Vadakara',
    'Thalassery',
    'Kannur Road',
    'Kodiyeri',
    'Perambra',
    'Kakkodi',
    'Olavakkot',
    'Arikkulam',
    'Thiruvallur',
    'Kappad',
    'Beypore',
    'Kadalundi',
    'Valiyaparamba',
    'Payyoli',
    'Chalisgaon',
    'Nadapuram',
    'Vanimel',
    'Unnikulam',
    'Koduvally',
    'Koyilandy North',
    'Koyilandy South',
    'Thalassery North',
    'Thalassery South',
  ];

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = widget.role == 'restaurant'
        ? _restaurantNameController.text.trim()
        : _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (widget.role == 'restaurant' && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          email,
          password,
          name,
          widget.role,
          restaurantName: _restaurantNameController.text.trim(),
          address: _addressController.text.trim(),
          location: _selectedLocation,
          cuisine: _cuisineController.text.trim(),
          description: _descriptionController.text.trim(),
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!)),
        );
      }
      // Note: If registration is successful, routerProvider will automatically
      // trigger a redirect and dispose this widget.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRestaurant = widget.role == 'restaurant';
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRestaurant ? 'Register Restaurant' : 'Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            if (isRestaurant) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Restaurant Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _restaurantNameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'City/Area',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                hint: const Text('Select your area'),
                items: kozhikodeLocations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cuisineController,
                decoration: const InputDecoration(
                  labelText: 'Cuisine (e.g. Fusion, Italica)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Tell customers about your restaurant',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isRestaurant ? Colors.deepPurple : Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account',
                      style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
