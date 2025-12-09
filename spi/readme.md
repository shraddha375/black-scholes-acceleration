## Hardware connections

📌 ESP32 Pins

Using HSPI:

| Signal |  ESP32 GPIO |
|--------|-------------|
|  SCK   |      14     |
|  MOSI  |      13     |
|  MISO  |      12     |
|  CS    |      15     |
|  GND   |      GND    |


📌 Cmod A7-35T PINOUT (DIP Header)

Use these FPGA pins:

|  SPI Signal  |  Cmod A7 DIP Pin  |  FPGA Pin  |   Notes    |
|--------------|-------------------|------------|------------|
| SCK          | A5                |  G17       |SPI clock   |
| MOSI         | A6                |  J18       |ESP32 → FPGA|
| MISO         | A7                |  K15       |FPGA → ESP32|
| CS           | A8                |  L16       |Active-low  |
| GND          | Any GND           |  —         |Needed      |

## Wiring Diagram

    ESP32 GPIO14  ─── SCK  ─── A5  (G17)
    ESP32 GPIO13  ─── MOSI ─── A6  (J18)
    ESP32 GPIO12  ─── MISO ─── A7  (K15)
    ESP32 GPIO15  ─── CS   ─── A8  (L16)
    ESP32 GND     ─────────── GND

⚠ Both boards run at 3.3V → logic-level safe, no converters needed.
