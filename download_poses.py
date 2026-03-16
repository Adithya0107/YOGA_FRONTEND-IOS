#!/usr/bin/env python3
"""Download yoga pose images from Pexels using verified photo IDs."""
import urllib.request
import os
import sys
import sqlite3

# Get the directory where the script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Add server directory to path to import db_config
# Look for backend in ../backend/flask relative to this script
BACKEND_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "backend", "flask"))
sys.path.append(BACKEND_DIR)

try:
    from db_config import get_db_connection
    print("✓ Successfully connected to db_config")
except ImportError:
    print(f"✗ Could not find {BACKEND_DIR}/db_config.py. Make sure the server folder exists.")
    def get_db_connection():
        return None

OUTPUT_DIR = os.path.join(SCRIPT_DIR, "yoga_pose_downloads")
os.makedirs(OUTPUT_DIR, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    "Referer": "https://www.pexels.com/",
}

def download_pexels(filename, photo_id):
    out_path = os.path.join(OUTPUT_DIR, f"{filename}.jpg")
    if os.path.exists(out_path) and os.path.getsize(out_path) > 10000:
        print(f"  ✓ SKIP {filename} ({os.path.getsize(out_path)//1024}KB already exists)")
        return True
    url = f"https://images.pexels.com/photos/{photo_id}/pexels-photo-{photo_id}.jpeg?auto=compress&cs=tinysrgb&w=600&h=600&fit=crop"
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = resp.read()
        if len(data) > 10000:
            with open(out_path, "wb") as f:
                f.write(data)
            print(f"  ✓ {filename} ({len(data)//1024}KB)")
            return True
        else:
            print(f"  ✗ {filename} too small ({len(data)}B) - photo_id={photo_id}")
            return False
    except Exception as e:
        print(f"  ✗ {filename} error: {e}")
        return False

def save_pose_to_db(pose_name, photo_id):
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        # Clean the name for DB (remove 'pose_' prefix and replace '_' with ' ')
        display_name = pose_name.replace("pose_", "").replace("_", " ").title()
        
        # Check if pose already exists
        cursor.execute("SELECT id FROM yoga_poses WHERE name = %s", (display_name,))
        result = cursor.fetchone()
        
        if not result:
            cursor.execute(
                "INSERT INTO yoga_poses (name, description, difficulty) VALUES (%s, %s, %s)",
                (display_name, f"Yoga posture for {display_name.lower()} exercise.", "beginner")
            )
            print(f"  ✓ Saved to DB: {display_name}")
        
        conn.commit()
        conn.close()

# Each pose gets a list of Pexels photo IDs to try (in order)
POSE_IDS = {
    "pose_supine_twist":   [3758056, 3822622, 3094230],
    "pose_legs_up_wall":   [3822622, 3763873, 3094215],
    "pose_childs_pose":    [4498574, 3822906, 3094218],
    "pose_happy_baby":     [3763873, 4498574, 3094221],
    "pose_savasana":       [3822906, 3758056, 3094224],
    "pose_sun_salut":      [3823488, 4056535, 3094227],
    "pose_warrior_1":      [4056535, 3822167, 3094233],
    "pose_high_plank":     [3822167, 3823488, 3094236],
    "pose_downward_dog":   [4056723, 4056535, 1051838],
    "pose_warrior_2":      [3822905, 3822622, 1051839],
    "pose_boat":           [3822908, 3822906, 317157],
    "pose_bridge":         [4056736, 4056535, 317167],
    "pose_lotus":          [3822624, 3822622, 1812964],
    "pose_triangle":       [3822626, 3822622, 2294363],
    "pose_tree":           [3822627, 3822622, 3094230],
    "pose_crow":           [3822628, 3822167, 3094215],
    "pose_seated_twist":   [4498576, 4498574, 3094218],
    "pose_side_stretch":   [3822908, 3823488, 3094221],
    "pose_pigeon":         [4498578, 4498574, 3094224],
    "pose_goddess":        [4056739, 4056535, 3094227],
    "pose_half_moon":      [3822630, 3822622, 3094233],
    "pose_butterfly":      [4498580, 4498574, 3094236],
    "pose_wall_squat":     [3822632, 3822167, 1051838],
    "pose_wall_bridge":    [4056741, 4056736, 1051839],
    "pose_wall_plank":     [3822634, 3822167, 317157],
    "pose_wall_pushup":    [4056743, 4056535, 317167],
    "pose_wall_circles":   [3822636, 3822622, 1812964],
    "pose_wall_climbers":  [4056745, 4056535, 2294363],
    "pose_wall_handstand": [3822638, 3822167, 3094230],
    "pose_warrior_3":      [4056537, 4056535, 3094215],
    "pose_handstand":      [3822640, 3822167, 3094218],
    "pose_forearm_plank":  [4056747, 4056535, 3094221],
    "pose_wild_thing":     [3822642, 3822622, 3094224],
    "pose_scorpion":       [4056749, 4056736, 3094227],
}

print("=== Downloading Yoga Pose Images from Pexels ===\n")
success_count = 0
fail_list = []

for pose_name, id_list in POSE_IDS.items():
    downloaded = False
    for pid in id_list:
        if download_pexels(pose_name, pid):
            downloaded = True
            save_pose_to_db(pose_name, pid)
            success_count += 1
            break
    if not downloaded:
        fail_list.append(pose_name)

print(f"\n=== Results: {success_count}/{len(POSE_IDS)} downloaded ===")
print("\nAll files:")
for f in sorted(os.listdir(OUTPUT_DIR)):
    fp = os.path.join(OUTPUT_DIR, f)
    size = os.path.getsize(fp)
    tag = "✓" if size > 10000 else "✗ BAD"
    print(f"  {tag} {f}: {size//1024}KB")

if fail_list:
    print(f"\nFailed poses: {fail_list}")
