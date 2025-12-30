# Image Labeler for CreateML

A simple GUI tool to label images for CreateML multilabel classification training.

## Requirements

- Python 3.7+
- Pillow (PIL)

## Installation

```bash
# Install Pillow (only dependency)
pip install Pillow
```

## Usage

```bash
# Run the labeler
python labeler.py
```

### Steps:

1. Click **"📁 Select Folder"** to choose your images folder
2. Browse through images with **Previous/Next** buttons (or arrow keys)
3. Add labels by:
   - Typing in the text field and pressing Enter or clicking "Add"
   - Clicking any **Quick Tag** button
4. Remove labels by clicking the **×** button next to them
5. The tool **auto-saves** after each change
6. Click **"💾 Save JSON"** to manually save
7. Click **"📋 Export"** to save to a custom location

### Keyboard Shortcuts:

| Key | Action |
|-----|--------|
| `←` Left Arrow | Previous image |
| `→` Right Arrow | Next image |
| `Enter` | Add typed label |
| `Ctrl+S` | Save JSON |

## Output Format

The tool creates an `annotations.json` file in your images folder:

```json
[
    {
        "image": "image1.jpg",
        "annotations": ["Tree", "Car", "Road"]
    },
    {
        "image": "image2.jpg",
        "annotations": ["Mountain", "Sky", "Cloud"]
    }
]
```

This format is compatible with CreateML's multilabel image classification.

## Pre-loaded Tags

The tool comes pre-loaded with tags from the iSpy game:

**Easy:** Traffic Sign, Car, Tree, Building, Cloud, Street Light, Road, Sky, Grass, Bridge

**Medium:** Mountain, Lake, Tunnel, Restaurant, Gas Station, Truck, Boat, Windmill, Farm, Monument

**Hard:** Wildlife, Historic Marker, Scenic Overlook, Vintage Car, Lighthouse, Canyon, Waterfall, Desert, Castle, Cave

## Tips

- New tags you add are automatically saved to Quick Tags
- The tool loads existing `annotations.json` if present (resume labeling)
- Only images with at least one label are included in the export
- Supported formats: JPG, JPEG, PNG, GIF, BMP

