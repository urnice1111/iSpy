#!/usr/bin/env python3
"""
Remove images with a specific tag from a folder.
Usage: python remove_by_tag.py /path/to/folder --tag "Speed Sign" --count 30
"""

import os
import json
import random
import argparse
from pathlib import Path

def remove_images_by_tag(folder_path, tag, count):
    """
    Remove images that have a specific tag.
    
    Args:
        folder_path: Path to folder with images and annotations.json
        tag: Tag to search for
        count: Number of images to remove
    """
    
    folder = Path(folder_path)
    annotations_path = folder / "annotations.json"
    
    if not annotations_path.exists():
        print(f"❌ No annotations.json found in {folder_path}")
        return
    
    # Load annotations
    with open(annotations_path, 'r') as f:
        data = json.load(f)
    
    print(f"📁 Folder: {folder_path}")
    print(f"📋 Total images in JSON: {len(data)}")
    print(f"🏷️  Looking for tag: '{tag}'")
    
    # Find images with the tag
    images_with_tag = []
    for item in data:
        filename = item.get("image", item.get("filename", ""))
        annotations = item.get("annotations", [])
        if tag in annotations:
            images_with_tag.append(filename)
    
    print(f"🔍 Found {len(images_with_tag)} images with tag '{tag}'")
    
    if len(images_with_tag) == 0:
        print("❌ No images found with that tag!")
        return
    
    # Select random images to remove
    to_remove = min(count, len(images_with_tag))
    random.shuffle(images_with_tag)
    images_to_delete = images_with_tag[:to_remove]
    
    print(f"\n🗑️  Will delete {to_remove} images:")
    for img in images_to_delete[:5]:  # Show first 5
        print(f"   - {img}")
    if to_remove > 5:
        print(f"   ... and {to_remove - 5} more")
    
    # Confirm
    confirm = input(f"\n⚠️  Delete {to_remove} images? (yes/no): ")
    if confirm.lower() != 'yes':
        print("❌ Cancelled")
        return
    
    # Delete image files
    deleted_files = 0
    for img in images_to_delete:
        img_path = folder / img
        if img_path.exists():
            os.remove(img_path)
            deleted_files += 1
            print(f"   🗑️  Deleted: {img}")
        else:
            print(f"   ⚠️  File not found: {img}")
    
    # Update JSON - remove entries for deleted images
    new_data = [item for item in data 
                if item.get("image", item.get("filename", "")) not in images_to_delete]
    
    # Save updated JSON
    with open(annotations_path, 'w') as f:
        json.dump(new_data, f, indent=4)
    
    print(f"\n✅ Done!")
    print(f"   Files deleted: {deleted_files}")
    print(f"   JSON entries before: {len(data)}")
    print(f"   JSON entries after: {len(new_data)}")

def main():
    parser = argparse.ArgumentParser(description="Remove images with a specific tag")
    parser.add_argument("folder", help="Path to folder with images and annotations.json")
    parser.add_argument("--tag", type=str, required=True, help="Tag to search for")
    parser.add_argument("--count", type=int, default=30, help="Number of images to remove (default: 30)")
    
    args = parser.parse_args()
    remove_images_by_tag(args.folder, args.tag, args.count)

if __name__ == "__main__":
    main()


