#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pprint import pprint
from pynq import Overlay

overlay = Overlay("/home/xilinx/mvm-project/hw/design_1.bit", download=True)
overlay.download()
pprint(overlay.ip_dict.keys())
