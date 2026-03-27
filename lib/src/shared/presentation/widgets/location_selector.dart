import 'package:flutter/material.dart';

class LocationSelector extends StatefulWidget {
  final String? selectedLocation;
  final Function(String) onLocationSelected;

  const LocationSelector({
    super.key,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final List<String> kozhikodeCities = [
    'Katangal',
    'Mukkam',
    'Kunnamangalam',
    'Kallamthode',
    'Kozhikode City',
    'Feroke',
    'Ramanattukara',
    'Koyilandy',
    'Balussery',
    'Perambra',
    'Vadakara',
    'Thamarassery',
    'Kalpetta',
    'Thiruvambady',
  ];

  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange),
              SizedBox(width: 8),
              Text('Select Location'),
            ],
          ),
          value: _selectedLocation,
          icon: const Icon(Icons.arrow_drop_down),
          items: kozhikodeCities.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLocation = newValue;
              });
              widget.onLocationSelected(newValue);
            }
          },
        ),
      ),
    );
  }
}
