from typing import Dict, Any

ATTACK_LABELS: Dict[int, str] = {
    0: "Normal",
    1: "ConstPos",
    2: "ConstPosOffset",
    4: "Random",
    8: "RandomOffset",
    16: "EventualStop",
    32: "Sybil",
    64: "Dos"
}

def map_raw_attacker_type(raw_val: Any) -> int:
    try:
        val = int(raw_val)
        return val if val in ATTACK_LABELS else 0
    except (ValueError, TypeError):
        return 0

def is_malicious(attacker_type: int) -> int:
    return 1 if attacker_type != 0 else 0
