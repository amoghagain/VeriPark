# Smart Parking System – Verilog Implementation

This project implements a **Verilog-based Smart Parking System** that controls and monitors the entry and exit of vehicles using sensors, password verification, and finite state machine (FSM) logic.

---

## 🚗 Overview

The system manages a parking area with the following features:
- Detects vehicles at the **entrance** and **exit** using sensor inputs.
- Validates access using a **4-bit password**.
- Tracks the number of parked vehicles using a **4-bit counter**.
- Operates based on a **Finite State Machine (FSM)** with five states.
- Provides real-time feedback using **RED** and **GREEN** LEDs and a 3-bit `indicator`.

---

## 🔧 Module I/O

### Inputs
- `clk`: Clock signal.
- `reset_n`: Active-high asynchronous reset.
- `sensor_entrance`: High when a vehicle is detected at the entrance.
- `sensor_exit`: High when a vehicle is detected at the exit.
- `password [3:0]`: 4-bit password input (correct password: `4'b1011`).

### Outputs
- `GREEN_LED`: Blinks in the `RIGHT_PASS` state to indicate access granted.
- `RED_LED`: Blinks in `WRONG_PASS` or `STOP` states to indicate access denied or waiting.
- `countcar [3:0]`: Number of cars currently in the parking lot.
- `indicator [2:0]`: Shows the current FSM state.

---

## 🔁 FSM States

| State         | Code   | Description                                                                 |
|---------------|--------|-----------------------------------------------------------------------------|
| `IDLE`        | 000    | Waiting for a car at entrance.                                              |
| `WAIT_PASSWORD` | 001  | Car detected, waiting for password.                                         |
| `WRONG_PASS`  | 010    | Invalid password entered. Blinks RED LED.                                   |
| `RIGHT_PASS`  | 011    | Valid password. Allows entry. Blinks GREEN LED.                             |
| `STOP`        | 100    | Waiting for both entrance and exit sensors. Used for blocking or reset logic.|

---

## 🔄 Behavior Summary

- System begins in the `IDLE` state.
- When a car is detected at the entrance, it moves to `WAIT_PASSWORD`.
- If the password is incorrect (`!= 4'b1011`), it enters `WRONG_PASS` and blinks RED.
- On correct password, it enters `RIGHT_PASS` and blinks GREEN while increasing the car counter.
- If both entrance and exit sensors are high, it moves to `STOP` (system hold).
- The system transitions back to `IDLE` after successful entry or exit.

---

## 🛠 Future Enhancements

- Integrate a 7-segment display module to show the count of cars.
- Add time-based auto reset.
- Interface with a real-time clock (RTC) for time-stamped access logging.

---

## 📁 File Structure

- `parking_system.v`: Main Verilog module implementing the FSM, sensor logic, and counter.
- *(Optional)* `seven_segment_display.v`: Module for car count display (commented out in current version).

---

## 🧪 Simulation Suggestions

You can simulate this design using ModelSim, Vivado, or any other Verilog simulator. Suggested testbench stimuli:
- Toggle entrance/exit sensors.
- Apply correct and incorrect passwords.
- Observe LED outputs and `countcar` register.

---

## 💡 License

This project is open-source and free to use for educational and non-commercial purposes.
