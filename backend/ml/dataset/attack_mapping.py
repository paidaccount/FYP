from typing import Any

ATTACK_LABELS = {
    0: "Normal Vehicle",
    1: "False Position Attack",
    2: "False Speed Attack",
    3: "Replay Attack",
    4: "Sybil Attack",
    5: "DoS Attack",
    6: "Message Injection",
    7: "GPS Spoofing",
    8: "Fake Emergency Message"
}

def map_raw_attacker_type(attacker_type: Any) -> int:
    try:
        val = int(attacker_type)
        if val in ATTACK_LABELS:
            return val
    except (ValueError, TypeError):
        pass
    return 0

def is_malicious(attacker_type: int) -> int:
    return 1 if attacker_type > 0 else 0
