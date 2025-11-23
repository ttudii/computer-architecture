# PWM Generator (`pwm_gen.v`) – Implementation Documentation

## Module Implementation

### 1. Bit Extraction from `functions` Register
```verilog
wire align_left_right = functions[0];
wire aligned_mode = functions[1];
```

* `align_left_right` controls whether the signal is left-aligned or right-aligned.
* `aligned_mode` controls the PWM operating mode (aligned or unaligned).

---

### 2. Overflow/Underflow Detection
```verilog
wire overflow_event = (count_val == period);
wire wrap_event = (count_val == 0 && last_count_val == period);
wire overflow_underflow = overflow_event || wrap_event;
```

* `overflow_event` = 1 when the counter reaches the `PERIOD` value.
* `wrap_event` = 1 when the counter has wrapped from `PERIOD` to 0.
* `overflow_underflow` = combines both events and marks **the beginning of a new period**.

---

### 3. Storing Previous Counter State
```verilog
reg [15:0] last_count_val;
reg last_overflow_underflow;
```

* The counter value and overflow state from the previous step are preserved to detect **the exact moment when a new period begins**.

---

### 4. Retaining Active Configurations at Period Start
```verilog
reg[15:0] active_period;
reg[15:0] active_compare1;
reg[15:0] active_compare2;
reg active_align_left_right;
reg active_aligned_mode;
```

* These registers store the current configuration that will be used **until the next overflow**.
* Update occurs only **on the rising edge of overflow/underflow**:
```verilog
if (overflow_underflow && !last_overflow_underflow) begin
    active_period <= period;
    active_compare1 <= compare1;
    active_compare2 <= compare2;
    active_align_left_right <= align_left_right;
    active_aligned_mode <= aligned_mode;
end
```

---

### 5. PWM Signal Generation

#### 5.1. PWM Disabled
```verilog
if (!pwm_en)
    pwm_out <= pwm_out;
```

* If `pwm_en` = 0, the PWM signal remains in its current state.

---

#### 5.2. Aligned Mode (`aligned_mode == 0`)

* **Left-aligned (`align_left_right == 0`)**
```verilog
if (overflow_underflow && !last_overflow_underflow)
    pwm_out <= 1'b1;
else if (count_val == active_compare1)
    pwm_out <= 1'b0;
```

* At the beginning of the period &rarr; `pwm_out` = 1
* When the counter reaches `COMPARE1` &rarr; `pwm_out` = 0

* **Right-aligned (`align_left_right == 1`)**
```verilog
if (overflow_underflow && !last_overflow_underflow)
    pwm_out <= 1'b0;
else if (count_val == active_compare1)
    pwm_out <= 1'b1;
```

* At the beginning of the period &rarr; `pwm_out` = 0
* At `COMPARE1` &rarr; `pwm_out` = 1

---

#### 5.3. Unaligned Mode (`aligned_mode == 1`)
```verilog
if (overflow_underflow && !last_overflow_underflow)
    pwm_out <= 1'b0;
else if (count_val == active_compare1)
    pwm_out <= 1'b1;
else if (count_val == active_compare2)
    pwm_out <= 1'b0;
```

* At the beginning of the period → `pwm_out` = 0
* At `COMPARE1` &rarr; `pwm_out` = 1
* At `COMPARE2` &rarr; `pwm_out` = 0

---

### 6. Reset and Synchronization

* At asynchronous reset (`rst_n == 0`) &rarr; all registers and the PWM signal are initialized to 0.
* All operations occur on the rising edge of the `clk` clock.

---

### 7. Summary

* The code synchronizes PWM configurations at **the beginning of the period**.
* Supports **left/right aligned** and **aligned/unaligned mode**.
* PWM management is based on `COMPARE1` and `COMPARE2` values and counter state.