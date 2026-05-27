import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../data/vehicle_data.dart';
import 'glass_card.dart';

class CompareView extends StatefulWidget {
  final Vehicle? initialVehicle;

  const CompareView({super.key, this.initialVehicle});

  @override
  State<CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView> {
  late Vehicle _vehicleA;
  late Vehicle _vehicleB;

  @override
  void initState() {
    super.initState();
    // Default select vehicle A as initial or index 0
    _vehicleA = widget.initialVehicle ?? VehicleDatabase.vehicles[0];
    
    // Default select vehicle B as index 1 (or 0 if same, ensure different if possible)
    if (VehicleDatabase.vehicles.length > 1) {
      if (widget.initialVehicle?.id == VehicleDatabase.vehicles[1].id) {
        _vehicleB = VehicleDatabase.vehicles[0];
      } else {
        _vehicleB = VehicleDatabase.vehicles[1];
      }
    } else {
      _vehicleB = VehicleDatabase.vehicles[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: FadeInPoint(
        delayMs: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Comparison Tool',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Compare specs, engine outputs, and prices side-by-side',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 16),
  
            // Selector Header
            Row(
              children: [
                // Vehicle A Selector
                Expanded(
                  child: _buildSelectorCard(_vehicleA, true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Vehicle B Selector
                Expanded(
                  child: _buildSelectorCard(_vehicleB, false),
                ),
              ],
            ),
            const SizedBox(height: 20),
  
            // Comparison rows
            _buildComparisonSection('Basic info', [
              _CompareRow('Brand', _vehicleA.brand, _vehicleB.brand),
              _CompareRow('Model', _vehicleA.model, _vehicleB.model),
              _CompareRow('Launch Year', _vehicleA.launchYear, _vehicleB.launchYear),
              _CompareRow('Type', _vehicleA.type, _vehicleB.type),
            ]),
            
            _buildComparisonSection('Pricing & Value', [
              _CompareRow('Showroom Price', _vehicleA.priceRange, _vehicleB.priceRange),
              _CompareRow('Est. Used Value', _vehicleA.usedPriceRange, _vehicleB.usedPriceRange),
            ]),
  
            _buildComparisonSection('Performance & Specs', [
              _CompareRow('Fuel Type', _vehicleA.fuelType, _vehicleB.fuelType),
              _CompareRow('Engine CC', _vehicleA.engineCC, _vehicleB.engineCC),
              _CompareRow('Transmission', _vehicleA.transmission, _vehicleB.transmission),
              _CompareRow('Mileage', _vehicleA.mileage, _vehicleB.mileage),
              _CompareRow('Tank Capacity', _vehicleA.fuelTankCapacity, _vehicleB.fuelTankCapacity),
              _CompareRow('Max Power', _vehicleA.power, _vehicleB.power),
              _CompareRow('Max Torque', _vehicleA.torque, _vehicleB.torque),
              _CompareRow('Top Speed', _vehicleA.topSpeed, _vehicleB.topSpeed),
            ]),
  
            _buildComparisonSection('Cabin & Dimensions', [
              _CompareRow('Seating', '${_vehicleA.seatingCapacity} Seater', '${_vehicleB.seatingCapacity} Seater'),
              _CompareRow('Length', _vehicleA.dimensions.length, _vehicleB.dimensions.length),
              _CompareRow('Width', _vehicleA.dimensions.width, _vehicleB.dimensions.width),
              _CompareRow('Height', _vehicleA.dimensions.height, _vehicleB.dimensions.height),
              _CompareRow('Ground Clearance', _vehicleA.dimensions.groundClearance, _vehicleB.dimensions.groundClearance),
              _CompareRow('Wheelbase', _vehicleA.dimensions.wheelbase, _vehicleB.dimensions.wheelbase),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorCard(Vehicle selectedVehicle, bool isVehicleA) {
    final List<Vehicle> dropdownItems = List.from(VehicleDatabase.vehicles);
    if (!dropdownItems.any((v) => v.id == selectedVehicle.id)) {
      dropdownItems.add(selectedVehicle);
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 70,
              child: selectedVehicle.localImageBytes != null
                  ? Image.memory(
                      selectedVehicle.localImageBytes!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      selectedVehicle.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.directions_car, color: Colors.white30),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown button
          DropdownButtonHideUnderline(
            child: DropdownButton<Vehicle>(
              value: selectedVehicle,
              isExpanded: true,
              dropdownColor: Colors.black.withAlpha(220),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              selectedItemBuilder: (BuildContext context) {
                return dropdownItems.map<Widget>((Vehicle v) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${v.brand} ${v.model}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              items: dropdownItems.map((Vehicle vehicle) {
                final isCustom = vehicle.id == selectedVehicle.id &&
                    !VehicleDatabase.vehicles.any((v) => v.id == vehicle.id);
                return DropdownMenuItem<Vehicle>(
                  value: vehicle,
                  child: Text(
                    isCustom
                        ? '${vehicle.brand} ${vehicle.model} (Scanned)'
                        : '${vehicle.brand} ${vehicle.model} (${vehicle.year})',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (Vehicle? newValue) {
                if (newValue != null) {
                  setState(() {
                    if (isVehicleA) {
                      _vehicleA = newValue;
                    } else {
                      _vehicleB = newValue;
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(String title, List<_CompareRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8, left: 4),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 16,
          child: Column(
            children: rows.map((row) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10, width: 0.8)),
                ),
                child: Column(
                  children: [
                    Text(
                      row.parameter,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.valueA,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 18,
                          color: Colors.white12,
                        ),
                        Expanded(
                          child: Text(
                            row.valueB,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CompareRow {
  final String parameter;
  final String valueA;
  final String valueB;

  _CompareRow(this.parameter, this.valueA, this.valueB);
}
