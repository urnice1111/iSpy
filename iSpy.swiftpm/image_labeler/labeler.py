#!/usr/bin/env python3
"""
Image Labeler for CreateML Multilabel Classification
A simple GUI tool to label images and export to CreateML JSON format.
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import json
import os
from pathlib import Path

try:
    from PIL import Image, ImageTk
except ImportError:
    print("Please install Pillow: pip install Pillow")
    exit(1)


class ImageLabeler:
    def __init__(self, root):
        self.root = root
        self.root.title("Image Labeler for CreateML")
        self.root.geometry("900x750")
        self.root.minsize(800, 700)
        
        # Data
        self.image_folder = None
        self.image_files = []
        self.current_index = 0
        self.annotations = {}  # filename -> list of labels
        self.all_tags = set()  # All tags ever used (for quick tags)
        
        # Default quick tags (from iSpy game)
        self.default_tags = [
            # "Traffic Sign", "Car", "Tree", "Building", "Cloud", 
            # "Street Light", "Road", "Sky", "Grass", "Bridge",
            # "Mountain", "Lake", "Tunnel", "Restaurant", "Gas Station",
            # "Truck", "Boat", "Windmill", "Farm", "Monument",
            # "Wildlife", "Historic Marker", "Scenic Overlook", "Vintage Car",
            # "Lighthouse", "Canyon", "Waterfall", "Desert", "Castle", "Cave"
        ]
        self.all_tags.update(self.default_tags)
        
        self.setup_ui()
        
    def setup_ui(self):
        # Main container
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Top bar - folder selection and save
        top_frame = ttk.Frame(main_frame)
        top_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Button(top_frame, text="📁 Select Folder", command=self.select_folder).pack(side=tk.LEFT)
        
        self.progress_label = ttk.Label(top_frame, text="No images loaded")
        self.progress_label.pack(side=tk.LEFT, padx=20)
        
        ttk.Button(top_frame, text="💾 Save JSON", command=self.save_json).pack(side=tk.RIGHT)
        ttk.Button(top_frame, text="📋 Export", command=self.export_json).pack(side=tk.RIGHT, padx=5)
        
        # Image display
        self.image_frame = ttk.LabelFrame(main_frame, text="Image Preview", padding="5")
        self.image_frame.pack(fill=tk.BOTH, expand=True, pady=5)
        
        self.image_label = ttk.Label(self.image_frame, text="Select a folder to start", anchor="center")
        self.image_label.pack(fill=tk.BOTH, expand=True)
        
        # Filename label
        self.filename_label = ttk.Label(main_frame, text="", font=("Arial", 10, "italic"))
        self.filename_label.pack(pady=5)
        
        # Current labels section
        labels_frame = ttk.LabelFrame(main_frame, text="Current Labels", padding="5")
        labels_frame.pack(fill=tk.X, pady=5)
        
        self.labels_container = ttk.Frame(labels_frame)
        self.labels_container.pack(fill=tk.X)
        
        # Add label section
        add_frame = ttk.LabelFrame(main_frame, text="Add Label", padding="5")
        add_frame.pack(fill=tk.X, pady=5)
        
        add_inner = ttk.Frame(add_frame)
        add_inner.pack(fill=tk.X)
        
        self.label_entry = ttk.Entry(add_inner, width=40)
        self.label_entry.pack(side=tk.LEFT, padx=(0, 10))
        self.label_entry.bind("<Return>", lambda e: self.add_label())
        
        ttk.Button(add_inner, text="➕ Add", command=self.add_label).pack(side=tk.LEFT)
        
        # Quick tags section
        quick_frame = ttk.LabelFrame(main_frame, text="Quick Tags (click to add)", padding="5")
        quick_frame.pack(fill=tk.X, pady=5)
        
        # Create scrollable frame for quick tags
        self.quick_tags_canvas = tk.Canvas(quick_frame, height=100)
        scrollbar = ttk.Scrollbar(quick_frame, orient="vertical", command=self.quick_tags_canvas.yview)
        self.quick_tags_frame = ttk.Frame(self.quick_tags_canvas)
        
        self.quick_tags_frame.bind(
            "<Configure>",
            lambda e: self.quick_tags_canvas.configure(scrollregion=self.quick_tags_canvas.bbox("all"))
        )
        
        self.quick_tags_canvas.create_window((0, 0), window=self.quick_tags_frame, anchor="nw")
        self.quick_tags_canvas.configure(yscrollcommand=scrollbar.set)
        
        self.quick_tags_canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        self.update_quick_tags()
        
        # Navigation buttons
        nav_frame = ttk.Frame(main_frame)
        nav_frame.pack(fill=tk.X, pady=10)
        
        ttk.Button(nav_frame, text="◀ Previous", command=self.prev_image, width=15).pack(side=tk.LEFT, expand=True)
        ttk.Button(nav_frame, text="Next ▶", command=self.next_image, width=15).pack(side=tk.RIGHT, expand=True)
        
        # Keyboard shortcuts
        self.root.bind("<Left>", lambda e: self.prev_image())
        self.root.bind("<Right>", lambda e: self.next_image())
        self.root.bind("<Control-s>", lambda e: self.save_json())
        
    def select_folder(self):
        folder = filedialog.askdirectory(title="Select folder with images")
        if folder:
            self.image_folder = folder
            self.load_images()
            self.load_existing_annotations()
            self.show_current_image()
            
    def load_images(self):
        """Load all image files from the selected folder"""
        valid_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp'}
        self.image_files = []
        
        for file in sorted(os.listdir(self.image_folder)):
            if Path(file).suffix.lower() in valid_extensions:
                self.image_files.append(file)
                
        self.current_index = 0
        
        if not self.image_files:
            messagebox.showwarning("No Images", "No image files found in the selected folder.")
            
    def load_existing_annotations(self):
        """Load existing annotations.json if present"""
        json_path = os.path.join(self.image_folder, "annotations.json")
        if os.path.exists(json_path):
            try:
                with open(json_path, 'r') as f:
                    data = json.load(f)
                    for item in data:
                        # Support both "image" and "filename" for backwards compatibility
                        filename = item.get("image", item.get("filename", ""))
                        labels = item.get("annotations", [])
                        self.annotations[filename] = labels
                        self.all_tags.update(labels)
                    self.update_quick_tags()
                    messagebox.showinfo("Loaded", f"Loaded existing annotations for {len(data)} images.")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load annotations: {e}")
                
    def show_current_image(self):
        """Display the current image"""
        if not self.image_files:
            return
            
        filename = self.image_files[self.current_index]
        filepath = os.path.join(self.image_folder, filename)
        
        try:
            # Load and resize image to fit
            img = Image.open(filepath)
            
            # Calculate size to fit in frame (max 600x400)
            max_width, max_height = 700, 350
            ratio = min(max_width / img.width, max_height / img.height)
            new_size = (int(img.width * ratio), int(img.height * ratio))
            img = img.resize(new_size, Image.Resampling.LANCZOS)
            
            self.photo = ImageTk.PhotoImage(img)
            self.image_label.config(image=self.photo, text="")
            
        except Exception as e:
            self.image_label.config(image="", text=f"Error loading image: {e}")
            
        # Update progress and filename
        self.progress_label.config(text=f"Image {self.current_index + 1} of {len(self.image_files)}")
        self.filename_label.config(text=filename)
        
        # Update labels display
        self.update_labels_display()
        
    def update_labels_display(self):
        """Update the current labels display"""
        # Clear existing labels
        for widget in self.labels_container.winfo_children():
            widget.destroy()
            
        if not self.image_files:
            return
            
        filename = self.image_files[self.current_index]
        labels = self.annotations.get(filename, [])
        
        if not labels:
            ttk.Label(self.labels_container, text="No labels yet", foreground="gray").pack(side=tk.LEFT)
            return
            
        for label in labels:
            frame = ttk.Frame(self.labels_container)
            frame.pack(side=tk.LEFT, padx=2)
            
            ttk.Label(frame, text=label, background="#e0e0e0", padding="5 2").pack(side=tk.LEFT)
            ttk.Button(frame, text="×", width=2, 
                      command=lambda l=label: self.remove_label(l)).pack(side=tk.LEFT)
                      
    def add_label(self, label=None):
        """Add a label to the current image"""
        if not self.image_files:
            return
            
        if label is None:
            label = self.label_entry.get().strip()
            self.label_entry.delete(0, tk.END)
            
        if not label:
            return
            
        filename = self.image_files[self.current_index]
        
        if filename not in self.annotations:
            self.annotations[filename] = []
            
        if label not in self.annotations[filename]:
            self.annotations[filename].append(label)
            
        # Add to quick tags if new
        if label not in self.all_tags:
            self.all_tags.add(label)
            self.update_quick_tags()
            
        self.update_labels_display()
        self.auto_save()
        
    def remove_label(self, label):
        """Remove a label from the current image"""
        if not self.image_files:
            return
            
        filename = self.image_files[self.current_index]
        
        if filename in self.annotations and label in self.annotations[filename]:
            self.annotations[filename].remove(label)
            
        self.update_labels_display()
        self.auto_save()
        
    def update_quick_tags(self):
        """Update the quick tags buttons"""
        # Clear existing
        for widget in self.quick_tags_frame.winfo_children():
            widget.destroy()
            
        # Sort tags alphabetically
        sorted_tags = sorted(self.all_tags)
        
        # Create buttons in a grid
        cols = 6
        for i, tag in enumerate(sorted_tags):
            row, col = divmod(i, cols)
            btn = ttk.Button(self.quick_tags_frame, text=tag, width=15,
                           command=lambda t=tag: self.add_label(t))
            btn.grid(row=row, column=col, padx=2, pady=2)
            
    def prev_image(self):
        """Go to previous image"""
        if self.image_files and self.current_index > 0:
            self.current_index -= 1
            self.show_current_image()
            
    def next_image(self):
        """Go to next image"""
        if self.image_files and self.current_index < len(self.image_files) - 1:
            self.current_index += 1
            self.show_current_image()
            
    def auto_save(self):
        """Auto-save annotations to JSON"""
        if self.image_folder:
            self.save_json(silent=True)
            
    def save_json(self, silent=False):
        """Save annotations to JSON file"""
        if not self.image_folder:
            if not silent:
                messagebox.showwarning("No Folder", "Please select a folder first.")
            return
            
        # Build JSON structure
        data = []
        for filename in self.image_files:
            labels = self.annotations.get(filename, [])
            if labels:  # Only include images with labels
                data.append({
                    "image": filename,
                    "annotations": labels
                })
                
        # Save to file
        json_path = os.path.join(self.image_folder, "annotations.json")
        try:
            with open(json_path, 'w') as f:
                json.dump(data, f, indent=4)
            if not silent:
                messagebox.showinfo("Saved", f"Saved annotations for {len(data)} images to:\n{json_path}")
        except Exception as e:
            if not silent:
                messagebox.showerror("Error", f"Failed to save: {e}")
                
    def export_json(self):
        """Export annotations to a chosen location"""
        if not self.annotations:
            messagebox.showwarning("No Data", "No annotations to export.")
            return
            
        filepath = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json")],
            initialfile="annotations.json"
        )
        
        if filepath:
            data = []
            for filename in self.image_files:
                labels = self.annotations.get(filename, [])
                if labels:
                    data.append({
                        "image": filename,
                        "annotations": labels
                    })
                    
            with open(filepath, 'w') as f:
                json.dump(data, f, indent=4)
            messagebox.showinfo("Exported", f"Exported {len(data)} annotations to:\n{filepath}")


def main():
    root = tk.Tk()
    app = ImageLabeler(root)
    root.mainloop()


if __name__ == "__main__":
    main()

