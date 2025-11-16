module instr_dcd (
    // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input[7:0] data_in,
    output[7:0] data_out,
    // register access signals
    output read,
    output write,
    output[5:0] addr,
    input[7:0] data_read,
    output[7:0] data_write
);

reg rw_reg;
reg hl_reg;
reg [5:0] addr_reg;
reg [7:0] data_out_reg;
reg [7:0] data_write_reg;
reg write_reg;
reg read_reg;


// 0 = SETUP, 1 = DATA
reg state;

assign data_out = data_out_reg;
assign data_write = data_write_reg;
assign addr = addr_reg;
assign read = read_reg;
assign write = write_reg;


endmodule