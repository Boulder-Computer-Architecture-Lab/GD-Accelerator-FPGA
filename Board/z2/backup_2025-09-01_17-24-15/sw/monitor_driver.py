from pynq import MMIO

# AXI Performance Monitor (v5.0) : Advanced mode (AXI4-Stream)

class APM:

    # Metric Selection Registers
    MSR0 = 0x044 # counters 0..3
    MSR1 = 0x048 # counters 4..7
    MSR2 = 0x04C # counters 8..9

    # Sample/capture path
    SAMPLE_REG   = 0x02C
    SAMPLED_BASE = 0x200
    SAMPLED_STRIDE = 0x10

    # Global control
    GCR = 0x300    
    GCR_RESET = 0x2
    GCR_START = 0x1

    # AXIS metric IDs
    AXIS_XFER      = 0x10 # Transfer cycle count
    AXIS_PKT       = 0x11 # Packet count
    AXIS_BYTES     = 0x12 # Data byte count
    AXIS_SLV_IDLE  = 0x15 # Slave idle (backpressure)
    AXIS_MST_IDLE  = 0x16 # Master idle

    def __init__(self, base_addr, core_clk_hz):
        self.mmio = MMIO(base_addr, 0x40000)
        self.clk_hz = float(core_clk_hz)

    @staticmethod
    def _sel(slot_id, metric_id):
        return ((slot_id & 0x7) << 5) | (metric_id & 0x1F)

    def _wr_msr0_bytes(self, b0, b1, b2, b3):
        self.mmio.write(self.MSR0, (b3 << 24) | (b2 << 16) | (b1 << 8) | b0)

    def _wr_msr1_bytes(self, b4, b5, b6, b7):
        self.mmio.write(self.MSR1, (b7 << 24) | (b6 << 16) | (b5 << 8) | b4)

    def _read_sampled64(self, index):
        base = self.SAMPLED_BASE + index * self.SAMPLED_STRIDE
        lo = self.mmio.read(base) & 0xFFFFFFFF
        hi = self.mmio.read(base + 4) & 0xFFFFFFFF
        return (hi << 32) | lo

    def reset(self):
        self.mmio.write(self.GCR, self.GCR_RESET)

    def program_two_axis_slots(self, slot_a, slot_b):
        a0 = self._sel(slot_a, self.AXIS_XFER)
        a1 = self._sel(slot_a, self.AXIS_BYTES)
        a2 = self._sel(slot_a, self.AXIS_SLV_IDLE)
        a3 = self._sel(slot_a, self.AXIS_MST_IDLE)
        self._wr_msr0_bytes(a0, a1, a2, a3)

        b4 = self._sel(slot_b, self.AXIS_XFER)
        b5 = self._sel(slot_b, self.AXIS_BYTES)
        b6 = self._sel(slot_b, self.AXIS_SLV_IDLE)
        b7 = self._sel(slot_b, self.AXIS_MST_IDLE)
        self._wr_msr1_bytes(b4, b5, b6, b7)

    def start(self):
        self.mmio.write(self.GCR, self.GCR_START)

    def snapshot(self):
        _ = self.mmio.read(self.SAMPLE_REG)

    def read_slot(self, which):
        idx_base = 0 if which == 0 else 4
        xfer      = self._read_sampled64(idx_base + 0)
        bytes_    = self._read_sampled64(idx_base + 1)
        slv_idle  = self._read_sampled64(idx_base + 2)
        mst_idle  = self._read_sampled64(idx_base + 3)

        total = xfer + slv_idle + mst_idle
        secs  = (total / self.clk_hz) if self.clk_hz else 0.0
        bw    = (bytes_ / secs) if secs > 0 else 0.0

        return {
            "total_cycles": total,
            "active_cycles": xfer,
            "stall_cycles": slv_idle,
            "master_idle_cycles": mst_idle,
            "seconds": secs,
            "bytes": bytes_,
            "bandwidth_Bps": bw,
            "active_pct": (xfer / total) if total else 0.0,
            "stall_pct": (slv_idle / total) if total else 0.0,
            "idle_pct": (mst_idle / total) if total else 0.0,
        }

