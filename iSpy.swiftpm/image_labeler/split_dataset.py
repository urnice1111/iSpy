#!/usr/bin/env python3
"""
Split dataset into training and testing folders.
Usage: python split_dataset.py /path/to/images --train 30 --test 100
"""

import os
import json
import shutil
import random
import argparse
from pathlib import Path

def split_dataset(source_folder, train_count=30, test_count=100):
    """
    Split images into training and testing sets.
    
    Args:
        source_folder: Path to folder with images and annotations.json
        train_count: Number of images for training
        test_count: Number of images for testing
    """
    
    source_path = Path(source_folder)
    
    # Create output folders
    train_folder = source_path / "training"
    test_folder = source_path / "testing"
    
    train_folder.mkdir(exist_ok=True)
    test_folder.mkdir(exist_ok=True)
    
    print(f"📁 Source folder: {source_folder}")
    print(f"📁 Training folder: {train_folder}")
    print(f"📁 Testing folder: {test_folder}")
    
    # Get all image files
    valid_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp'}
    all_images = [f for f in os.listdir(source_folder) 
                  if Path(f).suffix.lower() in valid_extensions]
    
    print(f"\n📷 Total images found: {len(all_images)}")
    
    if len(all_images) < train_count + test_count:
        print(f"⚠️  Warning: Not enough images! Need {train_count + test_count}, have {len(all_images)}")
        print("   Adjusting counts...")
        total_needed = train_count + test_count
        ratio = len(all_images) / total_needed
        train_count = int(train_count * ratio)
        test_count = int(test_count * ratio)
    
    # Shuffle and split
    random.shuffle(all_images)
    
    test_images = all_images[:test_count]
    train_images = all_images[test_count:test_count + train_count]
    
    print(f"\n🎲 Randomly selected:")
    print(f"   Training: {len(train_images)} images")
    print(f"   Testing:  {len(test_images)} images")
    
    # Load existing annotations if available
    annotations_path = source_path / "annotations.json"
    annotations_dict = {}
    
    if annotations_path.exists():
        with open(annotations_path, 'r') as f:
            data = json.load(f)
            for item in data:
                filename = item.get("image", item.get("filename", ""))
                annotations_dict[filename] = item.get("annotations", [])
        print(f"\n📋 Loaded annotations for {len(annotations_dict)} images")
    
    # Copy images and create annotation files
    train_annotations = []
    test_annotations = []
    
    print("\n📦 Copying training images...")
    for img in train_images:
        # Copy image
        src = source_path / img
        dst = train_folder / img
        shutil.copy2(src, dst)
        
        # Add annotation if exists
        if img in annotations_dict:
            train_annotations.append({
                "image": img,
                "annotations": annotations_dict[img]
            })
    
    print("📦 Copying testing images...")
    for img in test_images:
        # Copy image
        src = source_path / img
        dst = test_folder / img
        shutil.copy2(src, dst)
        
        # Add annotation if exists
        if img in annotations_dict:
            test_annotations.append({
                "image": img,
                "annotations": annotations_dict[img]
            })
    
    # Save annotation files
    if train_annotations:
        train_json_path = train_folder / "annotations.json"
        with open(train_json_path, 'w') as f:
            json.dump(train_annotations, f, indent=4)
        print(f"\n✅ Saved training annotations: {train_json_path}")
    
    if test_annotations:
        test_json_path = test_folder / "annotations.json"
        with open(test_json_path, 'w') as f:
            json.dump(test_annotations, f, indent=4)
        print(f"✅ Saved testing annotations: {test_json_path}")
    
    # Summary
    print("\n" + "="*50)
    print("📊 SUMMARY")
    print("="*50)
    print(f"Training folder: {len(train_images)} images, {len(train_annotations)} annotated")
    print(f"Testing folder:  {len(test_images)} images, {len(test_annotations)} annotated")
    print("="*50)
    print("\n✨ Done!")

def main():
    parser = argparse.ArgumentParser(description="Split dataset into training and testing sets")
    parser.add_argument("source", help="Path to source folder with images")
    parser.add_argument("--train", type=int, default=30, help="Number of training images (default: 30)")
    parser.add_argument("--test", type=int, default=100, help="Number of testing images (default: 100)")
    parser.add_argument("--seed", type=int, default=None, help="Random seed for reproducibility")
    
    args = parser.parse_args()
    
    if args.seed is not None:
        random.seed(args.seed)
        print(f"🎲 Using random seed: {args.seed}")
    
    split_dataset(args.source, args.train, args.test)

if __name__ == "__main__":
    main()

