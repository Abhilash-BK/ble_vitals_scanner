import asyncio
import random
import struct

from bless import (
    BlessServer,
    GATTAttributePermissions,
    GATTCharacteristicProperties,
)


DEVICE_NAME = "BLE Vitals Simulator"
HEART_RATE_SERVICE_UUID = "0000180d-0000-1000-8000-00805f9b34fb"
HEART_RATE_MEASUREMENT_UUID = "00002a37-0000-1000-8000-00805f9b34fb"
HEALTH_THERMOMETER_SERVICE_UUID = "00001809-0000-1000-8000-00805f9b34fb"
TEMPERATURE_MEASUREMENT_UUID = "00002a1c-0000-1000-8000-00805f9b34fb"


class BleVitalsSimulator:
    def __init__(self) -> None:
        self.server = BlessServer(name=DEVICE_NAME)
        self.heart_rate = 76
        self.temperature_c = 36.8

    async def setup(self) -> None:
        await self.server.add_new_service(HEART_RATE_SERVICE_UUID)
        await self.server.add_new_characteristic(
            HEART_RATE_SERVICE_UUID,
            HEART_RATE_MEASUREMENT_UUID,
            GATTCharacteristicProperties.read | GATTCharacteristicProperties.notify,
            self._heart_rate_payload(),
            GATTAttributePermissions.readable,
        )

        await self.server.add_new_service(HEALTH_THERMOMETER_SERVICE_UUID)
        await self.server.add_new_characteristic(
            HEALTH_THERMOMETER_SERVICE_UUID,
            TEMPERATURE_MEASUREMENT_UUID,
            GATTCharacteristicProperties.read | GATTCharacteristicProperties.notify,
            self._temperature_payload(),
            GATTAttributePermissions.readable,
        )

    def _heart_rate_payload(self) -> bytes:
        # Bluetooth Heart Rate Measurement: flags byte 0, then uint8 bpm.
        return bytes([0x00, self.heart_rate])

    def _temperature_payload(self) -> bytes:
        # The Flutter MVP parser expects little-endian tenths of Celsius.
        return struct.pack("<H", int(round(self.temperature_c * 10)))

    async def publish_loop(self) -> None:
        while True:
            self.heart_rate = max(58, min(112, self.heart_rate + random.randint(-2, 2)))
            self.temperature_c = max(
                36.0,
                min(38.0, self.temperature_c + random.choice([-0.1, 0.0, 0.1])),
            )

            self.server.update_value(
                HEART_RATE_SERVICE_UUID,
                HEART_RATE_MEASUREMENT_UUID,
                self._heart_rate_payload(),
            )
            self.server.update_value(
                HEALTH_THERMOMETER_SERVICE_UUID,
                TEMPERATURE_MEASUREMENT_UUID,
                self._temperature_payload(),
            )

            print(
                f"Advertising {DEVICE_NAME}: "
                f"{self.heart_rate} bpm, {self.temperature_c:.1f} C"
            )
            await asyncio.sleep(1)

    async def run(self) -> None:
        await self.setup()
        await self.server.start()
        print(f"{DEVICE_NAME} started")
        print(f"Heart Rate Service: {HEART_RATE_SERVICE_UUID}")
        print(f"Heart Rate Measurement: {HEART_RATE_MEASUREMENT_UUID}")
        print(f"Health Thermometer Service: {HEALTH_THERMOMETER_SERVICE_UUID}")
        print(f"Temperature Measurement: {TEMPERATURE_MEASUREMENT_UUID}")
        await self.publish_loop()


if __name__ == "__main__":
    asyncio.run(BleVitalsSimulator().run())
