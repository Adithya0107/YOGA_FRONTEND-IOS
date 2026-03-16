#!/usr/bin/env python3
"""Add all downloaded yoga pose images into Xcode Assets.xcassets."""
import os
import shutil
import json

# Get the directory where the script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

DOWNLOADS_DIR = os.path.join(SCRIPT_DIR, "yoga_pose_downloads")
ASSETS_DIR = os.path.join(SCRIPT_DIR, "yoga/Assets.xcassets")

POSES = [
    "pose_supine_twist",
    "pose_legs_up_wall",
    "pose_childs_pose",
    "pose_happy_baby",
    "pose_savasana",
    "pose_sun_salut",
    "pose_warrior_1",
    "pose_high_plank",
    "pose_downward_dog",
    "pose_warrior_2",
    "pose_boat",
    "pose_bridge",
    "pose_lotus",
    "pose_triangle",
    "pose_tree",
    "pose_crow",
    "pose_seated_twist",
    "pose_side_stretch",
    "pose_pigeon",
    "pose_goddess",
    "pose_half_moon",
    "pose_butterfly",
    "pose_wall_squat",
    "pose_wall_bridge",
    "pose_wall_plank",
    "pose_wall_pushup",
    "pose_wall_circles",
    "pose_wall_climbers",
    "pose_wall_handstand",
    "pose_warrior_3",
    "pose_handstand",
    "pose_forearm_plank",
    "pose_wild_thing",
    "pose_scorpion",
]

contents_template = {
    "images": [
        {
            "filename": "",
            "idiom": "universal",
            "scale": "1x"
        },
        {
            "idiom": "universal",
            "scale": "2x"
        },
        {
            "idiom": "universal",
            "scale": "3x"
        }
    ],
    "info": {
        "author": "xcode",
        "version": 1
    }
}

added = 0
skipped = 0
errors = []

for pose in POSES:
    src_jpg = os.path.join(DOWNLOADS_DIR, f"{pose}.jpg")
    if not os.path.exists(src_jpg):
        print(f"  ✗ MISSING source: {pose}.jpg")
        errors.append(pose)
        continue
    if os.path.getsize(src_jpg) < 5000:
        print(f"  ✗ TOO SMALL: {pose}.jpg ({os.path.getsize(src_jpg)}B)")
        errors.append(pose)
        continue

    # Create imageset folder
    imageset_dir = os.path.join(ASSETS_DIR, f"{pose}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)

    # Copy image
    dst_img = os.path.join(imageset_dir, f"{pose}.jpg")
    shutil.copy2(src_jpg, dst_img)

    # Write Contents.json
    contents = dict(contents_template)
    contents["images"] = [
        {"filename": f"{pose}.jpg", "idiom": "universal", "scale": "1x"},
        {"idiom": "universal", "scale": "2x"},
        {"idiom": "universal", "scale": "3x"}
    ]
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

    print(f"  ✓ Added {pose} to Assets.xcassets ({os.path.getsize(src_jpg)//1024}KB)")
    added += 1

print(f"\n=== Done: {added} added, {skipped} skipped, {len(errors)} errors ===")
if errors:
    print(f"Errors: {errors}")

print("\nAssets.xcassets now contains:")
for d in sorted(os.listdir(ASSETS_DIR)):
    if d.endswith(".imageset") and d.startswith("pose_"):
        print(f"  ✓ {d}")
