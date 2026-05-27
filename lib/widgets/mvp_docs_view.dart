import 'package:flutter/material.dart';
import 'glass_card.dart';

class MvpDocsView extends StatelessWidget {
  const MvpDocsView({super.key});

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
              'Startup Pitch & Architecture',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Technical architecture, training models, and monetization roadmap',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),
  
            // 1. AI Modules Section
            _buildCollapsibleSection(
              context,
              '1. Three-Module AI System',
              Icons.memory,
              [
                _buildFeatureBullet(
                  'Module 1: Vehicle Detection (YOLOv8)',
                  'Locates bounding boxes of bikes, rickshaws, cars, trucks, and buses. Runs on edge/mobile devices (TFLite) or cloud endpoints.',
                ),
                _buildFeatureBullet(
                  'Module 2: Model Recognition (ResNet50 / CNN)',
                  'Applies transfer learning on pre-trained networks to classify the specific brand and model (e.g., Tata Nexon, Honda Activa).',
                ),
                _buildFeatureBullet(
                  'Module 3: Facelift & Year Estimation (DeepDiff)',
                  'A Siamese neural network compares visual features (headlight profiles, grille styling, alloy patterns) to determine the exact year variant.',
                ),
              ],
            ),
            const SizedBox(height: 12),
  
            // 2. Training Pipeline Section
            _buildCollapsibleSection(
              context,
              '2. Image Training Pipeline',
              Icons.model_training,
              [
                _buildFeatureBullet(
                  'Step 1: Annotation',
                  'Upload images to Roboflow. Draw bounding boxes around the body, headlights, and tail lights for sub-assembly classification.',
                ),
                _buildFeatureBullet(
                  'Step 2: Augmentation',
                  'Generate variations in brightness, perspective, crop, and contrast to simulate roadside captures and garage environments.',
                ),
                _buildFeatureBullet(
                  'Step 3: Training & Compression',
                  'Train using PyTorch/YOLOv8 framework. Export weights to ONNX format, then convert to TensorFlow Lite (FP16/INT8 quantized) for mobile deployment.',
                ),
              ],
            ),
            const SizedBox(height: 12),
  
            // 3. Tech Stack Section
            _buildCollapsibleSection(
              context,
              '3. Core Tech Stack',
              Icons.layers,
              [
                _buildStackRow('Frontend', 'Flutter (Single codebase for Web, Android, iOS)'),
                _buildStackRow('Backend API', 'FastAPI (Python-based async endpoints for image processing)'),
                _buildStackRow('Database & Storage', 'Supabase / Firebase (Stores user history, presets, and images)'),
                _buildStackRow('AI Engine', 'YOLOv8 + PyTorch (Trained model pipeline)'),
                _buildStackRow('Extra Tools', 'EasyOCR (Number plate extraction) & Roboflow (Dataset management)'),
              ],
            ),
            const SizedBox(height: 12),
  
            // 4. Development Phases
            _buildCollapsibleSection(
              context,
              '4. Launch Phases',
              Icons.rocket_launch,
              [
                _buildFeatureBullet(
                  'Phase 1: MVP (Months 1-2)',
                  'Support local photo uploads and preset detection for 100-200 popular Indian vehicles (Creta, Activa, Nexon). Show core specifications.',
                ),
                _buildFeatureBullet(
                  'Phase 2: Smart AI (Months 3-5)',
                  'Integrate Year/Facelift detection, automatic variant estimation, and high-performance offline inference on mobile processors.',
                ),
                _buildFeatureBullet(
                  'Phase 3: Advanced (Months 6+)',
                  'Integrate EasyOCR plate decoders, AI-based body damage/scratch detection, AR specs placement, and used market value APIs.',
                ),
              ],
            ),
            const SizedBox(height: 12),
  
            // 5. Monetization Strategy
            _buildCollapsibleSection(
              context,
              '5. Monetization Models',
              Icons.currency_rupee,
              [
                _buildFeatureBullet('Dealership Partnerships', 'Earn lead generation commission from used car dealers (CarWale, Spinny, Cars24).'),
                _buildFeatureBullet('Insurance Valuations', 'Provide API evaluations of vehicle body integrity and health checks for insurance renewals.'),
                _buildFeatureBullet('Premium Subscriptions', 'Charge users for detailed historical reports, accident reports, and garage servicing histories.'),
                _buildFeatureBullet('Spare Parts Commission', 'Direct users to buy replacement parts (Brembo, Bosch, etc.) when parts diagnostics show wear.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: Colors.cyanAccent,
        collapsedIconColor: Colors.white60,
        childrenPadding: const EdgeInsets.all(8),
        children: children,
      ),
    );
  }

  Widget _buildFeatureBullet(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.keyboard_arrow_right, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackRow(String category, String tech) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              tech,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
