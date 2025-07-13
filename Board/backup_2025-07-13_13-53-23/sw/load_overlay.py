#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pynq import Overlay, MMIO
from time import sleep
import subprocess, os

PROJ_DIR = "/home/xilinx/mvm-project/hw/"
DTBO_NAME = "axi_ram.dtbo"
OVERLAY_NAME = "axi_ram"
OVERLAY_PATH = f"/sys/kernel/config/device-tree/overlays/{OVERLAY_NAME}"

if __name__ == "__main__":
    # Remove old overlay if applied
    if os.path.exists(OVERLAY_PATH):
        try:
            subprocess.run(["rmdir", OVERLAY_PATH], check=True)
            print("Previous overlay removed.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to remove old overlay: {e}")

    # Load the new device tree overlay
    try:
        os.makedirs(OVERLAY_PATH, exist_ok=True)
        subprocess.run(
            ["cp", f"{PROJ_DIR}{DTBO_NAME}", f"{OVERLAY_PATH}/dtbo"],
            check=True
        )
        print("Device tree overlay applied.")
        sleep(0.1)
    except subprocess.CalledProcessError as e:
        print(f"Failed to apply device tree overlay: {e}")

