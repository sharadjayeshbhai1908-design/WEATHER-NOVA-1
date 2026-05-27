import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vehicle.dart';
import '../data/vehicle_data.dart';
import 'glass_card.dart';
import 'interactive_details_sheets.dart';

class VehicleDetailsView extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onBack;
  final Function(Vehicle) onSelectVehicle;

  const VehicleDetailsView({
    super.key,
    required this.vehicle,
    required this.onBack,
    required this.onSelectVehicle,
  });

  @override
  State<VehicleDetailsView> createState() => _VehicleDetailsViewState();
}

class _VehicleDetailsViewState extends State<VehicleDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VehicleDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicle.id != widget.vehicle.id) {
      setState(() {
        _activeImageIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final similarVehicles = VehicleDatabase.vehicles
        .where((v) => v.type == widget.vehicle.type && v.id != widget.vehicle.id)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(15),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: Text(
          '${widget.vehicle.brand} ${widget.vehicle.model}',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.cyan.shade900,
          unselectedLabelColor: Colors.black45,
          indicatorColor: Colors.cyan.shade800,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 15,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Specs'),
            Tab(text: 'Maintenance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(similarVehicles),
          _buildSpecsTab(),
          _buildMaintenanceTab(),
        ],
      ),
    );
  }

  // --- OVERVIEW TAB ---
  Widget _buildOverviewTab(List<Vehicle> similar) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: FadeInPoint(
        delayMs: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slider
            SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: widget.vehicle.localImageBytes != null ? 1 : widget.vehicle.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _activeImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.vehicle.localImageBytes != null
                          ? Image.memory(
                              widget.vehicle.localImageBytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.vehicle.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade900,
                                child: const Icon(Icons.broken_image, color: Colors.white38, size: 48),
                              ),
                            ),
                    );
                  },
                ),
                // Indicator dots
                if (widget.vehicle.localImageBytes == null && widget.vehicle.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.vehicle.imageUrls.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _activeImageIndex == index
                                ? Colors.cyanAccent
                                : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price Tag Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.fullName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.vehicle.variant,
                      style: TextStyle(
                        color: Colors.cyan.shade800,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.cyan.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.cyan.withAlpha(80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withAlpha(10),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  widget.vehicle.fuelType,
                  style: TextStyle(
                    color: Colors.cyan.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick highlights cards
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniCard('Showroom Price', widget.vehicle.priceRange, Icons.currency_rupee),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricMiniCard('Est. Used Value', widget.vehicle.usedPriceRange, Icons.sell),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniCard('Mileage', widget.vehicle.mileage, Icons.electric_car_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricMiniCard('Engine CC', widget.vehicle.engineCC, Icons.speed),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniCard('Tank Capacity', widget.vehicle.fuelTankCapacity, Icons.local_gas_station_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricMiniCard('Transmission', widget.vehicle.transmission, Icons.settings_input_component_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          const Text(
            'Vehicle Overview',
            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.vehicle.description
                  .split(RegExp(r'\.(?=\s|$)'))
                  .map((sentence) => sentence.trim())
                  .where((sentence) => sentence.isNotEmpty)
                  .map((sentence) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.cyanAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sentence,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMetricMiniCard(String label, String value, IconData icon) {
    return GestureDetector(
      onTap: () {
        InteractiveDetailsSheets.showMetricDetailSheet(
          context: context,
          label: label,
          value: value,
          icon: icon,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 12,
          fillGradientStart: Colors.white.withAlpha(8),
          fillGradientEnd: Colors.white.withAlpha(2),
          customBorder: Border.all(color: Colors.white.withAlpha(15)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withAlpha(15),
                ),
                child: Icon(icon, color: Colors.cyanAccent, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(label, style: const TextStyle(color: Colors.black45, fontSize: 10)),
                        const SizedBox(width: 4),
                        const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 10),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SPECS TAB ---
  Widget _buildSpecsTab() {
    final specItems = [
      _SpecRow('Brand', widget.vehicle.brand),
      _SpecRow('Model', widget.vehicle.model),
      _SpecRow('Variant', widget.vehicle.variant),
      _SpecRow('Model Year', widget.vehicle.year.toString()),
      _SpecRow('Launch/Facelift Year', widget.vehicle.launchYear),
      _SpecRow('Fuel Type', widget.vehicle.fuelType),
      _SpecRow('Engine Displacement', widget.vehicle.engineCC),
      _SpecRow('Transmission', widget.vehicle.transmission),
      _SpecRow('Claimed Mileage', widget.vehicle.mileage),
      _SpecRow('Fuel Tank Capacity', widget.vehicle.fuelTankCapacity),
      _SpecRow('City Mileage Est.', widget.vehicle.cityMileage),
      _SpecRow('Highway Mileage Est.', widget.vehicle.highwayMileage),
      _SpecRow('Max Power', widget.vehicle.power),
      _SpecRow('Max Torque', widget.vehicle.torque),
      _SpecRow('Seating Capacity', '${widget.vehicle.seatingCapacity} Seater'),
      _SpecRow('Top Speed', widget.vehicle.topSpeed),
      _SpecRow('Dimensions (L x W x H)', '${widget.vehicle.dimensions.length} x ${widget.vehicle.dimensions.width} x ${widget.vehicle.dimensions.height}'),
      _SpecRow('Ground Clearance', widget.vehicle.dimensions.groundClearance),
      _SpecRow('Wheelbase', widget.vehicle.dimensions.wheelbase),
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: specItems.length,
      itemBuilder: (context, index) {
        final row = specItems[index];
        return FadeInPoint(
          delayMs: index * 30,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12, width: 0.8)),
              color: index % 2 == 0 ? Colors.black.withAlpha(5) : Colors.transparent,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    row.label,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    row.value,
                    style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  // --- MAINTENANCE TAB ---
  Widget _buildMaintenanceTab() {
    final maintenance = widget.vehicle.maintenance;
    
    if (maintenance == null) {
      return Center(
        child: Text(
          'Maintenance recommendations not available.',
          style: GoogleFonts.outfit(color: Colors.black54, fontSize: 15),
        ),
      );
    }

    final isEv = widget.vehicle.fuelType.toLowerCase().contains('electric') || widget.vehicle.type == 'EV';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Maintenance Insights',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEv 
              ? 'Tailored electric powertrain maintenance guidelines (${widget.vehicle.year})'
              : 'Tailored step-by-step recommendations based on vehicle age (${widget.vehicle.year})',
            style: GoogleFonts.outfit(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),

          // Recommended Oil / Electric Drive Fluid Card
          AnimatedGlassCard(
            glowColor: Colors.amber,
            onTap: () {
              InteractiveDetailsSheets.showLubricationSheet(
                context: context,
                vehicleType: widget.vehicle.type,
                typeAndGrade: maintenance.engineOil.typeAndGrade,
                replacementInterval: maintenance.engineOil.replacementInterval,
                recommendedBrands: maintenance.engineOil.recommendedBrands,
                benefits: maintenance.engineOil.benefits,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEv ? Icons.electric_bolt_rounded : Icons.water_drop_rounded,
                          color: Colors.amber.shade700,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEv ? 'Electric Drive System Fluid' : 'Engine Oil Specification',
                              style: GoogleFonts.outfit(
                                color: Colors.amber.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              maintenance.engineOil.typeAndGrade,
                              style: GoogleFonts.outfit(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Lifespan row
                  if (maintenance.engineOil.replacementInterval != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.update_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isEv ? 'Service Interval: ' : 'Lifespan: ',
                          style: GoogleFonts.outfit(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          maintenance.engineOil.replacementInterval!,
                          style: GoogleFonts.outfit(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Recommended Brands
                  Text(
                    isEv ? 'Referred Fluid Brands:' : 'Recommended Brands:',
                    style: GoogleFonts.outfit(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: maintenance.engineOil.recommendedBrands.map((brand) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withAlpha(50), width: 1),
                        ),
                        child: Text(
                          brand,
                          style: GoogleFonts.outfit(
                            color: Colors.amber.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Benefits header
                  Text(
                    isEv ? 'Fluid & System Safety Benefits:' : 'Engine Health Benefits:',
                    style: GoogleFonts.outfit(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(maintenance.engineOil.benefits.length, (index) {
                    return _buildCheckBenefitPoint(maintenance.engineOil.benefits[index], Colors.amber, index);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recommended Fuel / Battery Charging Card
          AnimatedGlassCard(
            glowColor: Colors.cyan,
            onTap: () {
              InteractiveDetailsSheets.showFuelDynamicsSheet(
                context: context,
                vehicleType: widget.vehicle.type,
                fuelType: widget.vehicle.fuelType,
                typeAndGrade: maintenance.fuel.typeAndGrade,
                recommendedBrands: maintenance.fuel.recommendedBrands,
                benefits: maintenance.fuel.benefits,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEv ? Icons.battery_charging_full_rounded : Icons.local_gas_station_rounded,
                          color: Colors.cyan.shade700,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEv ? 'Battery Specification & Charging' : 'Recommended Fuel Type',
                              style: GoogleFonts.outfit(
                                color: Colors.cyan.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              maintenance.fuel.typeAndGrade,
                              style: GoogleFonts.outfit(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.info_outline_rounded, color: Colors.cyan, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Recommended Brands
                  Text(
                    isEv ? 'Recommended Charger & Charging Networks:' : 'Recommended Brands:',
                    style: GoogleFonts.outfit(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: maintenance.fuel.recommendedBrands.map((brand) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.cyan.withAlpha(50), width: 1),
                        ),
                        child: Text(
                          brand,
                          style: GoogleFonts.outfit(
                            color: Colors.cyan.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Benefits header
                  Text(
                    isEv ? 'Electric Drive Advantages:' : 'Performance Benefits:',
                    style: GoogleFonts.outfit(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(maintenance.fuel.benefits.length, (index) {
                    return _buildCheckBenefitPoint(maintenance.fuel.benefits[index], Colors.cyan, index);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Condition Assessment
          Text(
            isEv ? 'EV Longevity & Safety Assessment' : 'Longevity & Condition Assessment',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedGlassCard(
            glowColor: Colors.purple,
            onTap: () {
              InteractiveDetailsSheets.showLongevityChecklistSheet(
                context: context,
                longevityTips: maintenance.longevityAssessment,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEv ? 'EV Diagnostic Checklist Guidelines' : 'Diagnostic Checklist Guidelines',
                        style: GoogleFonts.outfit(
                          color: Colors.purple.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.fact_check_outlined, color: Colors.purple, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(maintenance.longevityAssessment.length, (index) {
                    final point = maintenance.longevityAssessment[index];
                    return FadeInPoint(
                      delayMs: index * 80,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.health_and_safety_rounded, color: Colors.purple, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                point,
                                style: GoogleFonts.outfit(
                                  color: Colors.black87,
                                  fontSize: 13.5,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckBenefitPoint(String text, Color accentColor, int index) {
    return FadeInPoint(
      delayMs: index * 80,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: accentColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data row helper
class _SpecRow {
  final String label;
  final String value;
  _SpecRow(this.label, this.value);
}
