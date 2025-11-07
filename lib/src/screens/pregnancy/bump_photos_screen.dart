import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/bump_photo_model.dart';
import '../../providers/pregnancy_provider.dart';

class BumpPhotosScreen extends StatefulWidget {
  const BumpPhotosScreen({super.key});

  @override
  State<BumpPhotosScreen> createState() => _BumpPhotosScreenState();
}

class _BumpPhotosScreenState extends State<BumpPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);
    if (provider.activePregnancy != null) {
      await provider.loadBumpPhotos(
        provider.activePregnancy!.userId,
        provider.activePregnancy!.id,
      );
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    if (provider.activePregnancy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.isBangla
                ? 'কোনো সক্রিয় গর্ভাবস্থা পাওয়া যায়নি'
                : 'No active pregnancy found',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show image source dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              provider.isBangla
                  ? 'ফটো সোর্স নির্বাচন করুন'
                  : 'Select Photo Source',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(provider.isBangla ? 'ক্যামেরা' : 'Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(provider.isBangla ? 'গ্যালারি' : 'Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show add photo dialog
      if (mounted) {
        _showAddPhotoDialog(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isBangla
                  ? 'ফটো নিতে ব্যর্থ: $e'
                  : 'Failed to pick photo: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddPhotoDialog(File imageFile) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);
    final currentWeek = provider.currentWeek;

    int selectedWeek = currentWeek;
    final TextEditingController notesController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController bellySizeController = TextEditingController();
    final List<String> selectedTags = [];

    final availableTags = [
      {'en': 'Happy', 'bn': 'খুশি'},
      {'en': 'Tired', 'bn': 'ক্লান্ত'},
      {'en': 'Glowing', 'bn': 'উজ্জ্বল'},
      {'en': 'Excited', 'bn': 'উত্তেজিত'},
      {'en': 'Bloated', 'bn': 'ফোলা'},
      {'en': 'Energetic', 'bn': 'প্রাণবন্ত'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                provider.isBangla ? 'বাম্প ফটো যোগ করুন' : 'Add Bump Photo',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imageFile,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Week selector
                    Text(
                      provider.isBangla ? 'সপ্তাহ' : 'Week',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: selectedWeek,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List.generate(42, (index) => index + 1)
                          .map((week) => DropdownMenuItem(
                                value: week,
                                child: Text(
                                  provider.isBangla
                                      ? 'সপ্তাহ $week'
                                      : 'Week $week',
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedWeek = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: provider.isBangla
                            ? 'নোট (ঐচ্ছিক)'
                            : 'Notes (optional)',
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: provider.isBangla
                            ? 'ওজন (কেজি) (ঐচ্ছিক)'
                            : 'Weight (kg) (optional)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Belly size
                    TextField(
                      controller: bellySizeController,
                      decoration: InputDecoration(
                        labelText: provider.isBangla
                            ? 'পেটের আকার (সেমি) (ঐচ্ছিক)'
                            : 'Belly Size (cm) (optional)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Text(
                      provider.isBangla ? 'অনুভূতি' : 'Feelings',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTags.map((tag) {
                        final tagLabel =
                            provider.isBangla ? tag['bn']! : tag['en']!;
                        final isSelected = selectedTags.contains(tag['en']);
                        return FilterChip(
                          label: Text(tagLabel),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedTags.add(tag['en']!);
                              } else {
                                selectedTags.remove(tag['en']);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    // Parse values
                    double? weight;
                    double? bellySize;

                    if (weightController.text.isNotEmpty) {
                      weight = double.tryParse(weightController.text);
                    }
                    if (bellySizeController.text.isNotEmpty) {
                      bellySize = double.tryParse(bellySizeController.text);
                    }

                    // Create photo model
                    final photo = BumpPhotoModel(
                      id: '',
                      userId: provider.activePregnancy!.userId,
                      pregnancyId: provider.activePregnancy!.id,
                      week: selectedWeek,
                      photoDate: DateTime.now(),
                      photoUrl: '',
                      notes: notesController.text.trim(),
                      weight: weight,
                      bellySize: bellySize,
                      tags: selectedTags,
                      createdAt: DateTime.now(),
                    );

                    // Upload photo
                    await provider.addBumpPhoto(imageFile, photo);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.isBangla
                                ? 'ফটো সফলভাবে যোগ করা হয়েছে!'
                                : 'Photo added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(provider.isBangla ? 'যোগ করুন' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPhotoDetails(BumpPhotoModel photo) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      photo.photoUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, size: 48),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Week
                    Text(
                      provider.isBangla
                          ? 'সপ্তাহ ${photo.week}'
                          : 'Week ${photo.week}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date
                    Text(
                      photo.formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    if (photo.weight != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.monitor_weight, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${provider.isBangla ? 'ওজন' : 'Weight'}: ${photo.formattedWeight}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Belly size
                    if (photo.bellySize != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.straighten, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${provider.isBangla ? 'পেটের আকার' : 'Belly Size'}: ${photo.formattedBellySize}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Notes
                    if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.isBangla ? 'নোট:' : 'Notes:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(photo.notes!),
                      const SizedBox(height: 8),
                    ],

                    // Tags
                    if (photo.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.isBangla ? 'অনুভূতি:' : 'Feelings:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: photo.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.purple[50],
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _confirmDelete(photo);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: Text(
                provider.isBangla ? 'মুছুন' : 'Delete',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BumpPhotoModel photo) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(provider.isBangla ? 'ফটো মুছুন?' : 'Delete Photo?'),
          content: Text(
            provider.isBangla
                ? 'আপনি কি নিশ্চিত যে আপনি এই ফটোটি মুছতে চান?'
                : 'Are you sure you want to delete this photo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.deleteBumpPhoto(photo);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isBangla
                            ? 'ফটো মুছে ফেলা হয়েছে'
                            : 'Photo deleted',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(provider.isBangla ? 'মুছুন' : 'Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(
      builder: (context, provider, child) {
        final photos = provider.bumpPhotos;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              provider.isBangla ? 'বাম্প ফটো' : 'Bump Photos',
            ),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.isBangla
                                ? 'এখনও কোনো ফটো নেই'
                                : 'No photos yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.isBangla
                                ? 'আপনার বাম্প ফটো যোগ করতে + বাটনে ট্যাপ করুন'
                                : 'Tap the + button to add your bump photos',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isGridView
                      ? _buildGridView(photos)
                      : _buildListView(photos),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _pickAndUploadPhoto,
            icon: const Icon(Icons.add_a_photo),
            label: Text(provider.isBangla ? 'ফটো যোগ করুন' : 'Add Photo'),
            backgroundColor: const Color(0xFFBA68C8),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<BumpPhotoModel> photos) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _buildPhotoCard(photo);
        },
      ),
    );
  }

  Widget _buildListView(List<BumpPhotoModel> photos) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _buildPhotoListTile(photo);
      },
    );
  }

  Widget _buildPhotoCard(BumpPhotoModel photo) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => _showPhotoDetails(photo),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                photo.photoUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.isBangla
                        ? 'সপ্তাহ ${photo.week}'
                        : 'Week ${photo.week}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoListTile(BumpPhotoModel photo) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photo.photoUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              );
            },
          ),
        ),
        title: Text(
          provider.isBangla ? 'সপ্তাহ ${photo.week}' : 'Week ${photo.week}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(photo.formattedDate),
            if (photo.weight != null || photo.bellySize != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (photo.weight != null) photo.formattedWeight,
                  if (photo.bellySize != null) photo.formattedBellySize,
                ].join(' • '),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showPhotoDetails(photo),
      ),
    );
  }
}
