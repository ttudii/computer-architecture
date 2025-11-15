module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    input mosi,
    output miso,
    // internal facing 
    output byte_sync,
    output[7:0] data_in,
    input[7:0] data_out
);

reg [1:0] sclk_sync, cs_sync;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sclk_sync <= 2'b00;
        cs_sync <= 2'b11;
    end else begin
        sclk_sync <= {sclk_sync[0], sclk}
        cs_sync <= {cs_sync[0], cs_n}
    end
end

wire sclk_rising = (sclk_sync == 2'b01);
wire sclk_falling = (sclk_sync == 2'b10);
wire cs_active = ~cs_sync[1];

// Shift Registers and Counters

// SPI Logic

endmodule