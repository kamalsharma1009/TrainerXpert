import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class NutritionGuideScreen extends StatefulWidget {
  const NutritionGuideScreen({super.key});

  @override
  State<NutritionGuideScreen> createState() => _NutritionGuideScreenState();
}

class _NutritionGuideScreenState extends State<NutritionGuideScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _recipeSearchController = TextEditingController();

  String _generatedPlan = '';
  String _generatedRecipes = '';
  String _groceryList = '';
  bool _isGenerating = false;
  late GenerativeModel _model;
  double _calories = 2000;
  String _dietType = 'Balanced';
  String _selectedDay = 'Monday';
  String _selectedMealType = 'Breakfast';
  bool _showRecipes = false;
  bool _showGroceryList = false;

  final List<String> _dietTypes = [
    'Balanced',
    'Keto',
    'Vegetarian',
    'Vegan',
    'Paleo',
    'Mediterranean',
    'Low-Carb',
    'High-Protein',
  ];

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  Future<void> _generateMealPlan() async {
    if (_goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your fitness goal')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedPlan = '';
      _generatedRecipes = '';
      _groceryList = '';
      _showRecipes = false;
      _showGroceryList = false;
    });

    try {
      final prompt = '''
      Generate a detailed weekly $_dietType meal plan for someone with these characteristics:
      - Fitness Goal: ${_goalController.text}
      - Daily Calorie Target: ${_calories.round()} kcal
      - Dietary Restrictions: ${_allergiesController.text.isNotEmpty ? _allergiesController.text : 'None'}
      - Food Preferences: ${_preferencesController.text.isNotEmpty ? _preferencesController.text : 'None'}
      
      Provide the plan in this EXACT format:
      
      ### Weekly Meal Plan for [Goal]
      **Calorie Target**: [calories] kcal/day
      **Diet Type**: [diet type]
      
      #### [Day 1]
      **Breakfast**:
      - [Food item 1]: [calories] kcal, [macros]
      - [Food item 2]: [calories] kcal, [macros]
      **Total**: [total calories] kcal
      
      **Lunch**:
      - [Food items...]
      **Total**: [total calories] kcal
      
      **Dinner**:
      - [Food items...]
      **Total**: [total calories] kcal
      
      **Snacks**:
      - [Food items...]
      **Total**: [total calories] kcal
      
      [Repeat for all 7 days]
      
      #### Weekly Nutritional Summary
      - Average Daily Calories: [total] kcal
      - Protein: [amount]g/day
      - Carbs: [amount]g/day
      - Fats: [amount]g/day
      
      **Meal Prep Tips**: [brief advice]
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      setState(() {
        _generatedPlan = response.text ?? 'Failed to generate meal plan';
      });
    } catch (e) {
      setState(() {
        _generatedPlan = 'Error generating meal plan: $e';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateRecipes() async {
    if (_generatedPlan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate a meal plan first')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedRecipes = '';
      _showRecipes = true;
    });

    try {
      final prompt = '''
      Based on this meal plan, provide detailed recipes for $_selectedDay's $_selectedMealType:
      
      $_generatedPlan
      
      For each recipe include:
      1. Recipe name
      2. Preparation time
      3. Cooking time
      4. Detailed ingredients list with quantities
      5. Step-by-step instructions
      6. Nutritional information per serving
      7. Serving suggestions
      8. Any special equipment needed
      
      Format the recipes clearly with headings for each section.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      setState(() {
        _generatedRecipes = response.text ?? 'Failed to generate recipes';
      });
    } catch (e) {
      setState(() {
        _generatedRecipes = 'Error generating recipes: $e';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateGroceryList() async {
    if (_generatedPlan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate a meal plan first')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _groceryList = '';
      _showGroceryList = true;
    });

    try {
      final prompt = '''
      Create a comprehensive grocery shopping list for this meal plan:
      
      $_generatedPlan
      
      Organize the list by:
      1. Food categories (Produce, Dairy, Meat, Pantry, etc.)
      2. Include exact quantities needed for the entire week
      3. Note any specialty items
      4. Include estimated costs if possible
      5. Add tips for selecting the best quality ingredients
      
      Format the list clearly with categories and bullet points.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      setState(() {
        _groceryList = response.text ?? 'Failed to generate grocery list';
      });
    } catch (e) {
      setState(() {
        _groceryList = 'Error generating grocery list: $e';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _searchRecipes() async {
    if (_recipeSearchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe search term')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedRecipes = '';
      _showRecipes = true;
    });

    try {
      final prompt = '''
      Provide 3 detailed $_dietType recipes for: ${_recipeSearchController.text}
      that fit a ${_calories.round()} kcal/day diet.
      
      For each recipe include:
      1. Recipe name and description
      2. Preparation and cooking time
      3. Detailed ingredients with quantities
      4. Step-by-step instructions
      5. Nutritional information (calories, protein, carbs, fats)
      6. Serving size
      7. Meal prep and storage tips
      8. Possible variations or substitutions
      
      Format each recipe with clear headings and separate sections.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      setState(() {
        _generatedRecipes = response.text ?? 'Failed to find recipes';
      });
    } catch (e) {
      setState(() {
        _generatedRecipes = 'Error searching recipes: $e';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showMealPlanDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Generate Custom Meal Plan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _dietType,
                    items:
                        _dietTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => _dietType = value!),
                    decoration: const InputDecoration(labelText: 'Diet Type'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      labelText: 'Fitness Goal',
                      hintText: 'e.g., Weight loss, Muscle gain, Maintenance',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _calories,
                    min: 1200,
                    max: 4000,
                    divisions: 28,
                    label: _calories.round().toString(),
                    onChanged: (value) => setState(() => _calories = value),
                  ),
                  Text(
                    'Daily Calories: ${_calories.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      labelText: 'Allergies/Restrictions',
                      hintText: 'e.g., Dairy-free, Nut allergy',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _preferencesController,
                    decoration: const InputDecoration(
                      labelText: 'Food Preferences',
                      hintText: 'e.g., Prefer chicken over beef',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateMealPlan();
                },
                child: const Text('Generate Plan'),
              ),
            ],
          ),
    );
  }

  void _showRecipeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Generate Recipes'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    items:
                        _daysOfWeek.map((day) {
                          return DropdownMenuItem(value: day, child: Text(day));
                        }).toList(),
                    onChanged: (value) => setState(() => _selectedDay = value!),
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMealType,
                    items:
                        _mealTypes.map((meal) {
                          return DropdownMenuItem(
                            value: meal,
                            child: Text(meal),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedMealType = value!),
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateRecipes();
                },
                child: const Text('Generate Recipes'),
              ),
            ],
          ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _launchRecipeSearch(String query) async {
    final url = Uri.parse('https://www.google.com/search?q=$query+recipe');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showMealPlanDialog,
            tooltip: 'Create Meal Plan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Tips Section
            _buildSectionHeader('Daily Nutrition Tips'),
            const SizedBox(height: 16),
            _buildNutritionTip(
              'Hydration',
              'Drink at least 8 glasses of water daily. Add lemon or cucumber for flavor.',
              Icons.local_drink,
            ),
            _buildNutritionTip(
              'Macro Balance',
              'Aim for 30% protein, 40% carbs, 30% fats for most fitness goals.',
              Icons.pie_chart,
            ),
            _buildNutritionTip(
              'Meal Timing',
              'Eat every 3-4 hours to maintain energy and metabolism.',
              Icons.access_time,
            ),

            // Recipe Search Section
            _buildSectionHeader('Recipe Finder'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipeSearchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search recipes (e.g., "high protein breakfast")',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchRecipes,
                      ),
                    ),
                    onSubmitted: (_) => _searchRecipes(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickSearchChip('Keto Snacks'),
                _buildQuickSearchChip('Vegan Lunch'),
                _buildQuickSearchChip('High Protein'),
                _buildQuickSearchChip('Low Carb'),
              ],
            ),

            // Meal Planning Section
            _buildSectionHeader('Meal Planning'),
            const SizedBox(height: 16),
            _buildMealPlanCard('Weight Loss', '1600-1800 kcal'),
            _buildMealPlanCard('Muscle Gain', '2500-3000 kcal'),
            _buildMealPlanCard('Maintenance', '2000-2200 kcal'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _showMealPlanDialog,
                child: const Text('Create Custom Meal Plan'),
              ),
            ),

            // Generated Content Sections
            if (_generatedPlan.isNotEmpty) ...[
              _buildSectionHeader('Your Meal Plan'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _isGenerating
                          ? const Center(child: CircularProgressIndicator())
                          : SelectableText(
                            _generatedPlan,
                            style: const TextStyle(fontSize: 15),
                          ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _showRecipeDialog,
                            child: const Text('Get Recipes'),
                          ),
                          ElevatedButton(
                            onPressed: _generateGroceryList,
                            child: const Text('Grocery List'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyToClipboard(_generatedPlan),
                            tooltip: 'Copy Plan',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_showRecipes && _generatedRecipes.isNotEmpty) ...[
              _buildSectionHeader(
                'Recipes for $_selectedDay $_selectedMealType',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _isGenerating
                          ? const Center(child: CircularProgressIndicator())
                          : SelectableText(
                            _generatedRecipes,
                            style: const TextStyle(fontSize: 15),
                          ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed:
                                () => _copyToClipboard(_generatedRecipes),
                            tooltip: 'Copy Recipes',
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed:
                                () => _launchRecipeSearch(
                                  '$_dietType $_selectedMealType',
                                ),
                            tooltip: 'Search Online',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_showGroceryList && _groceryList.isNotEmpty) ...[
              _buildSectionHeader('Grocery Shopping List'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _isGenerating
                          ? const Center(child: CircularProgressIndicator())
                          : SelectableText(
                            _groceryList,
                            style: const TextStyle(fontSize: 15),
                          ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(_groceryList),
                        tooltip: 'Copy List',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Macronutrient Calculator
            _buildSectionHeader('Macronutrient Calculator'),
            const SizedBox(height: 16),
            _buildMacroCalculator(),

            // Additional Resources
            _buildSectionHeader('Additional Resources'),
            const SizedBox(height: 16),
            _buildResourceCard(
              'Nutrition Database',
              Icons.article,
              () => _launchRecipeSearch('nutrition database'),
            ),
            _buildResourceCard(
              'Meal Prep Videos',
              Icons.video_library,
              () => _launchRecipeSearch('meal prep videos'),
            ),
            _buildResourceCard(
              'Healthy Eating Guides',
              Icons.menu_book,
              () => _launchRecipeSearch('healthy eating guides'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNutritionTip(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildQuickSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _recipeSearchController.text = label;
        _searchRecipes();
      },
    );
  }

  Widget _buildMealPlanCard(String title, String calories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _goalController.text = title;
          _calories = double.parse(calories.split('-')[0]);
          _generateMealPlan();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text(calories),
                backgroundColor: Colors.orange.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Calculate your macronutrient needs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _calories,
              min: 1200,
              max: 4000,
              divisions: 28,
              label: _calories.round().toString(),
              onChanged: (value) => setState(() => _calories = value),
            ),
            Text(
              'Daily Calories: ${_calories.round()} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Protein: 30%'),
                Text('Carbs: 40%'),
                Text('Fats: 30%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('Macro')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('%')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('Grams')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('Calories')),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('Protein')),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('30%')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text((_calories * 0.3 / 4).round().toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text((_calories * 0.3).round().toString()),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('Carbs')),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('40%')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text((_calories * 0.4 / 4).round().toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text((_calories * 0.4).round().toString()),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('Fats')),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('30%')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text((_calories * 0.3 / 9).round().toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text((_calories * 0.3).round().toString()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Adjust ratios based on your goals:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildMacroRatioChip('High Protein', '40/30/30'),
                _buildMacroRatioChip('Low Carb', '30/20/50'),
                _buildMacroRatioChip('Balanced', '30/40/30'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRatioChip(String label, String ratio) {
    return FilterChip(
      label: Text('$label ($ratio)'),
      selected: label == 'Balanced',
      onSelected: (selected) {
        // Update ratios based on selection
      },
    );
  }

  Widget _buildResourceCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
