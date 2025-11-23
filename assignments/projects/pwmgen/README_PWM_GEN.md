# PWM Generator (`pwm_gen.v`) – Documentatie de implementare

Acest document descrie implementarea modulului **PWM Generator** (`pwm_gen.v`) utilizat pentru generarea semnalelor PWM. Acesta primeste configuratii din registrii si valoarea curenta a numaratorului, generand semnalul de iesire pwm_out conform specificatiilor.

---

## Implementarea modulului

### 1. Extrageri de biti din registrul `functions`

```verilog
wire align_left_right = functions[0];
wire aligned_mode = functions[1];
```

* `align_left_right` controleaza daca semnalul este left-aligned sau right-aligned.
* `aligned_mode` controleaza modul de functionare al PWM-ului (aligned sau unaligned).

---

### 2. Detectarea overflow/underflow

```verilog
wire overflow_event = (count_val == period);
wire wrap_event = (count_val == 0 && last_count_val == period);
wire overflow_underflow = overflow_event || wrap_event;
```

* `overflow_event` = 1 cand counter-ul ajunge la valoarea `PERIOD`.
* `wrap_event` = 1 cand counter-ul a facut wrap de la `PERIOD` la 0.
* `overflow_underflow` = combina ambele evenimente si marcheaza **inceputul unei noi perioade**.

---

### 3. Memorarea starii anterioare a counter-ului

```verilog
reg [15:0] last_count_val;
reg last_overflow_underflow;
```

* Se pastreaza valoarea counter-ului si starea overflow-ului de la pasul anterior pentru a detecta **momentul exact cand incepe o noua perioada**.

---

### 4. Retinerea configurarilor active la inceputul perioadei

```verilog
reg[15:0] active_period;
reg[15:0] active_compare1;
reg[15:0] active_compare2;
reg active_align_left_right;
reg active_aligned_mode;
```

* Aceste registre stocheaza configuratia curenta care se va utiliza **pana la urmatorul overflow**.
* Actualizarea se face doar **la frontul pozitiv al overflow/underflow**:

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

### 5. Generarea semnalului PWM

#### 5.1. PWM dezactivat

```verilog
if (!pwm_en)
    pwm_out <= pwm_out;
```

* Daca `pwm_en` = 0, semnalul PWM ramane in starea curenta.

---

#### 5.2. Mod aliniat (`aligned_mode == 0`)

* **Left-aligned (`align_left_right == 0`)**

```verilog
if (overflow_underflow && !last_overflow_underflow)
    pwm_out <= 1'b1;
else if (count_val == active_compare1)
    pwm_out <= 1'b0;
```

* La inceputul perioadei &rarr; `pwm_out` = 1

* Cand counter-ul ajunge la `COMPARE1` &rarr; `pwm_out` = 0

* **Right-aligned (`align_left_right == 1`)**

```verilog
if (overflow_underflow && !last_overflow_underflow)
    pwm_out <= 1'b0;
else if (count_val == active_compare1)
    pwm_out <= 1'b1;
```

* La inceputul perioadei &rarr; `pwm_out` = 0
* La `COMPARE1` &rarr; `pwm_out` = 1

---

#### 5.3. Mod nealiniat (`aligned_mode == 1`)

```verilog
if (overflow_underflow && !last_overflow_underflow)
    pwm_out <= 1'b0;
else if (count_val == active_compare1)
    pwm_out <= 1'b1;
else if (count_val == active_compare2)
    pwm_out <= 1'b0;
```

* La inceputul perioadei → `pwm_out` = 0

* La `COMPARE1` → `pwm_out` = 1

* La `COMPARE2` → `pwm_out` = 0

---

### 6. Reset si sincronizare

* La reset asincron (`rst_n == 0`) &rarr; toate registrele si semnalul PWM sunt initializate la 0.
* Toate operatiile se realizeaza pe frontul pozitiv al ceasului `clk`.

---

### 7. Rezumat

* Codul sincronizeaza configurarile PWM la **inceputul perioadei**.
* Suporta **left/right aligned** si **aligned/unaligned mode**.
* Gestionarea PWM se face pe baza valorilor `COMPARE1` si `COMPARE2` si a starii counter-ului.

