import 'dart:typed_data';

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String variant;
  final String type; // Car, Bike, Scooter
  final int year;
  final String launchYear;
  final String priceRange;
  final String usedPriceRange;
  final String fuelType;
  final String engineCC;
  final String transmission;
  final String mileage;
  final String cityMileage;
  final String highwayMileage;
  final String power;
  final String torque;
  final int seatingCapacity;
  final String fuelTankCapacity; // e.g. "45 Liters"
  final String topSpeed;
  final List<String> colors;
  final List<String> imageUrls;
  final VehicleDimensions dimensions;
  final Map<String, List<String>> features; // Category -> List of features
  final List<VehiclePart> parts;
  final String description;
  final Uint8List? localImageBytes;
  final VehicleMaintenance? maintenance;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.variant,
    required this.type,
    required this.year,
    required this.launchYear,
    required this.priceRange,
    required this.usedPriceRange,
    required this.fuelType,
    required this.engineCC,
    required this.transmission,
    required this.mileage,
    required this.cityMileage,
    required this.highwayMileage,
    required this.power,
    required this.torque,
    required this.seatingCapacity,
    required this.fuelTankCapacity,
    required this.topSpeed,
    required this.colors,
    required this.imageUrls,
    required this.dimensions,
    required this.features,
    required this.parts,
    required this.description,
    this.localImageBytes,
    this.maintenance,
  });

  String get fullName => '$brand $model ($year)';
}

class VehicleDimensions {
  final String length;
  final String width;
  final String height;
  final String groundClearance;
  final String wheelbase;

  const VehicleDimensions({
    required this.length,
    required this.width,
    required this.height,
    required this.groundClearance,
    required this.wheelbase,
  });
}

class VehiclePart {
  final String name;
  final String icon;
  final String status;
  final double health; // 0.0 to 1.0
  final String details;
  final String? originalSpec;
  final String? repairTip;
  final String? imageUrl;

  const VehiclePart({
    required this.name,
    required this.icon,
    required this.status,
    required this.health,
    required this.details,
    this.originalSpec,
    this.repairTip,
    this.imageUrl,
  });
}

class VehicleMaintenance {
  final MaintenanceDetail engineOil;
  final MaintenanceDetail fuel;
  final List<String> longevityAssessment;

  const VehicleMaintenance({
    required this.engineOil,
    required this.fuel,
    required this.longevityAssessment,
  });
}

class MaintenanceDetail {
  final String typeAndGrade;
  final List<String> recommendedBrands;
  final String? replacementInterval;
  final List<String> benefits;

  const MaintenanceDetail({
    required this.typeAndGrade,
    required this.recommendedBrands,
    this.replacementInterval,
    required this.benefits,
  });
}
