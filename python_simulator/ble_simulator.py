import asyncio
import random
import struct

from bless import (
    BlessServer,
    GATTAttributePermissions,
    GATTCharacteristicProperties,
)


VITALS_SERVICE_UUID = "0000180d-0000-1000-8000-00805f9b34fb"
HEART_RATE_CHAR_UUID = "00002a37-0000-1000-8000-00805f9b34fb"
TEMPERATURE_CHAR_UUID = "00002a1c-0000-1000-8000-00805f9b34fb"


class VitalsSimulator:
    def __init__(self) -> None:
        self.server = BlessServer(name="BLE Vitals Simulator")
        self.heart_rate = 74
        self.temperature_tenths_c = 370

    async def setup(self) -> None:
        await self.server.add_new_service(VITALS_SERVICE_UUID)
        await self.server.add_new_characteristic(
            VITALS_SERVICE_UUID,
            HEART_RATE_CHAR_UUID,
            GATTCharacteristicProperties.read | GATTCharacteristicProperties.notify,
            bytes([0, self.heart_rate]),
            GATTAttributePermissions.readable,
        )
        await self.server.add_new_characteristic(
            VITALS_SERVICE_UUID,
            TEMPERATURE_CHAR_UUID,
            GATTCharacteristicProperties.read | GATTCharacteristicProperties.notify,
            struct.pack("<H", self.temperature_tenths_c),
            GATTAttributePermissions.readable,
        )

    async def publish_loop(self) -> None:
        while True:
            self.heart_rate = max(
                55,
                min(115, self.heart_rate + random.randint(-2, 2)),
            )
            self.temperature_tenths_c = max(
                360,
                min(380, self.temperature_tenths_c + random.randint(-1, 1)),
            )

            self.server.update_value(
                VITALS_SERVICE_UUID,
                HEART_RATE_CHAR_UUID,
                bytes([0, self.heart_rate]),
            )
            self.server.update_value(
                VITALS_SERVICE_UUID,
                TEMPERATURE_CHAR_UUID,
                struct.pack("<H", self.temperature_tenths_c),
            )

            print(
                "Vitals:",
                f"{self.heart_rate} bpm,",
                f"{self.temperature_tenths_c / 10:.1f} C",
            )
            await asyncio.sleep(1)

    async def run(self) -> None:
        await self.setup()
        await self.server.start()
        print("BLE Vitals Simulator started")
        print(f"Service: {VITALS_SERVICE_UUID}")
        print(f"Heart rate: {HEART_RATE_CHAR_UUID}")
        print(f"Temperature: {TEMPERATURE_CHAR_UUID}")
        await self.publish_loop()


if __name__ == "__main__":
    asyncio.run(VitalsSimulator().run())
