#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pprint import pprint
from pynq import Overlay, PL

PL.reset()
overlay = Overlay("/home/xilinx/mvm-project/hw/design_1.bit")
#overlay = Overlay("/home/xilinx/mvm-project/tests/async_2x2/design_1.bit")
overlay.download()
pprint(overlay.ip_dict.keys())
