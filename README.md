UART FPGA Command Processor (VHDL)
Projektbeschreibung
Dieses Projekt implementiert ein vollständiges UART-basiertes Kommandoverarbeitungssystem auf FPGA-Basis. Über eine serielle UART-Schnittstelle werden Befehle gesendet, empfangen, dekodiert und durch eine ALU verarbeitet.

Das System besteht aus:

UART Transmitter
UART Receiver mit Oversampling
Decoder mit Handshake-Protokoll
Synchroner ALU
Top-Level-Integration
Das Design wurde vollständig simuliert, implementiert und zeitlich analysiert (Timing Closure bei 100 MHz).

Project Description
This project implements a complete UART-based command processing system on FPGA. Commands are received via UART, decoded and executed by an ALU.

The system includes:

UART Transmitter
UART Receiver with oversampling
Decoder with handshake protocol
Synchronous ALU
Top-level system integration
The design was fully simulated, implemented and verified with timing closure at 100 MHz.

Architektur / Architecture
Each module communicates synchronously using valid/ack handshake signals.

Implementierte Module / Implemented Modules
UART_TX
FSM-basierter UART-Sender
Parametrisierbare Baudrate
Startbit, Datenbits, Stopbit
UART_RX
UART-Empfänger mit 16× Oversampling
Metastabilitätsvermeidung durch Synchronisation
Saubere Startbit-Erkennung

Decoder
Extrahiert Opcode und Operanden
Implementiert cmd_valid / cmd_ack Handshake

ALU
Arithmetische Operationen: Add, Sub, Mul, Div
Synchrones Design
Ergebnisbereitstellung für Rückübertragung
Verifikation / Verification
Systemweite Testbench (uart_top_tb.v)
UART Loopback (TX → RX)

Funktionale Simulation
Post-Implementation Timing Analyse
Timing & Constraints
System Clock: 100 MHz
Alle Setup- und Hold-Zeiten erfüllt
Keine Timing Violations nach Implementation

Tools
VHDL HDL
Xilinx Vivado
RTL Simulation & Post-Implementation Timing Analysis


Autor / Author
Dylann Kinfack
GitHub: https://github.com/DyKinfack
