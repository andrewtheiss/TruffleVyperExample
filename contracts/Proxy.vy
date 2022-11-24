# @version ^0.3.7
# Beacon Upgradable

interface Beacon:
    def implementation() -> address: view

BEACON: immutable(Beacon)

@external
def __init__(_beacon: Beacon):
    BEACON = _beacon

@external
def __default__():
    implementation: address = BEACON.implementation()
    raw_call(implementation, msg.data, is_delegate_call = True)

@view
@external
def implementation() -> address:
    return BEACON.implementation()
